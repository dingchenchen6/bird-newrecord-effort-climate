#!/usr/bin/env Rscript
# ============================================================
# Script 122: 最终流水线 (3/4) —— DHARMa 残差诊断与模型检验
# Final pipeline (3/4): DHARMa residual diagnostics
# ============================================================
# 目的 / Objective:
#   对最终主模型做系统残差诊断, 确认结论不是模型误设的产物。
#
# 最终主模型 / Final model (tavg_annual, W=15, effort = visits, thr50):
#   event ~ clim_change_z * effort_z + clim_var_z
#           + (1|species) + (1|province),  family = binomial("cloglog")
#   模型阶梯(script 121 D 段)显示 N4 优于 N5: 年度气候变异只需主效应,
#   其与努力的交互不改善拟合(thr50 8407.2 vs 8407.6), 故按简约原则去掉。
#
# 诊断项 / Diagnostics:
#   1 均匀性 KS 检验            残差是否服从均匀分布 (模型分布假设)
#   2 离散度检验                是否过离散/欠离散
#   3 离群点检验                极端残差比例是否异常
#   4 残差 vs 各预测因子        是否存在未捕捉的非线性
#   5 分组残差 (省 / 年 / 物种) 随机效应层面是否有系统偏差
#   6 时间自相关 (按年聚合)     Durbin-Watson
#   7 空间自相关 (省级残差)     Moran's I
#
# Input / 输入:
#   analysis_final/data/components_tavg_annual_W15.parquet
#   analysis_species_specific/data/model_thr50.parquet
#   analysis_rebuilt/data/grid_province_lookup.csv (省质心, 供 Moran's I)
#
# Output / 输出:
#   analysis_final/tables/tbl_G_dharma_tests.csv
#   analysis_final/figures/FigS1_dharma_panel.{png,pdf}
#   analysis_final/data/final_model_thr50.rds
#
# Key assumptions / 关键假设:
#   - DHARMa 用 500 次模拟; 事件率 0.36% 属稀有事件, 均匀性检验对
#     稀有二元结局较敏感, 故同时看分组残差与自相关, 不单凭 KS 判定
#
# Main packages / 主要包: glmmTMB, DHARMa, data.table, sf
# 运行 / Run: Rscript --no-init-file code/122_final_diagnostics.R
# ============================================================

suppressPackageStartupMessages({
  library(data.table); library(arrow); library(glmmTMB); library(DHARMa); library(sf)
})
options(warn = 1)
set.seed(42)
sf::sf_use_s2(FALSE)

V2  <- normalizePath(".", mustWork = TRUE)
SS  <- file.path(V2, "analysis_species_specific")
RB  <- file.path(V2, "analysis_rebuilt")
OUT <- file.path(V2, "analysis_final")
TAB <- file.path(OUT, "tables"); FIG <- file.path(OUT, "figures")
SHP <- file.path(V2, "data", "spatial", "basemap_GS2019_1822")
log <- function(...) cat(sprintf("[122 %s] ", format(Sys.time(), "%H:%M:%S")), ..., "\n")

IND <- "tavg_annual"; W <- 15L; EP <- "eff_visits"; THR <- 50L

b <- as.data.table(read_parquet(file.path(SS, "data", sprintf("model_thr%d.parquet", THR))))
cmp <- as.data.table(read_parquet(file.path(OUT, "data",
        sprintf("components_%s_W%d.parquet", IND, W))))
d <- merge(b, cmp[, .(species, province, year, clim_change, clim_var)],
           by = c("species", "province", "year"))
d <- d[is.finite(clim_change) & is.finite(clim_var) & is.finite(get(EP))]
d[, `:=`(clim_change_z = as.numeric(scale(clim_change)),
         clim_var_z    = as.numeric(scale(clim_var)),
         effort_z      = as.numeric(scale(get(EP))))]
log("建模集: ", format(nrow(d), big.mark = ","), " 行 | ", sum(d$event), " 事件 | 事件率 ",
    round(100 * mean(d$event), 3), "%")

FORM <- event ~ clim_change_z * effort_z + clim_var_z + (1|species) + (1|province)
mf <- file.path(OUT, "data", "final_model_thr50.rds")
if (file.exists(mf)) { m <- readRDS(mf); log("复用已保存模型") } else {
  log("拟合最终模型 ...")
  m <- glmmTMB(FORM, d, family = binomial("cloglog"))
  saveRDS(m, mf); log("  已保存 final_model_thr50.rds")
}
print(summary(m)$coefficients$cond)

