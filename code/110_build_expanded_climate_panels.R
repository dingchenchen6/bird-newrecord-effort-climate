#!/usr/bin/env Rscript
# ============================================================
# Script 110: 构建扩展气候指标面板 (WorldClim 10' CRU-TS 降尺度)
# Build expanded climate indicator panels at 10 arc-minutes
# ============================================================
# Scientific question / 科学问题:
#   年均温异常找不到气候信号, 但季节分解显示冬夏方向相反。
#   需要一套【机制上更贴近鸟类分布限制】的指标, 尤其是越冬冷限
#   (最冷月最低温), 以及此前完全缺失的降水维度。
#   Annual mean temperature hides opposing seasonal signals; build a
#   mechanistically motivated indicator set including cold limits and precipitation.
#
# 重要背景更正 / Important correction:
#   模型中的 394 个物种均为【在华有历史分布区】的种; 无中国分布区的 69 个
#   迷鸟已被排除。因此这些新纪录是【分布扩张 / 新发现种群】, 不是迷鸟事件。
#   "寒潮驱动迷鸟"不能作为冬季负交互的解释, 机制待定。
#
# 数据源 / Data (WorldClim 2.1, 10 arc-min, CRU-TS 4.09 降尺度):
#   historical_tmin  月值 1980-2024 (540 幅)
#   historical_tmax  月值 1980-2024 (540 幅)
#   historical_prec  月值 2000-2024 (300 幅)
#   baseline_prec    WorldClim 1970-2000 月气候态 (12 幅)
#
# 基线口径 / Baselines (显式声明, 不可混用):
#   温度类指标: 1980-2000 (21 年, 受历史序列起始年限制)
#   降水类指标: WorldClim 1970-2000 月气候态
#   两者不同, 故温度与降水的异常值不做绝对量级比较, 只在各自尺度内标准化。
#
# 13 个指标 / Indicators (逐年逐格计算, 再减基线得异常):
#   tmin_cold    最冷月最低温        [越冬冷限, 机制上最关键]
#   tmin_winter  冬季(DJF)平均最低温
#   frost_months 月最低温 < 0 的月数 [霜冻频次]
#   tmax_warm    最热月最高温        [热极端]
#   tmax_summer  夏季(JJA)平均最高温
#   tavg_annual  年均温 = mean((tmin+tmax)/2)
#   tavg_winter  冬季均温
#   tavg_summer  夏季均温
#   dtr          日较差 = mean(tmax - tmin)
#   gdd5         生长度日 (base 5C, 月近似)
#   prec_annual  年降水总量
#   prec_winter  冬季降水
#   prec_summer  夏季降水
#
# Output / 输出:
#   analysis_species_specific/data/clim110_grid.csv     (网格 x 年 x 指标)
#   analysis_species_specific/data/clim110_species.csv  (物种分布区 x 年 x 指标)
#   analysis_species_specific/tables/qa_clim110_panels.csv
#
# Main packages / 主要包: terra, sf, exactextractr, data.table
# 运行 / Run: Rscript --no-init-file code/110_build_expanded_climate_panels.R
# ============================================================

suppressPackageStartupMessages({
  library(data.table); library(sf); library(terra); library(arrow)
})
options(warn = 1)
sf::sf_use_s2(FALSE)

V2  <- normalizePath(".", mustWork = TRUE)
RB  <- file.path(V2, "analysis_rebuilt")
OUT <- file.path(V2, "analysis_species_specific")
WC  <- file.path("/Users/dingchenchen/Documents/New project",
                 "bird_new_record_full_risk_100pct_20260724/data_external/worldclim_10m/unzipped")
DYN <- "/Users/dingchenchen/Documents/New project/bird_dynamic_occupancy_analysis"
BOTW <- "/Users/dingchenchen/Documents/NEW DISTRIBUTION RECORDS/BOTW_clean.gpkg"
log <- function(...) cat(sprintf("[110 %s] ", format(Sys.time(), "%H:%M:%S")), ..., "\n")

TBASE_FROM <- 1980L; TBASE_TO <- 2000L      # 温度基线 / temperature baseline
YR_FROM    <- 2002L; YR_TO    <- 2024L      # 分析期
CHINA <- terra::ext(71, 137, 3, 55)
DAYS  <- c(31, 28.25, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)

