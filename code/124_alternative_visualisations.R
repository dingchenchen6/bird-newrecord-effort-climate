#!/usr/bin/env Rscript
# ============================================================
# Script 124: 替代可视化形式 (不覆盖 Fig1-3) + 可编辑 PPTX
# Alternative visualisations with editable PPTX export
# ============================================================
# 目的 / Objective:
#   用与 Fig1-3 不同的图形语法呈现同一组结果, 供选图时对比;
#   全部图件额外导出【逐元素可编辑的 PPTX】(officer + rvg::dml)。
#
# 图件 / Figures (全部新文件名, 不覆盖既有 Fig1-3):
#   FigA1 交互曲面      预测风险在 (累积气候变化 x 调查努力) 平面上的填充等值面
#                       —— 比四条折线更完整地呈现交互结构
#   FigA2 规格景观      气候指标 x 滑动窗口 的 HR 热图 + 显著性标记 + 边际 dAIC 条
#   FigA3 证据权重      模型阶梯改用 Akaike 权重与证据比, 比 dAIC 更易解释
#   FigA4 系数斜边图    努力代理 x 三档阈值 的 dumbbell/slope 对比
#   FigA5 重要性瀑布    偏差解释份额的瀑布图 (累积贡献视角)
#
# 最终主模型 / Final model (tavg_annual, W=15, effort = visits):
#   event ~ clim_change_z * effort_z + clim_var_z + (1|species) + (1|province), cloglog
#
# Input / 输入:  analysis_final/tables/tbl_{A,B,C,D,E}_*.csv
#                analysis_final/data/final_model_thr50.rds
#                analysis_final/data/components_tavg_annual_W15.parquet
# Output / 输出: analysis_final/figures_alt/FigA{1..5}_*.{png,pdf,svg,pptx} + source data
#
# Main packages / 主要包: ggplot2, data.table, glmmTMB, officer, rvg
# 运行 / Run: Rscript --no-init-file code/124_alternative_visualisations.R
# ============================================================

suppressPackageStartupMessages({
  library(data.table); library(ggplot2); library(glmmTMB)
  library(officer); library(rvg); library(arrow)
  has_pw <- requireNamespace("patchwork", quietly = TRUE); if (has_pw) library(patchwork)
})
options(warn = 1)

V2  <- normalizePath(".", mustWork = TRUE)
OUT <- file.path(V2, "analysis_final")
TAB <- file.path(OUT, "tables")
FIG <- file.path(OUT, "figures_alt")
dir.create(FIG, recursive = TRUE, showWarnings = FALSE)
log <- function(...) cat(sprintf("[124 %s] ", format(Sys.time(), "%H:%M:%S")), ..., "\n")

OI <- c(blue = "#0072B2", orange = "#E69F00", green = "#009E73", red = "#D55E00",
        purple = "#CC79A7", sky = "#56B4E9", yellow = "#F0E442", grey = "#999999")

theme_pub <- function(base = 9) {
  theme_classic(base_size = base, base_family = "sans") +
    theme(axis.line = element_line(linewidth = 0.35, colour = "grey20"),
          axis.ticks = element_line(linewidth = 0.3, colour = "grey20"),
          axis.text = element_text(colour = "grey15"),
          panel.grid.major.y = element_line(linewidth = 0.25, colour = "grey92"),
          strip.background = element_blank(),
          strip.text = element_text(face = "bold", size = base, hjust = 0),
          plot.title = element_text(face = "bold", size = base + 2, hjust = 0),
          plot.subtitle = element_text(size = base - 0.5, colour = "grey30", hjust = 0),
          plot.caption = element_text(size = base - 2.5, colour = "grey45", hjust = 0),
          plot.tag = element_text(face = "bold", size = base + 3),
          plot.tag.position = c(0.005, 0.985),
          legend.key.size = unit(9, "pt"),
          legend.text = element_text(size = base - 1),
          legend.title = element_text(size = base - 1, face = "bold"),
          plot.margin = margin(6, 8, 6, 8))
}

