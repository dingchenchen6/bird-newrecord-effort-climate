#!/usr/bin/env Rscript
# ============================================================
# Script 126: 未来情景预测地图 —— 机制模型 vs 可解释机器学习
# Future projections: mechanistic hazard model vs interpretable ML
# ============================================================
# 科学问题 / Scientific question:
#   在最终规格下, 未来新纪录风险的空间格局如何演变? 机制模型(cloglog 风险模型)
#   与机器学习(XGBoost + TreeSHAP)是否给出一致的空间格局与驱动解释?
#
# 机制模型 / Mechanistic (final model):
#   event ~ clim_change_z * effort_z + clim_var_z + (1|species) + (1|province), cloglog
#
# 可解释 ML / Interpretable ML:
#   XGBoost (binary:logistic) + 精确 TreeSHAP (predict predcontrib = TRUE)
#   特征与机制模型一致, 便于逐特征对照解释, 不引入机制模型没有的信息。
#
# 未来情景 / Scenarios:
#   气候: CMIP6 4-GCM 集成中位 delta, SSP2-4.5 / SSP5-8.5 x 2030 / 2050 / 2080
#         ★ delta 必须【同时施加到目标省与物种分布区两端】, 否则会凭空造出气候效应
#           (物种特异梯度 = 省异常 − 分布区异常, 空间近均一的增温会相互抵消)
#   努力: SSP 差异化增长 (SSP245 +0.30, SSP585 +0.60 SD/decade)
#
# Output / 输出 (analysis_final/figures_future/):
#   FigM1 机制模型 省级预测面 (SSP x 年代 网格)
#   FigM2 ML 预测面 (同布局)
#   FigM3 SHAP 可解释性 (特征重要性 + 依赖图)
#   FigM4 机制 vs ML 一致性 (散点 + 分歧地图)
#   每图 PNG(450dpi) + PDF + SVG + 可编辑 PPTX + source data
#
# 地图规范 / Map standards:
#   叠加官方 GS(2019)1822 国界与南海九段线; 冷-暖发散配色; 四周留边距
#
# Main packages / 主要包: glmmTMB, xgboost, sf, ggplot2, officer, rvg
# 运行 / Run: Rscript --no-init-file code/126_future_maps_mech_vs_ml.R
# ============================================================

suppressPackageStartupMessages({
  library(data.table); library(arrow); library(glmmTMB); library(xgboost)
  library(sf); library(ggplot2); library(officer); library(rvg)
  has_pw <- requireNamespace("patchwork", quietly = TRUE); if (has_pw) library(patchwork)
})
options(warn = 1); set.seed(42); sf::sf_use_s2(FALSE)

V2  <- normalizePath(".", mustWork = TRUE)
SS  <- file.path(V2, "analysis_species_specific")
OUT <- file.path(V2, "analysis_final")
FIG <- file.path(OUT, "figures_future"); TAB <- file.path(OUT, "tables")
SHP <- file.path(V2, "data", "spatial", "basemap_GS2019_1822")
dir.create(FIG, recursive = TRUE, showWarnings = FALSE)
log <- function(...) cat(sprintf("[126 %s] ", format(Sys.time(), "%H:%M:%S")), ..., "\n")

OI <- c(blue = "#0072B2", orange = "#E69F00", green = "#009E73", red = "#D55E00",
        purple = "#CC79A7", sky = "#56B4E9", grey = "#999999")
EFF_GROW <- c(ssp245 = 0.30, ssp585 = 0.60)

theme_pub <- function(base = 9) theme_classic(base_size = base, base_family = "sans") +
  theme(axis.line = element_line(linewidth = 0.35, colour = "grey20"),
        axis.ticks = element_line(linewidth = 0.3, colour = "grey20"),
        panel.grid.major.y = element_line(linewidth = 0.25, colour = "grey92"),
        strip.background = element_blank(),
        strip.text = element_text(face = "bold", size = base, hjust = 0.5),
        plot.title = element_text(face = "bold", size = base + 2, hjust = 0),
        plot.subtitle = element_text(size = base - 0.5, colour = "grey30", hjust = 0),
        plot.caption = element_text(size = base - 2.5, colour = "grey45", hjust = 0),
        plot.tag = element_text(face = "bold", size = base + 3),
        legend.key.size = unit(9, "pt"), plot.margin = margin(6, 8, 6, 8))
