#!/usr/bin/env Rscript
# ============================================================
# Script 88: 构建 物种 × 年 历史分布区温度异常 完整面板
# Build the complete species-by-year native-range temperature anomaly panel
# ============================================================
# Scientific question / 科学问题:
#   模型的气候项应为物种特异的
#       temp_anom_grad(species, province, year)
#         = temp_anom(province, year) - temp_native_anom(species, year)
#   但现有 species_year_native_climate.csv 只有 720 行(事件索引, 覆盖风险集 7.3%),
#   因为原脚本只在"新纪录发表当年"提取历史分布区气候。
#   本脚本把【同一方法】扩展到 2002-2024 每一年, 得到完整面板。
#
# Objective / 分析目标:
#   逐物种取其【中国历史分布区】多边形, 叠 CRU TS 4.09 年均温,
#   以 1970-2000 为基线, 求每年异常 => species × year 完整面板。
#
# 口径 / Definition (与 compute_bird_range_climate_shift_metrics.R 一致):
#   baseline(sp)            = mean_{1970..2000} annual_mean_temp over range(sp)
#   annual(sp, t)           = annual_mean_temp in year t over range(sp)
#   temp_native_anom(sp, t) = annual(sp, t) - baseline(sp)
#
# 范围决策 / Scope (用户 2026-07-25 指示):
#   **排除迷鸟** —— BOTW 中无中国分布区的 69 个物种(Anser/Branta/Arenaria/Anous 等),
#   其"中国历史分布区异常"在定义上不存在, 不做替代估计, 直接剔除。
#   Vagrants without a Chinese historical range are excluded, not imputed.
#
# Input data / 输入数据:
#   CFG$BOTW  (BirdLife range polygons clipped to China; see config.R)
#     (466 种, sci_name, MULTIPOLYGON, 已裁到中国)
#   <dyn>/data/external/cru_ts/cru_ts4.09.1901.2024.tmp.dat.nc
#   SDM derived_inputs/species_year_native_climate.csv  (720 行, 仅用于校验)
#
# Workflow / 主要流程:
#   1. 读 BOTW 分布区; 与风险集物种取交集
#   2. CRU 月值 -> 1970-2024 逐年年均温栅格(裁到中国范围)
#   3. 基线 = 1970-2000 年均温的多年平均
#   4. exact_extract 逐种提取基线与 2002-2024 各年值
#   5. 求异常; 与现有 720 行权威值校验相关性
#
# Expected output / 预期输出:
#   analysis_rebuilt/data/species_native_anom_panel.csv
#   analysis_rebuilt/tables/qa_species_native_anom.csv
#
# Key assumptions / 关键假设:
#   - CRU 0.5 度对小分布区物种可能只覆盖少数格; 记录 n_cells 以便过滤
#   - 本重建用 CRU, 而权威 720 行用 WorldClim, 故校验看【相关性与斜率】,
#     不要求数值相等(基线期同为 1970-2000, 但源与分辨率不同)
#
# Main packages / 主要包: terra, sf, exactextractr, data.table
# Output directory / 输出路径: analysis_rebuilt/
# 运行 / Run: Rscript --no-init-file code/88_build_species_native_anom_panel.R
# ============================================================

suppressPackageStartupMessages({
  library(data.table); library(sf); library(terra); library(arrow)
})
options(warn = 1)

# External archive paths come from config.R at the repository root; edit that file (or set
# the corresponding environment variables) to point at your own copies.
if (file.exists("config.R")) source("config.R") else
  stop("config.R not found. Run this script from the repository root.")

sf::sf_use_s2(FALSE)

V2  <- normalizePath(".", mustWork = TRUE)
SDM <- normalizePath(file.path(V2, "..", "bird_new_record_hazard_model"), mustWork = TRUE)
OUT <- file.path(V2, "analysis_rebuilt")
BOTW <- path.expand(CFG$BOTW)
CRU  <- path.expand(CFG$CRU_TMP)
log <- function(...) cat(sprintf("[88 %s] ", format(Sys.time(), "%H:%M:%S")), ..., "\n")

BASE_FROM <- 1970L; BASE_TO <- 2000L      # 基线期 / baseline period
YR_FROM   <- 2002L; YR_TO   <- 2024L      # 分析期 / analysis window
CHINA_EXT <- terra::ext(71, 137, 3, 55)

# ---- 1. 分布区 / ranges ----
rng <- st_read(BOTW, quiet = TRUE)
rng <- st_make_valid(rng)
names(rng)[names(rng) == "sci_name"] <- "species"
rs  <- as.data.table(read_parquet(file.path(OUT, "data", "riskset_corrected_thr50.parquet")))
rs_sp <- unique(rs$species)
keep  <- intersect(rs_sp, unique(rng$species))
vagrant <- setdiff(rs_sp, unique(rng$species))
log("风险集物种 ", length(rs_sp), " | BOTW 有中国分布区 ", length(keep),
    " | 迷鸟(无中国分布区, 已排除) ", length(vagrant))
rng <- rng[rng$species %in% keep, ]
rng <- rng[!st_is_empty(st_geometry(rng)), ]
log("用于提取的分布区: ", nrow(rng), " 个")