mfile <- function(var, y, m)
  list.files(file.path(WC, paste0("historical_", var)),
             pattern = sprintf("_%s_%04d-%02d\\.tif$", var, y, m),
             full.names = TRUE, recursive = TRUE)

read_year <- function(var, y) {
  fs <- vapply(1:12, function(m) { f <- mfile(var, y, m); if (length(f)) f[1] else NA_character_ }, "")
  if (anyNA(fs)) return(NULL)
  terra::crop(terra::rast(fs), CHINA)
}

# ---- 1. 逐年指标栅格 / per-year indicator rasters ----
year_indicators <- function(y, want_prec) {
  tn <- read_year("tmin", y); tx <- read_year("tmax", y)
  if (is.null(tn) || is.null(tx)) return(NULL)
  ta <- (tn + tx) / 2
  out <- list(
    tmin_cold    = terra::app(tn, fun = min,  na.rm = TRUE),
    tmin_winter  = terra::mean(tn[[c(1, 2, 12)]], na.rm = TRUE),
    frost_months = terra::app(tn, fun = function(x) sum(x < 0, na.rm = TRUE)),
    tmax_warm    = terra::app(tx, fun = max,  na.rm = TRUE),
    tmax_summer  = terra::mean(tx[[6:8]], na.rm = TRUE),
    tavg_annual  = terra::mean(ta, na.rm = TRUE),
    tavg_winter  = terra::mean(ta[[c(1, 2, 12)]], na.rm = TRUE),
    tavg_summer  = terra::mean(ta[[6:8]], na.rm = TRUE),
    dtr          = terra::mean(tx - tn, na.rm = TRUE),
    gdd5         = terra::app(ta, fun = function(x) sum(pmax(0, x - 5) * 30.4, na.rm = TRUE)))
  if (want_prec) {
    pr <- read_year("prec", y)
    if (!is.null(pr)) {
      out$prec_annual <- terra::app(pr, fun = sum, na.rm = TRUE)
      out$prec_winter <- terra::app(pr[[c(1, 2, 12)]], fun = sum, na.rm = TRUE)
      out$prec_summer <- terra::app(pr[[6:8]], fun = sum, na.rm = TRUE)
    }
  }
  out
}

TEMP_IND <- c("tmin_cold", "tmin_winter", "frost_months", "tmax_warm", "tmax_summer",
              "tavg_annual", "tavg_winter", "tavg_summer", "dtr", "gdd5")
PREC_IND <- c("prec_annual", "prec_winter", "prec_summer")

cache <- file.path(OUT, "data", "_clim110_stacks.rds")
if (!file.exists(cache)) {
  years <- TBASE_FROM:YR_TO
  acc <- setNames(vector("list", length(TEMP_IND) + length(PREC_IND)),
                  c(TEMP_IND, PREC_IND))
  for (y in years) {
    ind <- year_indicators(y, want_prec = y >= 2000L)
    if (is.null(ind)) { log("  跳过 ", y, " (缺月份)"); next }
    for (nm in names(ind)) acc[[nm]][[as.character(y)]] <- ind[[nm]]
    if (y %% 10 == 0 || y == max(years)) log("  逐年指标 ", y, " 完成")
  }
  stacks <- lapply(acc, function(l) { l <- l[!vapply(l, is.null, TRUE)]
    if (!length(l)) return(NULL); s <- terra::rast(l); names(s) <- names(l); s })
  stacks <- stacks[!vapply(stacks, is.null, TRUE)]
  terra::writeRaster(terra::rast(lapply(names(stacks), function(n) {
    s <- stacks[[n]]; names(s) <- paste0(n, "|", names(s)); s })),
    file.path(OUT, "data", "_clim110_stacks.tif"), overwrite = TRUE)
  saveRDS(names(stacks), cache)
  log("栅格堆叠已缓存: ", length(stacks), " 个指标")
} else log("复用缓存栅格堆叠")

allstk <- terra::rast(file.path(OUT, "data", "_clim110_stacks.tif"))
key <- tstrsplit(names(allstk), "\\|")
ind_of <- key[[1]]; yr_of <- as.integer(key[[2]])
log("堆叠层数 ", nlyr(allstk), " | 指标 ", length(unique(ind_of)))

# ---- 2. 基线 / baselines ----
# 降水基线用 WorldClim 1970-2000 月气候态 / precipitation baseline from WorldClim
bp <- list.files(file.path(WC, "baseline_prec"), pattern = "\\.tif$",
                 full.names = TRUE, recursive = TRUE)