# 统一导出: PNG(450dpi) + 矢量 PDF + SVG + 【可编辑 PPTX】
# editable PPTX via rvg::dml -> every element becomes a PowerPoint shape
save_all <- function(p, name, w, h, src = NULL) {
  for (ext in c("png", "pdf", "svg")) {
    f <- file.path(FIG, paste0(name, ".", ext))
    tryCatch({
      if (ext == "png") ggsave(f, p, width = w, height = h, dpi = 450, bg = "white")
      else if (ext == "pdf") ggsave(f, p, width = w, height = h, device = grDevices::cairo_pdf)
      else ggsave(f, p, width = w, height = h, device = grDevices::svg)
    }, error = function(e) log("   ", ext, " failed: ", conditionMessage(e)))
  }
  tryCatch({
    ppt <- read_pptx()
    ppt <- add_slide(ppt, layout = "Blank", master = "Office Theme")
    ppt <- ph_with(ppt, dml(ggobj = p, bg = "white"),
                   location = ph_location(left = 0.2, top = 0.2, width = w, height = h))
    print(ppt, target = file.path(FIG, paste0(name, ".pptx")))
  }, error = function(e) log("   pptx failed: ", conditionMessage(e)))
  if (!is.null(src)) fwrite(src, file.path(FIG, paste0("source_data_", name, ".csv")))
  log("  saved: ", name, "  (png/pdf/svg/pptx)")
}

A <- fread(file.path(TAB, "tbl_A_indicator_window.csv"))
B <- fread(file.path(TAB, "tbl_B_effort_proxy.csv"))
Cc<- fread(file.path(TAB, "tbl_C_threshold.csv"))
D <- fread(file.path(TAB, "tbl_D_ladder.csv"))
E <- fread(file.path(TAB, "tbl_E_importance.csv"))

star <- function(p) fifelse(p < 0.001, "***", fifelse(p < 0.01, "**",
                     fifelse(p < 0.05, "*", "")))

# ============ FigA1: 交互曲面 ============
m  <- readRDS(file.path(OUT, "data", "final_model_thr50.rds"))
cf <- fixef(m)$cond
b0 <- cf[["(Intercept)"]]; bcc <- cf[["clim_change_z"]]
bef <- cf[["effort_z"]];   bint <- cf[[grep(":", names(cf), value = TRUE)[1]]]
srf <- CJ(cc = seq(-2, 3, length.out = 160), ef = seq(-2, 3, length.out = 160))
srf[, hazard := 100 * (1 - exp(-exp(b0 + bcc * cc + bef * ef + bint * cc * ef)))]

cmp <- as.data.table(read_parquet(file.path(OUT, "data", "components_tavg_annual_W15.parquet")))
mdl <- as.data.table(read_parquet(file.path(V2, "analysis_species_specific", "data", "model_thr50.parquet")))
obs <- merge(mdl, cmp[, .(species, province, year, clim_change, clim_var)],
             by = c("species", "province", "year"))
obs <- obs[is.finite(clim_change) & is.finite(eff_visits)]
obs[, `:=`(cc = as.numeric(scale(clim_change)), ef = as.numeric(scale(eff_visits)))]
ev <- obs[event == 1]

pA1 <- ggplot(srf, aes(cc, ef)) +
  geom_raster(aes(fill = hazard), interpolate = TRUE) +
  geom_contour(aes(z = hazard), colour = "white", linewidth = 0.28, alpha = 0.8, bins = 10) +
  geom_point(data = ev, aes(cc, ef), shape = 21, size = 0.85, stroke = 0.28,
             fill = "white", colour = "grey15", alpha = 0.75) +
  scale_fill_viridis_c(option = "magma", direction = 1, name = "Annual\nhazard (%)") +
  coord_cartesian(xlim = c(-2, 3), ylim = c(-2, 3), expand = FALSE) +
  labs(x = "Accumulated climate change (SD)", y = "Survey effort (SD)",
       title = "Interaction surface: predicted hazard of a new distribution record",
       subtitle = "White contours = iso-hazard lines; open circles = 655 observed events",
       caption = "Converging contours toward the upper right show the negative interaction: the climate gradient flattens as effort rises.") +
  theme_pub() + theme(panel.grid.major.y = element_blank())