# ---- 2. CRU -> 逐年年均温栅格 / annual mean temperature rasters ----
r  <- tryCatch(rast(CRU, subds = "tmp"), error = function(e) rast(CRU))
nl <- nlyr(r)
idx <- function(y, m) (y - 1901L) * 12L + m       # CRU 自 1901-01 起
log("CRU layers = ", nl)

years_all <- BASE_FROM:YR_TO
ann <- vector("list", length(years_all))
for (i in seq_along(years_all)) {
  y  <- years_all[i]
  li <- idx(y, 1L):idx(y, 12L); li <- li[li >= 1 & li <= nl]
  if (length(li) < 12L) next
  ann[[i]] <- terra::mean(terra::crop(r[[li]], CHINA_EXT), na.rm = TRUE)
  if (i %% 15 == 0 || i == length(years_all)) log("  年均温栅格 ", y, " (", i, "/", length(years_all), ")")
}
names(ann) <- as.character(years_all)
ann <- ann[!vapply(ann, is.null, TRUE)]
stk <- terra::rast(ann)
names(stk) <- names(ann)
log("年均温栅格堆叠: ", nlyr(stk), " 层 (", min(years_all), "-", max(years_all), ")")

# 基线栅格 = 1970-2000 多年平均 / baseline raster
base_layers <- names(stk)[as.integer(names(stk)) %in% BASE_FROM:BASE_TO]
base_r <- terra::mean(stk[[base_layers]], na.rm = TRUE)
log("基线层数 ", length(base_layers), " (", BASE_FROM, "-", BASE_TO, ")")

# ---- 3. 逐种提取 / zonal extraction per species range ----
use_exact <- requireNamespace("exactextractr", quietly = TRUE)
log("exactextractr = ", use_exact)
yr_layers <- names(stk)[as.integer(names(stk)) %in% YR_FROM:YR_TO]
target <- c(base_r, stk[[yr_layers]])
names(target) <- c("baseline", yr_layers)

if (use_exact) {
  vals <- exactextractr::exact_extract(target, rng, "mean", progress = FALSE)
} else {
  vals <- terra::extract(target, terra::vect(rng), fun = mean, na.rm = TRUE)[, -1]
}
vals <- as.data.table(vals)
setnames(vals, sub("^mean\\.", "", names(vals)))
vals[, species := rng$species]
# 覆盖格数(诊断小分布区) / number of covered cells
ncell_cov <- if (use_exact)
  exactextractr::exact_extract(target[[1]], rng, function(v, cov) sum(cov > 0), progress = FALSE) else NA
vals[, n_cells := as.numeric(ncell_cov)]
log("提取完成: ", nrow(vals), " 种 | 基线缺失 ", sum(!is.finite(vals$baseline)), " 种")

# ---- 4. 转长表求异常 / reshape and compute anomalies ----
pan <- melt(vals, id.vars = c("species", "baseline", "n_cells"),
            variable.name = "year", value.name = "annual_temp")
pan[, year := as.integer(as.character(year))]
pan <- pan[is.finite(year) & year >= YR_FROM & year <= YR_TO]
pan[, temp_native_anom := annual_temp - baseline]
pan <- pan[is.finite(temp_native_anom)]
log("面板: ", format(nrow(pan), big.mark = ","), " 行 | ", uniqueN(pan$species),
    " 种 × ", uniqueN(pan$year), " 年 | 期望 ", uniqueN(pan$species) * length(YR_FROM:YR_TO))
fwrite(pan[, .(species, year, n_cells, baseline, annual_temp, temp_native_anom)],
       file.path(OUT, "data", "species_native_anom_panel.csv"))
log("wrote species_native_anom_panel.csv")

# ---- 5. 与权威 720 行校验 / validate against the authoritative table ----
auth <- fread(file.path(SDM, "results", "combined_threshold_50_test", "derived_inputs",
                        "species_year_native_climate.csv"), encoding = "UTF-8")
v <- merge(auth[, .(species, year, auth_anom = temp_native_anom)],
           pan[, .(species, year, cru_anom = temp_native_anom)],
           by = c("species", "year"))
qa <- data.table(
  n_matched   = nrow(v),
  r_pearson   = if (nrow(v) > 3) cor(v$auth_anom, v$cru_anom, use = "complete.obs") else NA_real_,
  slope       = if (nrow(v) > 3) coef(lm(auth_anom ~ cru_anom, data = v))[2] else NA_real_,
  mean_auth   = mean(v$auth_anom, na.rm = TRUE),
  mean_cru    = mean(v$cru_anom,  na.rm = TRUE),
  sd_auth     = stats::sd(v$auth_anom, na.rm = TRUE),
  sd_cru      = stats::sd(v$cru_anom,  na.rm = TRUE),
  n_species_panel = uniqueN(pan$species),
  n_vagrant_excluded = length(vagrant))
print(qa)
log("校验: n=", qa$n_matched, " r=", round(qa$r_pearson, 3),
    " slope=", round(qa$slope, 3), " (CRU 0.5deg vs WorldClim, 不要求数值相等)")
fwrite(qa, file.path(OUT, "tables", "qa_species_native_anom.csv"))
fwrite(data.table(species = vagrant),
       file.path(OUT, "tables", "list_excluded_vagrants.csv"))
log("wrote qa_species_native_anom.csv + list_excluded_vagrants.csv (", length(vagrant), " 种)")
log("DONE")
