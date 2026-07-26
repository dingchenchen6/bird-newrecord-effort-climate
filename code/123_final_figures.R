#!/usr/bin/env Rscript
# ============================================================
# Script 123: 最终流水线 (4/4) —— 投稿级图件
# Final pipeline (4/4): publication-quality figures
# ============================================================
# 目的 / Objective:
#   将最终分析结果制成可直接投稿的图件 (英文标注, 目标 Nature Ecol Evol /
#   Ecology Letters), 每图输出 PNG(450dpi) + 矢量 PDF + SVG + source data。
#
# 最终主模型 / Final model (tavg_annual, W = 15 yr, effort = visits):
#   event ~ clim_change_z * effort_z + clim_var_z + (1|species) + (1|province)
#   family = binomial("cloglog")   离散时间比例风险 / discrete-time proportional hazards
#
# 图件清单 / Figures:
#   Fig1 主结果 3 面板: (a) 系数森林图 x 三档 SDM 阈值
#                       (b) 交互效应: 不同努力水平下气候变化的边际效应
#                       (c) 相对重要性 (偏差解释份额)
#   Fig2 规格稳健性 3 面板: (a) 气候指标 x 滑动窗口 的气候变化 HR
#                           (b) 同上的 dAIC 曲面
#                           (c) 五个调查努力代理的森林图
#   Fig3 模型选择阶梯 (dAIC x 三档阈值)
#
# 设计规范 / Design standards:
#   - Okabe-Ito 色盲友好配色; 无冗余装饰; 直接标注优先于图例
#   - HR 轴统一以 1 为参考线; 误差棒为 95% Wald CI
#   - 面板字母 a/b/c 加粗左上; 字体 sans; 输出前统一 theme
#
# Input / 输入:  analysis_final/tables/tbl_{A,B,C,D,E}_*.csv
#                analysis_final/data/final_model_thr50.rds
# Output / 输出: analysis_final/figures/Fig{1,2,3}_*.{png,pdf,svg} + source_data_*.csv
#
# Main packages / 主要包: data.table, ggplot2, patchwork, glmmTMB
# 运行 / Run: Rscript --no-init-file code/123_final_figures.R
# ============================================================

suppressPackageStartupMessages({
  library(data.table); library(ggplot2); library(glmmTMB)
  library(officer); library(rvg)
  has_pw <- requireNamespace("patchwork", quietly = TRUE); if (has_pw) library(patchwork)
})
options(warn = 1)

V2  <- normalizePath(".", mustWork = TRUE)
OUT <- file.path(V2, "analysis_final")
TAB <- file.path(OUT, "tables"); FIG <- file.path(OUT, "figures")
log <- function(...) cat(sprintf("[123 %s] ", format(Sys.time(), "%H:%M:%S")), ..., "\n")

# ---- Okabe-Ito 色盲友好配色 / colourblind-safe palette ----
OI <- c(blue = "#0072B2", orange = "#E69F00", green = "#009E73", red = "#D55E00",
        purple = "#CC79A7", sky = "#56B4E9", yellow = "#F0E442", grey = "#999999")

theme_pub <- function(base = 9) {
  theme_classic(base_size = base, base_family = "sans") +
    theme(
      axis.line   = element_line(linewidth = 0.35, colour = "grey20"),
      axis.ticks  = element_line(linewidth = 0.3,  colour = "grey20"),
      axis.text   = element_text(colour = "grey15"),
      axis.title  = element_text(colour = "grey5"),
      panel.grid.major.y = element_line(linewidth = 0.25, colour = "grey92"),
      strip.background = element_blank(),
      strip.text  = element_text(face = "bold", size = base, hjust = 0),
      plot.title  = element_text(face = "bold", size = base + 2, hjust = 0),
      plot.subtitle = element_text(size = base - 0.5, colour = "grey30", hjust = 0),
      plot.tag    = element_text(face = "bold", size = base + 3),
      plot.tag.position = c(0.005, 0.985),
      legend.key.size = unit(9, "pt"),
      legend.text = element_text(size = base - 1),
      legend.title = element_text(size = base - 1, face = "bold"),
      plot.margin = margin(6, 8, 6, 8))
}