save_all(pA1, "FigA1_interaction_surface", 6.6, 5.4, srf[seq(1, .N, 40)])

# ============ FigA2: 规格景观热图 ============
IND_LAB <- c(tavg_annual = "Annual mean T", tavg_winter = "Winter mean T",
             tmax_warm = "Warmest-month Tmax", tmin_cold = "Coldest-month Tmin")
A[, ind_lab := factor(IND_LAB[indicator], levels = rev(unname(IND_LAB)))]
A[, lab := sprintf("%.2f%s", change_hr, star(change_p))]
pA2a <- ggplot(A, aes(factor(window), ind_lab, fill = change_hr)) +
  geom_tile(colour = "white", linewidth = 1.1) +
  geom_text(aes(label = lab), size = 2.7, colour = "grey10") +
  scale_fill_gradient2(low = OI[["blue"]], mid = "grey96", high = OI[["red"]],
                       midpoint = 1, name = "HR", limits = c(0.85, 1.5)) +
  labs(x = "Rolling window (years)", y = NULL,
       subtitle = "Climate-change hazard ratio (*** P<0.001, ** P<0.01, * P<0.05)") +
  theme_pub() + theme(panel.grid.major.y = element_blank())
pA2b <- ggplot(A, aes(factor(window), ind_lab, fill = dAIC_vs_effort)) +
  geom_tile(colour = "white", linewidth = 1.1) +
  geom_text(aes(label = sprintf("%.0f", dAIC_vs_effort)), size = 2.7, colour = "grey10") +
  scale_fill_gradient(low = OI[["green"]], high = "grey96", name = expression(Delta*"AIC")) +
  labs(x = "Rolling window (years)", y = NULL,
       subtitle = expression("Model improvement over effort-only ("*Delta*"AIC; greener = better)")) +
  theme_pub() + theme(panel.grid.major.y = element_blank(),
                      axis.text.y = element_blank())
if (has_pw) {
  pA2 <- (pA2a | pA2b) + plot_annotation(tag_levels = "a",
    title = "Specification landscape across climate indicators and accumulation windows")
  save_all(pA2, "FigA2_specification_landscape", 9.8, 3.6, A)
}

# ============ FigA3: Akaike 权重与证据比 ============
MOD_LAB <- c(N0_null = "Null", N1_effort = "Effort", N2_climate = "Climate only",
             N3_additive = "Additive", N4_intChange = "+ Climate x effort",
             N5_intBoth = "+ Both interactions", N6_static = "+ Static mismatch")
D[, w := exp(-0.5 * dAIC) / sum(exp(-0.5 * dAIC)), by = threshold]
D[, mod_lab := factor(MOD_LAB[model], levels = rev(unname(MOD_LAB)))]
pA3 <- ggplot(D, aes(w, mod_lab, colour = factor(threshold))) +
  geom_segment(aes(x = 0, xend = w, yend = mod_lab), linewidth = 0.5,
               position = position_dodge(0.6), alpha = 0.55) +
  geom_point(size = 2.4, position = position_dodge(0.6)) +
  scale_colour_manual(values = unname(OI[c("blue", "orange", "green")]), name = "SDM threshold") +
  scale_x_continuous(labels = scales::percent_format(accuracy = 1),
                     expand = expansion(mult = c(0, 0.08))) +
  labs(x = "Akaike weight (probability of being the best model)", y = NULL,
       title = "Model evidence expressed as Akaike weights",
       subtitle = "The two interaction models together carry essentially all the non-static evidence",
       caption = "Weights are computed within each threshold across the seven candidate models.") +
  theme_pub() + theme(legend.position = "top")
save_all(pA3, "FigA3_akaike_weights", 7.4, 4.2, D)