# ---- DHARMa ----
log("DHARMa 模拟残差 (n=500) ...")
sim <- simulateResiduals(m, n = 500, seed = 42)
res <- list()
u  <- testUniformity(sim, plot = FALSE)
dp <- testDispersion(sim, plot = FALSE)
ol <- testOutliers(sim, plot = FALSE, type = "bootstrap", nBoot = 100)
res$uniformity <- data.table(test = "KS uniformity", statistic = as.numeric(u$statistic),
                             p_value = u$p.value)
res$dispersion <- data.table(test = "dispersion", statistic = as.numeric(dp$statistic),
                             p_value = dp$p.value)
res$outliers   <- data.table(test = "outliers", statistic = as.numeric(ol$statistic),
                             p_value = ol$p.value)
log(sprintf("  均匀性 KS D=%.4f P=%.3g | 离散度 ratio=%.3f P=%.3g | 离群 P=%.3g",
    u$statistic, u$p.value, dp$statistic, dp$p.value, ol$p.value))

# 分组残差 / grouped residuals
for (g in c("province", "year", "species")) {
  gr <- recalculateResiduals(sim, group = d[[g]])
  tu <- testUniformity(gr, plot = FALSE)
  res[[paste0("group_", g)]] <- data.table(test = paste0("grouped uniformity: ", g),
    statistic = as.numeric(tu$statistic), p_value = tu$p.value)
  log(sprintf("  分组残差 %-8s D=%.4f P=%.3g (n=%d 组)", g, tu$statistic, tu$p.value,
              uniqueN(d[[g]])))
}

# 时间自相关 / temporal autocorrelation
gy <- recalculateResiduals(sim, group = d$year)
ty <- testTemporalAutocorrelation(gy, time = sort(unique(d$year)), plot = FALSE)
res$temporal <- data.table(test = "temporal autocorrelation (DW)",
                           statistic = as.numeric(ty$statistic[1]), p_value = ty$p.value)
log(sprintf("  时间自相关 DW=%.3f P=%.3g", ty$statistic[1], ty$p.value))

# 空间自相关 / spatial autocorrelation (province centroids)
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
pv <- pv[!is.na(pv$province), ]
ctr <- suppressWarnings(st_coordinates(st_centroid(st_geometry(pv))))
pc <- data.table(province = pv$province, x = ctr[, 1], y = ctr[, 2])
gp_ <- recalculateResiduals(sim, group = d$province)
pl <- data.table(province = levels(factor(d$province)), r = as.numeric(gp_$scaledResiduals))
pl <- merge(pl, pc, by = "province")
ts <- tryCatch(testSpatialAutocorrelation(
        simulationOutput = gp_, x = pl$x, y = pl$y, plot = FALSE), error = function(e) NULL)
if (!is.null(ts)) {
  res$spatial <- data.table(test = "spatial autocorrelation (Moran I)",
                            statistic = as.numeric(ts$statistic[1]), p_value = ts$p.value)
  log(sprintf("  空间自相关 Moran I=%.4f P=%.3g", ts$statistic[1], ts$p.value))
}
tt <- rbindlist(res, fill = TRUE)
print(tt); fwrite(tt, file.path(TAB, "tbl_G_dharma_tests.csv"))
log("wrote tbl_G_dharma_tests.csv")

# ---- 诊断图 / diagnostic panel ----
for (ext in c("png", "pdf")) {
  f <- file.path(FIG, paste0("FigS1_dharma_panel.", ext))
  if (ext == "png") png(f, width = 2400, height = 1800, res = 200)
  else grDevices::cairo_pdf(f, width = 12, height = 9)
  op <- par(mfrow = c(2, 3), mar = c(4, 4, 3, 1))
  tryCatch(plotQQunif(sim), error = function(e) plot.new())
  tryCatch(plotResiduals(sim, form = d$clim_change_z, xlab = "clim_change_z"), error = function(e) plot.new())
  tryCatch(plotResiduals(sim, form = d$effort_z, xlab = "effort_z"), error = function(e) plot.new())
  tryCatch(plotResiduals(sim, form = d$clim_var_z, xlab = "clim_var_z"), error = function(e) plot.new())
  tryCatch(plotResiduals(sim, form = factor(d$year), xlab = "year"), error = function(e) plot.new())
  tryCatch(plotResiduals(sim, form = factor(d$province), xlab = "province"), error = function(e) plot.new())
  par(op); dev.off()
}
log("wrote FigS1_dharma_panel.{png,pdf}")
log("DONE")