save_fig <- function(p, name, w, h, src = NULL) {
  for (ext in c("png", "pdf", "svg")) {
    f <- file.path(FIG, paste0(name, ".", ext))
    tryCatch({
      if (ext == "png") ggsave(f, p, width = w, height = h, dpi = 450, bg = "white")
      else if (ext == "pdf") ggsave(f, p, width = w, height = h, device = grDevices::cairo_pdf)
      else ggsave(f, p, width = w, height = h, device = grDevices::svg)
    }, error = function(e) log("  ", ext, " failed: ", conditionMessage(e)))
  }
  # 可编辑 PPTX: rvg::dml 将 ggplot 转为 PowerPoint 原生矢量形状
  # editable PPTX: every element becomes a PowerPoint shape
  tryCatch({
    ppt <- read_pptx(); ppt <- add_slide(ppt, "Blank", "Office Theme")
    ppt <- ph_with(ppt, dml(ggobj = p, bg = "white"),
                   location = ph_location(left = 0.2, top = 0.2, width = w, height = h))
    print(ppt, target = file.path(FIG, paste0(name, ".pptx")))
  }, error = function(e) log("  pptx failed: ", conditionMessage(e)))
  if (!is.null(src)) fwrite(src, file.path(FIG, paste0("source_data_", name, ".csv")))
  log("  figure saved: ", name, " (png/pdf/svg/pptx)")
}

A <- fread(file.path(TAB, "tbl_A_indicator_window.csv"))
B <- fread(file.path(TAB, "tbl_B_effort_proxy.csv"))
Cc<- fread(file.path(TAB, "tbl_C_threshold.csv"))
D <- fread(file.path(TAB, "tbl_D_ladder.csv"))
E <- fread(file.path(TAB, "tbl_E_importance.csv"))

TERM_LAB <- c(effort = "Survey effort",
              change = "Climate change (15-yr)",
              var    = "Annual climate variability",
              int    = "Climate change x effort")

# ============ Fig 1a: 系数森林图 x 三档阈值 ============
f1 <- rbindlist(lapply(c("effort", "change", "var", "int_change"), function(k) {
  Cc[, .(threshold, term = k,
         hr = get(paste0(k, "_hr")), lo = get(paste0(k, "_lo")), hi = get(paste0(k, "_hi")),
         p  = get(paste0(k, "_p")))]
}))
f1[, term_lab := factor(term, levels = c("int_change", "var", "change", "effort"),
     labels = c(TERM_LAB[["int"]], TERM_LAB[["var"]], TERM_LAB[["change"]], TERM_LAB[["effort"]]))]
f1[, thr_lab := factor(threshold, levels = c(50, 100, 200),
                       labels = c("50", "100", "200"))]
p1a <- ggplot(f1, aes(hr, term_lab, colour = thr_lab)) +
  geom_vline(xintercept = 1, linetype = 2, linewidth = 0.35, colour = "grey45") +
  geom_errorbarh(aes(xmin = lo, xmax = hi), height = 0.18,
                 position = position_dodge(0.55), linewidth = 0.45) +
  geom_point(size = 1.9, position = position_dodge(0.55)) +
  scale_colour_manual(values = unname(OI[c("blue", "orange", "green")]),
                      name = "SDM threshold") +
  scale_x_continuous(trans = "log", breaks = c(0.8, 0.9, 1, 1.2, 1.5, 1.8),
                     labels = c("0.8", "0.9", "1.0", "1.2", "1.5", "1.8")) +
  labs(x = "Hazard ratio per 1 SD (95% CI)", y = NULL,
       subtitle = "Discrete-time cloglog hazard model; 655 events") +
  theme_pub() + theme(legend.position = c(0.87, 0.22),
                      legend.background = element_rect(fill = "white", colour = NA))

# ============ Fig 1b: 交互效应 ============
m <- readRDS(file.path(OUT, "data", "final_model_thr50.rds"))
cf <- fixef(m)$cond
b0 <- cf[["(Intercept)"]]; b_cc <- cf[["clim_change_z"]]
b_ef <- cf[["effort_z"]]; b_int <- cf[[grep(":", names(cf), value = TRUE)[1]]]
grid <- CJ(cc = seq(-2, 3, by = 0.05), ef = c(-1, 0, 1, 2))
grid[, lp := b0 + b_cc * cc + b_ef * ef + b_int * cc * ef]
grid[, hazard := 100 * (1 - exp(-exp(lp)))]          # cloglog -> 年风险 %
grid[, eff_lab := factor(ef, levels = c(-1, 0, 1, 2),
     labels = c("-1 SD (low)", "Mean", "+1 SD", "+2 SD (high)"))]