theme_map <- function(base = 9) theme_void(base_size = base, base_family = "sans") +
  theme(strip.text = element_text(face = "bold", size = base),
        plot.title = element_text(face = "bold", size = base + 2, hjust = 0),
        plot.subtitle = element_text(size = base - 0.5, colour = "grey30", hjust = 0),
        plot.caption = element_text(size = base - 2.5, colour = "grey45", hjust = 0),
        legend.key.width = unit(26, "pt"), legend.key.height = unit(7, "pt"),
        legend.position = "bottom", plot.margin = margin(6, 10, 6, 10))

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
    ppt <- read_pptx(); ppt <- add_slide(ppt, "Blank", "Office Theme")
    ppt <- ph_with(ppt, dml(ggobj = p, bg = "white"),
                   location = ph_location(left = 0.2, top = 0.2, width = w, height = h))
    print(ppt, target = file.path(FIG, paste0(name, ".pptx")))
  }, error = function(e) log("   pptx failed: ", conditionMessage(e)))
  if (!is.null(src)) fwrite(src, file.path(FIG, paste0("source_data_", name, ".csv")))
  log("  saved: ", name, " (png/pdf/svg/pptx)")
}

# ---- 1. 数据与模型 / data and models ----
mdl <- as.data.table(read_parquet(file.path(SS, "data", "model_thr50.parquet")))
cmp <- as.data.table(read_parquet(file.path(OUT, "data", "components_tavg_annual_W15.parquet")))
d <- merge(mdl, cmp[, .(species, province, year, clim_change, clim_var, b_static)],
           by = c("species", "province", "year"))
d <- d[is.finite(clim_change) & is.finite(clim_var) & is.finite(eff_visits)]
CC_MU <- mean(d$clim_change); CC_SD <- stats::sd(d$clim_change)
CV_MU <- mean(d$clim_var);    CV_SD <- stats::sd(d$clim_var)
EF_MU <- mean(d$eff_visits);  EF_SD <- stats::sd(d$eff_visits)
d[, `:=`(clim_change_z = (clim_change - CC_MU) / CC_SD,
         clim_var_z    = (clim_var - CV_MU) / CV_SD,
         effort_z      = (eff_visits - EF_MU) / EF_SD)]
log("建模集 ", format(nrow(d), big.mark = ","), " 行 | ", sum(d$event), " 事件")

mech <- readRDS(file.path(OUT, "data", "final_model_thr50.rds"))
FEATS <- c("clim_change_z", "clim_var_z", "effort_z")
xgb_file <- file.path(OUT, "data", "xgb_final.rds")
if (file.exists(xgb_file)) { bst <- readRDS(xgb_file); log("复用 XGBoost 模型") } else {
  dm <- xgb.DMatrix(as.matrix(d[, ..FEATS]), label = d$event)
  bst <- xgb.train(list(objective = "binary:logistic", eta = 0.05, max_depth = 4,
                        subsample = 0.8, colsample_bytree = 0.9, eval_metric = "auc"),
                   dm, nrounds = 400, verbose = 0)
  saveRDS(bst, xgb_file); log("XGBoost 训练完成")
}

# ---- 2. 未来协变量 / future covariates ----
cm6 <- fread(file.path(SS, "tables", "tbl_F_cmip6_delta.csv"))
dp <- cm6[unit == "province", .(province = name, ssp, horizon, d_prov = delta)]
ds <- cm6[unit == "species",  .(species  = name, ssp, horizon, d_sp   = delta)]
base_yr <- d[year == max(year)]
log("投影基期 ", max(d$year), ": ", nrow(base_yr), " 行")