bp <- bp[order(basename(bp))]
bpr <- terra::crop(terra::rast(bp), CHINA)
PBASE <- list(prec_annual = terra::app(bpr, fun = sum, na.rm = TRUE),
              prec_winter = terra::app(bpr[[c(1, 2, 12)]], fun = sum, na.rm = TRUE),
              prec_summer = terra::app(bpr[[6:8]], fun = sum, na.rm = TRUE))
log("降水基线(WorldClim 1970-2000)构建完成")

# ---- 3. 提取 / extraction over grids and species ranges ----
grid <- st_make_valid(st_transform(readRDS(file.path(DYN, "data/derived_v2/china_grid_100km_v2.rds")), 4326))
g2p  <- fread(file.path(RB, "data", "grid_province_lookup.csv"), encoding = "UTF-8")
grid <- grid[grid$grid_cell %in% g2p$grid_cell, ]
d0   <- as.data.table(read_parquet(file.path(OUT, "data", "model_thr50.parquet")))
rng  <- st_make_valid(st_read(BOTW, quiet = TRUE)); names(rng)[names(rng) == "sci_name"] <- "species"
rng  <- rng[rng$species %in% unique(d0$species), ]
log("提取目标: 网格 ", nrow(grid), " | 物种分布区 ", nrow(rng))

extract_all <- function(sfobj, idcol, ids) {
  res <- list()
  for (nm in unique(ind_of)) {
    sel <- which(ind_of == nm)
    s <- allstk[[sel]]; ys <- yr_of[sel]; names(s) <- as.character(ys)
    # 基线 / baseline
    if (nm %in% PREC_IND) {
      bl <- PBASE[[nm]]
    } else {
      bsel <- which(ys >= TBASE_FROM & ys <= TBASE_TO)
      bl <- terra::mean(s[[bsel]], na.rm = TRUE)
    }
    bsel <- which(ys >= TBASE_FROM & ys <= TBASE_TO)
    bsd <- terra::stdev(s[[bsel]], na.rm = TRUE)
    ysel <- which(ys >= YR_FROM & ys <= YR_TO)
    tg <- c(bl, bsd, s[[ysel]])
    names(tg) <- c("baseline", "base_sd", as.character(ys[ysel]))
    m <- as.data.table(exactextractr::exact_extract(tg, sfobj, "mean", progress = FALSE))
    setnames(m, sub("^mean\\.", "", names(m)))
    m[[idcol]] <- ids
    lg <- melt(m, id.vars = c(idcol, "baseline", "base_sd"),
               variable.name = "year", value.name = "val")
    lg[, year := as.integer(as.character(year))]
    lg <- lg[is.finite(year)]
    lg[, anom := val - baseline]
    lg[, indicator := nm]
    res[[nm]] <- lg
    log("  提取 ", nm, " 完成 (", nrow(lg), " 行)")
  }
  rbindlist(res)
}

gf <- file.path(OUT, "data", "clim110_grid.csv")
sf_ <- file.path(OUT, "data", "clim110_species.csv")
if (!file.exists(gf)) {
  gp <- extract_all(grid, "grid_cell", grid$grid_cell)
  fwrite(gp, gf); log("wrote clim110_grid.csv: ", nrow(gp), " 行")
} else { gp <- fread(gf); log("复用 clim110_grid.csv") }
if (!file.exists(sf_)) {
  spp <- extract_all(rng, "species", rng$species)
  fwrite(spp, sf_); log("wrote clim110_species.csv: ", nrow(spp), " 行")
} else { spp <- fread(sf_); log("复用 clim110_species.csv") }

qa <- rbindlist(list(
  gp[, .(panel = "grid", n = .N, n_unit = uniqueN(grid_cell),
         miss_pct = round(100 * mean(!is.finite(anom)), 2),
         anom_sd = round(stats::sd(anom, na.rm = TRUE), 3)), by = indicator],
  spp[, .(panel = "species", n = .N, n_unit = uniqueN(species),
          miss_pct = round(100 * mean(!is.finite(anom)), 2),
          anom_sd = round(stats::sd(anom, na.rm = TRUE), 3)), by = indicator]))
print(qa)
fwrite(qa, file.path(OUT, "tables", "qa_clim110_panels.csv"))
log("wrote qa_clim110_panels.csv")
log("DONE")