# 直接标注曲线右端, 不用图例 (顶刊惯例) / direct labelling instead of a legend
lab_end <- grid[cc == max(cc)]
p1b <- ggplot(grid, aes(cc, hazard, colour = eff_lab)) +
  geom_line(linewidth = 0.7) +
  geom_text(data = lab_end, aes(label = eff_lab), hjust = -0.06, size = 2.5,
            show.legend = FALSE) +
  annotate("text", x = -2, y = max(grid$hazard) * 1.02, hjust = 0, size = 2.5,
           colour = "grey30", label = "Survey effort") +
  scale_colour_manual(values = unname(OI[c("sky", "blue", "orange", "red")]), guide = "none") +
  scale_y_continuous(labels = function(x) sprintf("%.2f", x)) +
  scale_x_continuous(limits = c(-2, 4.6), breaks = seq(-2, 3, 1)) +
  labs(x = "Accumulated climate change (SD)", y = "Annual hazard of a new record (%)",
       subtitle = "Climate effect is steepest where survey effort is low") +
  theme_pub()

# ============ Fig 1c: 相对重要性 ============
im <- melt(E, id.vars = "threshold",
           measure.vars = c("pct_effort", "pct_clim_change", "pct_clim_var", "pct_interactions"),
           variable.name = "component", value.name = "pct")
im[, component := factor(component,
     levels = c("pct_effort", "pct_clim_change", "pct_clim_var", "pct_interactions"),
     labels = c(TERM_LAB[["effort"]], TERM_LAB[["change"]], TERM_LAB[["var"]], TERM_LAB[["int"]]))]
p1c <- ggplot(im, aes(factor(threshold), pct, fill = component)) +
  geom_col(position = position_dodge(0.75), width = 0.68) +
  geom_text(aes(label = sprintf("%.0f", pct)), position = position_dodge(0.75),
            vjust = -0.4, size = 2.4, colour = "grey20") +
  scale_fill_manual(values = unname(OI[c("blue", "red", "green", "purple")]), name = NULL) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.12))) +
  labs(x = "SDM threshold", y = "Deviance explained (%)",
       subtitle = "Drop-term contribution to explained deviance") +
  theme_pub() + theme(legend.position = "right", legend.direction = "vertical",
                      legend.key.height = unit(11, "pt"))

if (has_pw) {
  fig1 <- (p1a | p1b) / p1c +
    plot_layout(heights = c(1, 0.60)) +
    plot_annotation(tag_levels = "a",
      title = "Survey effort dominates, but accumulated climate change independently raises new-record hazard")
  save_fig(fig1, "Fig1_main_results", 10.0, 6.4, f1)
} else { save_fig(p1a, "Fig1a_forest", 5, 3, f1); save_fig(p1b, "Fig1b_interaction", 5, 3, grid)
         save_fig(p1c, "Fig1c_importance", 5, 3.2, im) }

# ============ Fig 2: 规格稳健性 ============
IND_LAB <- c(tavg_annual = "Annual mean T", tavg_winter = "Winter mean T",
             tmax_warm = "Warmest-month Tmax", tmin_cold = "Coldest-month Tmin")
A[, ind_lab := factor(IND_LAB[indicator], levels = unname(IND_LAB))]
p2a <- ggplot(A, aes(window, change_hr, colour = ind_lab, group = ind_lab)) +
  geom_hline(yintercept = 1, linetype = 2, linewidth = 0.35, colour = "grey45") +
  geom_errorbar(aes(ymin = change_lo, ymax = change_hi), width = 0.45,
                linewidth = 0.35, position = position_dodge(0.9), alpha = 0.75) +
  geom_line(linewidth = 0.6, position = position_dodge(0.9)) +
  geom_point(size = 1.7, position = position_dodge(0.9)) +
  scale_colour_manual(values = unname(OI[c("red", "blue", "orange", "green")]), name = NULL) +
  scale_fill_manual(values = unname(OI[c("red", "blue", "orange", "green")]), guide = "none") +
  scale_x_continuous(breaks = c(5, 10, 15, 20)) +
  labs(x = "Rolling window (years)", y = "Climate-change HR (95% CI)",
       subtitle = "Signal requires >= 10 yr of accumulation") +
  theme_pub() + theme(legend.position = c(0.28, 0.85),
                      legend.background = element_rect(fill = "white", colour = NA))