proj <- rbindlist(lapply(c("ssp245", "ssp585"), function(sp_) {
  rbindlist(lapply(c(2030L, 2050L, 2080L), function(hz) {
    b <- copy(base_yr)
    b <- merge(b, dp[ssp == sp_ & horizon == hz, .(province, d_prov)], by = "province", all.x = TRUE)
    b <- merge(b, ds[ssp == sp_ & horizon == hz, .(species, d_sp)],   by = "species",  all.x = TRUE)
    b[is.na(d_prov), d_prov := 0]; b[is.na(d_sp), d_sp := 0]
    # delta 同时施加两端 -> 只保留空间不均一部分 / applied to both ends
    b[, clim_change_f := clim_change + (d_prov - d_sp)]
    b[, clim_change_z := (clim_change_f - CC_MU) / CC_SD]
    dec <- (hz - max(d$year)) / 10
    b[, effort_z := effort_z + EFF_GROW[[sp_]] * dec]
    b[, `:=`(ssp = sp_, horizon = hz)]
    b
  }))
}))
proj[, p_mech := as.numeric(predict(mech, newdata = proj, type = "response", allow.new.levels = TRUE))]
fx <- as.matrix(proj[, FEATS, with = FALSE])
proj[, p_ml := as.numeric(predict(bst, fx))]

# 2024 基期(无 CMIP6 delta、无努力增长) / baseline for relative change
b24 <- copy(base_yr)
b24[, p_mech := as.numeric(predict(mech, newdata = b24, type = "response", allow.new.levels = TRUE))]
b24[, p_ml := as.numeric(predict(bst, as.matrix(b24[, FEATS, with = FALSE])))]
base_prov <- b24[, .(mech0 = mean(p_mech, na.rm = TRUE),
                     ml0   = mean(p_ml,   na.rm = TRUE)), by = province]

prov_proj <- proj[, .(mech = 100 * mean(p_mech, na.rm = TRUE),
                      ml   = 100 * mean(p_ml,   na.rm = TRUE),
                      n_sp = uniqueN(species)), by = .(province, ssp, horizon)]
prov_proj <- merge(prov_proj, base_prov, by = "province")
prov_proj[, `:=`(mech_ratio = (mech / 100) / mech0, ml_ratio = (ml / 100) / ml0)]
log("相对倍数范围: 机制 ", round(min(prov_proj$mech_ratio), 2), "-", round(max(prov_proj$mech_ratio), 2),
    " | ML ", round(min(prov_proj$ml_ratio), 2), "-", round(max(prov_proj$ml_ratio), 2))
fwrite(prov_proj, file.path(TAB, "tbl_H_future_province_projection.csv"))
log("省级投影表: ", nrow(prov_proj), " 行")

# ---- 3. 底图 / basemap ----
PROV_CN_EN <- c("北京市"="Beijing","天津市"="Tianjin","河北省"="Hebei","山西省"="Shanxi",
 "内蒙古自治区"="Inner Mongolia","辽宁省"="Liaoning","吉林省"="Jilin","黑龙江省"="Heilongjiang",
 "上海市"="Shanghai","江苏省"="Jiangsu","浙江省"="Zhejiang","安徽省"="Anhui","福建省"="Fujian",
 "江西省"="Jiangxi","山东省"="Shandong","河南省"="Henan","湖北省"="Hubei","湖南省"="Hunan",
 "广东省"="Guangdong","广西壮族自治区"="Guangxi","海南省"="Hainan","重庆市"="Chongqing",
 "四川省"="Sichuan","贵州省"="Guizhou","云南省"="Yunnan","西藏自治区"="Tibet","陕西省"="Shaanxi",
 "甘肃省"="Gansu","青海省"="Qinghai","宁夏回族自治区"="Ningxia","新疆维吾尔自治区"="Xinjiang",
 "台湾省"="Taiwan","香港特别行政区"="Hong Kong","澳门特别行政区"="Macau")
pv <- st_make_valid(st_transform(st_read(file.path(SHP, "省（等积投影）.shp"), quiet = TRUE), 4326))
pv$province <- unname(PROV_CN_EN[as.character(pv[["省"]])])
outline <- tryCatch(st_transform(st_read(file.path(SHP, "中国轮廓线.shp"), quiet = TRUE), 4326), error = function(e) NULL)
nanhai  <- tryCatch(st_transform(st_read(file.path(SHP, "九段线.shp"), quiet = TRUE), 4326), error = function(e) NULL)

