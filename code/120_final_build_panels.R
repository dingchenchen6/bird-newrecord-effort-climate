#!/usr/bin/env Rscript
# ============================================================
# Script 120: 最终流水线 (1/4) —— 全序列气候面板与多窗口分量
# Final pipeline (1/4): full-series climate panels and multi-window components
# ============================================================
# Scientific question / 科学问题:
#   新纪录风险由【调查努力】、【累积气候变化】、【年度气候变异】共同决定,
#   三者需在同一完整风险集上、以只回看的方式度量, 才能各自可识别。
#
# 本脚本目标 / Objective:
#   为 4 个气候指标 × 4 个滑动窗口生成建模分量, 供 121 的全模型矩阵使用。
#   关键修正: 提取【1980-2024 全序列】, 使前推滑动窗使用分析期之前的历史年份,
#   分析期 2002-2024 的行数与事件数不因窗口长度而损失。
#
# 变量定义 / Variable definitions (s=物种, p=省, t=年; 基线 1980-2000)
#   T(p,t)        省内 100km 网格该指标的面积均值 (WorldClim 10' CRU-TS 降尺度)
#   N(s,t)        物种中国历史分布区(BOTW)内网格该指标均值
#   T_base/N_base 各自在 1980-2000 的多年平均
#   x(s,p,t)      = [T(p,t) − T_base(p)] − [N(s,t) − N_base(s)]   物种特异气候梯度
#   b_static(s,p) = T_base(p) − N_base(s)                         历史气候错配(静态)
#   clim_change   = x 在 [t−W+1, t] 的滑动均值                     累积气候变化
#   clim_var      = x(t) − clim_change(t)                          年度气候变异
#
# 气候指标 / Indicators:
#   tavg_annual 年均温 | tavg_winter 冬季均温 | tmax_warm 最热月最高温 | tmin_cold 最冷月最低温
# 滑动窗口 / Windows: 5 / 10 / 15 / 20 年
#
# Input / 输入:
#   analysis_species_specific/data/_clim110_stacks.tif   (13 指标 x 1980-2024 栅格)
#   analysis_rebuilt/data/grid_province_lookup.csv
#   BOTW_clean.gpkg | analysis_species_specific/data/model_thr{50,100,200}.parquet
#
# Output / 输出:
#   analysis_final/data/panel_full_{grid,species}.csv
#   analysis_final/data/components_{indicator}_W{5,10,15,20}.parquet
#   analysis_final/tables/qa_panels.csv
#
# Main packages / 主要包: terra, sf, exactextractr, data.table, arrow
# 运行 / Run: Rscript --no-init-file code/120_final_build_panels.R
# ============================================================

suppressPackageStartupMessages({
  library(data.table); library(arrow); library(sf); library(terra)
})
options(warn = 1)
sf::sf_use_s2(FALSE)

V2  <- normalizePath(".", mustWork = TRUE)
RB  <- file.path(V2, "analysis_rebuilt")
SS  <- file.path(V2, "analysis_species_specific")
OUT <- file.path(V2, "analysis_final")
for (d in c("data", "tables", "figures", "logs")) dir.create(file.path(OUT, d), recursive = TRUE, showWarnings = FALSE)
DYN  <- "/Users/dingchenchen/Documents/New project/bird_dynamic_occupancy_analysis"
BOTW <- "/Users/dingchenchen/Documents/NEW DISTRIBUTION RECORDS/BOTW_clean.gpkg"
log <- function(...) cat(sprintf("[120 %s] ", format(Sys.time(), "%H:%M:%S")), ..., "\n")

INDS <- c("tavg_annual", "tavg_winter", "tmax_warm", "tmin_cold")
WINS <- c(5L, 10L, 15L, 20L)
BASE_FROM <- 1980L; BASE_TO <- 2000L; YR_FROM <- 2002L; YR_TO <- 2024L