p2b <- ggplot(A, aes(window, dAIC_vs_effort, colour = ind_lab, group = ind_lab)) +
  geom_hline(yintercept = 0, linetype = 2, linewidth = 0.35, colour = "grey45") +
  geom_line(linewidth = 0.6) + geom_point(size = 1.7) +
  scale_colour_manual(values = unname(OI[c("red", "blue", "orange", "green")]), guide = "none") +
  scale_x_continuous(breaks = c(5, 10, 15, 20)) +
  labs(x = "Rolling window (years)", y = expression(Delta*"AIC vs effort-only model"),
       subtitle = "More negative = better than effort alone") +
  theme_pub()

EFF_LAB <- c(eff_visits = "Visits", eff_records = "Records", eff_observers = "Observers",
             eff_days = "Birding days", eff_pca = "PCA composite")
B[, eff_lab := factor(EFF_LAB[effort], levels = unname(EFF_LAB))]
b2 <- rbindlist(list(
  B[, .(eff_lab, term = TERM_LAB[["change"]], hr = change_hr, lo = change_lo, hi = change_hi)],
  B[, .(eff_lab, term = TERM_LAB[["int"]],    hr = int_change_hr, lo = int_change_lo, hi = int_change_hi)]))
p2c <- ggplot(b2, aes(hr, eff_lab, colour = term)) +
  geom_vline(xintercept = 1, linetype = 2, linewidth = 0.35, colour = "grey45") +
  geom_errorbarh(aes(xmin = lo, xmax = hi), height = 0.16,
                 position = position_dodge(0.5), linewidth = 0.45) +
  geom_point(size = 1.9, position = position_dodge(0.5)) +
  scale_colour_manual(values = unname(OI[c("red", "purple")]), name = NULL) +
  labs(x = "Hazard ratio per 1 SD (95% CI)", y = NULL,
       subtitle = "Consistent across all five effort proxies") +
  theme_pub() + theme(legend.position = "top")

if (has_pw) {
  fig2 <- (p2a | p2b) / p2c + plot_layout(heights = c(1, 0.66)) +
    plot_annotation(tag_levels = "a",
      title = "Specification robustness: climate indicator, accumulation window and effort proxy")
  save_fig(fig2, "Fig2_specification_robustness", 10.0, 6.2, A)
} else { save_fig(p2a, "Fig2a_window", 5, 3, A); save_fig(p2c, "Fig2c_effort", 5, 3, b2) }

# ============ Fig 3: 模型阶梯 ============
MOD_LAB <- c(N0_null = "Null", N1_effort = "Effort", N2_climate = "Climate only",
             N3_additive = "Additive", N4_intChange = "+ Climate x effort",
             N5_intBoth = "+ Both interactions", N6_static = "+ Static mismatch")
D[, mod_lab := factor(MOD_LAB[model], levels = unname(MOD_LAB))]
p3 <- ggplot(D, aes(mod_lab, dAIC, fill = factor(threshold))) +
  geom_col(position = position_dodge(0.72), width = 0.66) +
  geom_text(aes(label = sprintf("%.1f", dAIC)), position = position_dodge(0.72),
            vjust = -0.35, size = 2.2, colour = "grey25") +
  scale_fill_manual(values = unname(OI[c("blue", "orange", "green")]), name = "SDM threshold") +
  scale_y_continuous(expand = expansion(mult = c(0, 0.1))) +
  annotate("rect", xmin = 4.5, xmax = 5.5, ymin = -Inf, ymax = Inf,
           fill = OI[["yellow"]], alpha = 0.16) +
  annotate("text", x = 5, y = max(D$dAIC) * 0.62, label = "selected model",
           size = 2.7, fontface = "bold", colour = "grey20") +
  labs(x = NULL, y = expression(Delta*"AIC (0 = best-fitting)"),
       title = "Model selection ladder",
       subtitle = paste0("The climate-change x effort interaction improves fit over the additive model at every threshold.\n",
                         "The static climate-mismatch term fits best but is a time-invariant pair-level confounder, ",
                         "not a mechanism; it is retained only as a sensitivity check.")) +
  theme_pub() + theme(legend.position = "top",
                      axis.text.x = element_text(angle = 20, hjust = 1))
save_fig(p3, "Fig3_model_ladder", 8.8, 4.6, D)

log("DONE")