# 只保留有投影的省份并显式展开 省 x SSP x 年代, 避免 NA 分面
# expand geometry across facets so no NA panels appear
map_panel <- function(dt, valcol, title, sub) {
  dt <- as.data.table(dt)[is.finite(get(valcol))]
  geo <- pv[pv$province %in% unique(dt$province), c("province")]
  mp <- merge(geo, dt[, .(province, ssp, horizon, val = get(valcol))],
              by = "province", all.x = FALSE)
  mp$ssp_lab  <- factor(mp$ssp, levels = c("ssp245", "ssp585"),
                        labels = c("SSP2-4.5", "SSP5-8.5"))
  mp$hz_lab   <- factor(mp$horizon, levels = c(2030, 2050, 2080))
  brks <- c(0.5, 1, 2, 4, 8, 16)
  ggplot() +
    geom_sf(data = mp, aes(fill = val), colour = "grey45", linewidth = 0.1) +
    { if (!is.null(outline)) geom_sf(data = outline, fill = NA, colour = "grey15", linewidth = 0.28) } +
    { if (!is.null(nanhai))  geom_sf(data = nanhai,  fill = NA, colour = "grey15", linewidth = 0.38) } +
    facet_grid(ssp_lab ~ hz_lab, switch = "y") +
    scale_fill_distiller(palette = "RdYlBu", direction = -1, na.value = "grey93",
                         trans = "log2", breaks = brks, labels = paste0(brks, "x"),
                         name = "Hazard relative to 2024") +
    coord_sf(xlim = c(72, 136), ylim = c(2.5, 54), expand = TRUE) +
    labs(title = title, subtitle = sub,
         caption = paste0("Relative to the 2024 baseline (log2 colour scale). Base map: GS(2019)1822 ",
                          "national boundary and South China Sea nine-dash line.\n",
                          "Effort is extrapolated well beyond the observed range by 2080 ",
                          "(+1.7 SD under SSP2-4.5, +3.4 SD under SSP5-8.5); late-century values ",
                          "should be read as scenario illustrations, not forecasts.")) +
    theme_map()
}

pm1 <- map_panel(prov_proj, "mech_ratio",
  "Mechanistic projection of new-record hazard",
  "Discrete-time cloglog model; CMIP6 4-GCM ensemble delta applied to both province and species-range climate; SSP-differentiated effort growth")
save_all(pm1, "FigM1_future_mechanistic", 9.0, 7.2, prov_proj)

pm2 <- map_panel(prov_proj, "ml_ratio",
  "Machine-learning projection of new-record hazard",
  "XGBoost on the same three predictors; identical future covariates")
save_all(pm2, "FigM2_future_ml", 9.0, 7.2, prov_proj)

# ---- 4. SHAP 可解释性 / TreeSHAP interpretability ----
sh <- predict(bst, as.matrix(d[, ..FEATS]), predcontrib = TRUE)
sh <- as.data.table(sh); setnames(sh, c(FEATS, "BIAS"))
imp <- data.table(feature = FEATS,
                  mean_abs_shap = vapply(FEATS, function(f) mean(abs(sh[[f]])), 0))
imp[, pct := round(100 * mean_abs_shap / sum(mean_abs_shap), 1)]
FEAT_LAB <- c(clim_change_z = "Climate change (15-yr)",
              clim_var_z = "Annual climate variability", effort_z = "Survey effort")
imp[, lab := FEAT_LAB[feature]]
fwrite(imp, file.path(TAB, "tbl_H_shap_importance.csv"))
log("SHAP 重要性: ", paste(sprintf("%s %.1f%%", imp$lab, imp$pct), collapse = " | "))

p3a <- ggplot(imp, aes(reorder(lab, pct), pct, fill = lab)) +
  geom_col(width = 0.6) +
  geom_text(aes(label = sprintf("%.1f%%", pct)), hjust = -0.15, size = 2.8, colour = "grey20") +
  coord_flip() +
  scale_fill_manual(values = unname(OI[c("red", "blue", "green")]), guide = "none") +
  scale_y_continuous(expand = expansion(mult = c(0, 0.16))) +
  labs(x = NULL, y = "Mean |SHAP| (% of total)",
       subtitle = "Global feature importance (exact TreeSHAP)") +
  theme_pub()