# ---- 1. 全序列提取 / full-series extraction ----
gf <- file.path(OUT, "data", "panel_full_grid.csv")
sfp <- file.path(OUT, "data", "panel_full_species.csv")
if (!file.exists(gf) || !file.exists(sfp)) {
  allstk <- terra::rast(file.path(SS, "data", "_clim110_stacks.tif"))
  key <- tstrsplit(names(allstk), "\\|"); ind_of <- key[[1]]; yr_of <- as.integer(key[[2]])
  grid <- st_make_valid(st_transform(readRDS(file.path(DYN, "data/derived_v2/china_grid_100km_v2.rds")), 4326))
  g2p  <- fread(file.path(RB, "data", "grid_province_lookup.csv"), encoding = "UTF-8")
  grid <- grid[grid$grid_cell %in% g2p$grid_cell, ]
  d0   <- as.data.table(read_parquet(file.path(SS, "data", "model_thr50.parquet")))
  rng  <- st_make_valid(st_read(BOTW, quiet = TRUE)); names(rng)[names(rng) == "sci_name"] <- "species"
  rng  <- rng[rng$species %in% unique(d0$species), ]
  log("提取目标: 网格 ", nrow(grid), " | 物种分布区 ", nrow(rng), " | 指标 ", length(INDS))

  ex_one <- function(obj, idcol, ids, ind) {
    sel <- which(ind_of == ind); s <- allstk[[sel]]; ys <- yr_of[sel]
    ord <- order(ys); s <- s[[ord]]; ys <- ys[ord]; names(s) <- as.character(ys)
    bl <- terra::mean(s[[which(ys >= BASE_FROM & ys <= BASE_TO)]], na.rm = TRUE)
    tg <- c(bl, s); names(tg) <- c("baseline", as.character(ys))
    m <- as.data.table(exactextractr::exact_extract(tg, obj, "mean", progress = FALSE))
    setnames(m, sub("^mean\\.", "", names(m)))
    m[[idcol]] <- ids
    lg <- melt(m, id.vars = c(idcol, "baseline"), variable.name = "year", value.name = "val")
    lg[, year := as.integer(as.character(year))]
    lg <- lg[is.finite(year)]; lg[, indicator := ind]; lg
  }
  gp <- rbindlist(lapply(INDS, function(i) { r <- ex_one(grid, "grid_cell", grid$grid_cell, i)
                                             log("  网格 ", i, " 完成 (", nrow(r), " 行)"); r }))
  sp <- rbindlist(lapply(INDS, function(i) { r <- ex_one(rng, "species", rng$species, i)
                                             log("  分布区 ", i, " 完成 (", nrow(r), " 行)"); r }))
  fwrite(gp, gf); fwrite(sp, sfp)
  log("wrote panel_full_grid.csv (", nrow(gp), ") / panel_full_species.csv (", nrow(sp), ")")
} else log("复用全序列面板")

gp <- fread(gf); sp <- fread(sfp)
g2p <- fread(file.path(RB, "data", "grid_province_lookup.csv"), encoding = "UTF-8")
gp  <- merge(gp, g2p[, .(grid_cell, province)], by = "grid_cell")
prov <- gp[, .(T_t = mean(val, na.rm = TRUE), T_base = mean(baseline, na.rm = TRUE)),
           by = .(province, year, indicator)]
nat  <- sp[, .(species, year, indicator, N_t = val, N_base = baseline)]
log("省级序列 ", min(prov$year), "-", max(prov$year), " | 指标 ", uniqueN(prov$indicator))

base0 <- as.data.table(read_parquet(file.path(SS, "data", "model_thr50.parquet")))
pairs <- unique(base0[is.finite(eff_visits), .(species, province)])
log("(种,省) 对: ", nrow(pairs))

# ---- 2. 多指标 x 多窗口分量 / components ----
qa <- list()
for (ind in INDS) {
  d <- merge(pairs, prov[indicator == ind, .(province, year, T_t, T_base)],
             by = "province", allow.cartesian = TRUE)
  d <- merge(d, nat[indicator == ind, .(species, year, N_t, N_base)], by = c("species", "year"))
  d[, x := (T_t - T_base) - (N_t - N_base)]
  d[, b_static := T_base - N_base]
  setorder(d, species, province, year)
  for (W in WINS) {
    d[, clim_change := frollmean(x, W, align = "right"), by = .(species, province)]
    d[, clim_var := x - clim_change]
    out <- d[year >= YR_FROM & year <= YR_TO,
             .(species, province, year, x, b_static, clim_change, clim_var)]
    write_parquet(out, file.path(OUT, "data", sprintf("components_%s_W%d.parquet", ind, W)))
    qa[[paste(ind, W)]] <- data.table(indicator = ind, window = W, rows = nrow(out),
      miss_change = sum(!is.finite(out$clim_change)),
      sd_static = stats::sd(out$b_static), sd_change = stats::sd(out$clim_change, na.rm = TRUE),
      sd_var = stats::sd(out$clim_var, na.rm = TRUE),
      cor_static_change = cor(out$b_static, out$clim_change, use = "complete.obs"),
      cor_change_var = cor(out$clim_change, out$clim_var, use = "complete.obs"))
    log(sprintf("  %-12s W=%2d 行=%s 缺失=%d | SD 静态=%.3f 变化=%.3f 变异=%.3f | cor(变化,变异)=%.3f",
        ind, W, format(nrow(out), big.mark = ","), qa[[paste(ind, W)]]$miss_change,
        qa[[paste(ind, W)]]$sd_static, qa[[paste(ind, W)]]$sd_change,
        qa[[paste(ind, W)]]$sd_var, qa[[paste(ind, W)]]$cor_change_var))
  }
}
st <- rbindlist(qa); fwrite(st, file.path(OUT, "tables", "qa_panels.csv"))
log("wrote qa_panels.csv | DONE")