# ============ FigA4: 系数斜边图 (努力代理) ============
EFF_LAB <- c(eff_visits = "Visits", eff_records = "Records", eff_observers = "Observers",
             eff_days = "Birding days", eff_pca = "PCA composite")
B[, eff_lab := factor(EFF_LAB[effort], levels = rev(unname(EFF_LAB)))]
db <- B[, .(eff_lab, change_hr, int_change_hr, change_p, int_change_p)]
pA4 <- ggplot(db) +
  geom_vline(xintercept = 1, linetype = 2, linewidth = 0.35, colour = "grey45") +
  geom_segment(aes(x = int_change_hr, xend = change_hr, y = eff_lab, yend = eff_lab),
               colour = "grey75", linewidth = 1.4, lineend = "round") +
  geom_point(aes(int_change_hr, eff_lab, colour = "Climate change x effort"), size = 3) +
  geom_point(aes(change_hr, eff_lab, colour = "Climate change (15-yr)"), size = 3) +
  geom_text(aes(int_change_hr, eff_lab, label = sprintf("%.2f%s", int_change_hr, star(int_change_p))),
            vjust = -1.2, size = 2.4, colour = OI[["purple"]]) +
  geom_text(aes(change_hr, eff_lab, label = sprintf("%.2f%s", change_hr, star(change_p))),
            vjust = -1.2, size = 2.4, colour = OI[["red"]]) +
  scale_colour_manual(values = c("Climate change (15-yr)" = unname(OI[["red"]]),
                                 "Climate change x effort" = unname(OI[["purple"]])), name = NULL) +
  labs(x = "Hazard ratio per 1 SD", y = NULL,
       title = "Climate effect and its moderation are stable across survey-effort proxies",
       subtitle = "Each bar links the interaction (left) to the main climate effect (right) for one effort metric") +
  theme_pub() + theme(legend.position = "top")
save_all(pA4, "FigA4_effort_dumbbell", 7.6, 4.0, db)

# ============ FigA5: 重要性瀑布 ============
wf <- melt(E, id.vars = "threshold",
           measure.vars = c("pct_effort", "pct_clim_change", "pct_clim_var", "pct_interactions"),
           variable.name = "component", value.name = "pct")
LAB <- c(pct_effort = "Survey effort", pct_clim_change = "Climate change (15-yr)",
         pct_clim_var = "Annual climate variability", pct_interactions = "Climate change x effort")
wf[, comp := factor(LAB[as.character(component)], levels = unname(LAB))]
setorder(wf, threshold, comp)
wf[, ymin := cumsum(shift(pct, fill = 0)), by = threshold]
wf[, ymax := ymin + pct]
wf[, thr_lab := paste0("SDM threshold ", threshold)]
pA5 <- ggplot(wf, aes(comp, fill = comp)) +
  geom_rect(aes(xmin = as.numeric(comp) - 0.35, xmax = as.numeric(comp) + 0.35,
                ymin = ymin, ymax = ymax), colour = "white", linewidth = 0.4) +
  geom_text(aes(x = as.numeric(comp), y = ymax, label = sprintf("%.0f%%", pct)),
            vjust = -0.45, size = 2.5, colour = "grey20") +
  facet_wrap(~ thr_lab, nrow = 1) +
  scale_fill_manual(values = unname(OI[c("blue", "red", "green", "purple")]), guide = "none") +
  scale_y_continuous(expand = expansion(mult = c(0, 0.12))) +
  labs(x = NULL, y = "Cumulative deviance explained (%)",
       title = "Cumulative contribution of each process to explained deviance",
       subtitle = "Survey effort sets the level; climate change adds a further ~15%; the interaction ~4%",
       caption = "Drop-term contributions; components overlap slightly so the cumulative total exceeds 100%.") +
  theme_pub() + theme(axis.text.x = element_text(angle = 22, hjust = 1))
save_all(pA5, "FigA5_importance_waterfall", 9.2, 4.4, wf)

log("DONE")