set.seed(1); idx <- sample(nrow(d), min(20000, nrow(d)))
dep <- data.table(cc = d$clim_change_z[idx], shap = sh$clim_change_z[idx],
                  ef = d$effort_z[idx])
p3b <- ggplot(dep, aes(cc, shap, colour = ef)) +
  geom_hline(yintercept = 0, linetype = 2, linewidth = 0.3, colour = "grey50") +
  geom_point(size = 0.35, alpha = 0.45) +
  geom_smooth(method = "gam", formula = y ~ s(x, bs = "cs"), se = FALSE,
              colour = "grey15", linewidth = 0.6) +
  scale_colour_viridis_c(option = "viridis", name = "Survey\neffort (SD)") +
  labs(x = "Accumulated climate change (SD)", y = "SHAP value (log-odds)",
       subtitle = "Dependence: climate contribution rises, and is modulated by effort") +
  theme_pub()
if (has_pw) {
  p3 <- (p3a | p3b) + plot_layout(widths = c(0.8, 1.2)) +
    plot_annotation(tag_levels = "a",
      title = "Interpretable machine learning: exact TreeSHAP attribution")
  save_all(p3, "FigM3_shap_interpretability", 9.4, 3.8, imp)
}

# ---- 5. 机制 vs ML 一致性 / agreement ----
ag <- dcast(prov_proj, province + ssp + horizon ~ ., value.var = c("mech", "ml"))
ag <- prov_proj[, .(province, ssp, horizon, mech, ml)]
ag[, ssp_lab := factor(ssp, levels = c("ssp245", "ssp585"), labels = c("SSP2-4.5", "SSP5-8.5"))]
rr <- ag[, .(r = cor(mech, ml, use = "complete.obs")), by = .(ssp_lab, horizon)]
p4a <- ggplot(ag, aes(mech, ml, colour = factor(horizon))) +
  geom_abline(slope = 1, intercept = 0, linetype = 2, linewidth = 0.35, colour = "grey45") +
  geom_point(size = 1.1, alpha = 0.8) +
  facet_wrap(~ ssp_lab) +
  scale_colour_manual(values = unname(OI[c("sky", "orange", "red")]), name = "Horizon") +
  labs(x = "Mechanistic hazard (%)", y = "Machine-learning hazard (%)",
       subtitle = sprintf("Province-level agreement (Pearson r = %.2f-%.2f)",
                          min(rr$r), max(rr$r))) +
  theme_pub()
dv <- ag[horizon == 2080L & ssp == "ssp585"]
dv[, diff := mech - ml]
mpd <- merge(pv, dv[, .(province, diff)], by = "province", all.x = TRUE)
p4b <- ggplot() +
  geom_sf(data = mpd, aes(fill = diff), colour = "grey40", linewidth = 0.12) +
  { if (!is.null(outline)) geom_sf(data = outline, fill = NA, colour = "grey15", linewidth = 0.3) } +
  { if (!is.null(nanhai))  geom_sf(data = nanhai,  fill = NA, colour = "grey15", linewidth = 0.4) } +
  scale_fill_gradient2(low = OI[["blue"]], mid = "grey96", high = OI[["red"]], midpoint = 0,
                       na.value = "grey93", name = "Mechanistic - ML (%)") +
  coord_sf(xlim = c(72, 136), ylim = c(2.5, 54), expand = TRUE) +
  labs(subtitle = "Where the two models disagree (SSP5-8.5, 2080)") +
  theme_map()
if (has_pw) {
  p4 <- (p4a / p4b) + plot_layout(heights = c(0.85, 1.15)) +
    plot_annotation(tag_levels = "a",
      title = "Mechanistic and machine-learning projections agree on the spatial pattern")
  save_all(p4, "FigM4_mech_vs_ml_agreement", 8.4, 8.0, ag)
}
log("DONE")
