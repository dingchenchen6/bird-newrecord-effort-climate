#!/usr/bin/env Rscript
# ============================================================
# Script 127: 气候速度与气候新颖度作为累积变暖的替代算子
# Climate velocity and climate novelty as alternative warming operators
# ============================================================
# 科学问题 / Scientific question:
#   头条模型用【前推 15 年滑动均值】度量累积气候变化。分布变化文献中另有两个
#   标准算子: 梯度型气候速度 (Loarie et al. 2009; Burrows et al. 2011) 与
#   气候新颖度 (Williams & Jackson 2007; Mahony et al. 2017)。
#   换用这两个算子后, 气候主效应与 climate x effort 交互是否复现?
#
# 【方法学说明: 为何不直接用 climetrics 的输出】
#   climetrics::gVelocity 在经纬度(WGS84)栅格上返回的值中位数为 2.5e-4,
#   而按文献公式(纬度校正的 degC/km 空间梯度)计算得到 2.11 km/yr;
#   两者相差约 4 个数量级, 且相关仅 r = 0.494 —— 纯单位换算应给出 r = 1,
#   故差异是结构性的(该实现未做纬度校正, 空间梯度以"度"为单位)。
#   本机 PROJ 数据库在 Rscript --no-init-file 下不可用, 无法重投影到米制
#   坐标系复核。因此本脚本按原始文献公式自行实现并显式标注单位, 不使用
#   climetrics 的数值输出; climetrics 仅作为概念参照记录于此。
#
# 算子定义 / Operator definitions (基线 1980-2000, 滑动窗 W=15, 只回看)
#   gvel(u,t)  = trend_T(u,t) / |grad_T(u)|              [km/yr]
#       trend_T = 单元 u 在 [t-W+1, t] 上年均温的 OLS 斜率 (degC/yr)
#       |grad_T| = 基线期平均温度场的空间梯度模, 中心差分 + 纬度校正 (degC/km)
#   novel(u,t) = |mean_T(u,[t-W+1,t]) - mean_T(u,base)| / sd_T(u,base)   [基线 SD]
#       标准化局地异常 / standardized local anomaly (sigma dissimilarity 概念)
#
# 两种用法 / Two usages:
#   (A) 省级算子     —— 与文献一致, 气候速度是地点属性, 不随物种变化
#   (B) 物种特异算子 —— 省级值 − 该物种中国分布区值, 与头条 clim_change 同构
#
# 检验模型 / Test model (与头条同结构, 便于直接对比):
#   event ~ op_z * effort_z + clim_var_z + (1|species) + (1|province), cloglog
#
# Input / 输入:  analysis_species_specific/data/_clim110_stacks.tif (tavg_annual 1980-2024)
#                analysis_final/data/components_tavg_annual_W15.parquet (clim_var)
#                analysis_species_specific/data/model_thr{50,100,200}.parquet
# Output / 输出: analysis_final/data/operators_velocity_novelty.csv
#                analysis_final/tables/tbl_I_velocity_novelty.csv
#
# Main packages / 主要包: terra, sf, exactextractr, data.table, glmmTMB
# 运行 / Run: Rscript --no-init-file code/127_velocity_novelty_operators.R
# ============================================================

suppressPackageStartupMessages({
  library(data.table); library(arrow); library(terra); library(sf); library(glmmTMB)
})
options(warn = 1); sf::sf_use_s2(FALSE)

V2  <- normalizePath(".", mustWork = TRUE)
RB  <- file.path(V2, "analysis_rebuilt")
SS  <- file.path(V2, "analysis_species_specific")
OUT <- file.path(V2, "analysis_final")
TAB <- file.path(OUT, "tables")
DYN <- "/Users/dingchenchen/Documents/New project/bird_dynamic_occupancy_analysis"
BOTW <- "/Users/dingchenchen/Documents/NEW DISTRIBUTION RECORDS/BOTW_clean.gpkg"
log <- function(...) cat(sprintf("[127 %s] ", format(Sys.time(), "%H:%M:%S")), ..., "\n")

W <- 15L; BASE_FROM <- 1980L; BASE_TO <- 2000L; YR_FROM <- 2002L; YR_TO <- 2024L

# ---- 1. 年均温栈 / annual mean temperature stack ----
stk <- rast(file.path(SS, "data", "_clim110_stacks.tif"))
kk  <- tstrsplit(names(stk), "\\|"); ind <- kk[[1]]; yr <- as.integer(kk[[2]])
sel <- which(ind == "tavg_annual"); s <- stk[[sel]]; ys <- yr[sel]
o <- order(ys); s <- s[[o]]; ys <- ys[o]
log("年均温栈 ", nlyr(s), " 层 (", min(ys), "-", max(ys), ")")

# ---- 2. 基线场: 平均、年际 SD、空间梯度 ----
bsel   <- which(ys >= BASE_FROM & ys <= BASE_TO)
base_m <- terra::mean(s[[bsel]], na.rm = TRUE)
base_sd<- terra::stdev(s[[bsel]], na.rm = TRUE)
# 空间梯度: 中心差分 + 纬度校正 -> degC/km
xr <- xres(base_m); yr2 <- yres(base_m); lat <- init(base_m, "y")
dx_km <- 111.32 * xr * cos(lat * pi / 180); dy_km <- 110.57 * yr2
gx <- focal(base_m, w = matrix(c(0,0,0,-.5,0,.5,0,0,0), 3, 3, byrow = TRUE), fun = sum, na.rm = TRUE) / dx_km
gy <- focal(base_m, w = matrix(c(0,-.5,0,0,0,0,0,.5,0), 3, 3, byrow = TRUE), fun = sum, na.rm = TRUE) / dy_km
grad <- sqrt(gx^2 + gy^2)
grad <- terra::clamp(grad, lower = 1e-4)      # 避免极平坦地区速度爆炸 / floor to avoid blow-up
log("空间梯度 degC/km 中位 ", round(median(values(grad), na.rm = TRUE), 4))

# ---- 3. 逐年滑动窗算子栅格 / per-year operator rasters ----
yrs_an <- YR_FROM:YR_TO
vel_l <- nov_l <- vector("list", length(yrs_an))
for (i in seq_along(yrs_an)) {
  t <- yrs_an[i]
  widx <- which(ys >= (t - W + 1L) & ys <= t)
  if (length(widx) < W) { log("  ", t, " 窗口不足, 跳过"); next }
  wst <- s[[widx]]
  # 时间趋势 degC/yr (OLS 斜率的闭式解, 比 app+lm 快)
  n <- length(widx); xi <- seq_len(n); xbar <- mean(xi); Sxx <- sum((xi - xbar)^2)
  ybar <- terra::mean(wst, na.rm = TRUE)
  num <- terra::app(wst * 0, function(z) 0)   # 占位, 逐层累加
  num <- ybar * 0
  for (j in seq_len(n)) num <- num + (xi[j] - xbar) * (wst[[j]] - ybar)
  trend <- num / Sxx
  vel_l[[i]] <- trend / grad                          # km/yr
  nov_l[[i]] <- abs(ybar - base_m) / terra::clamp(base_sd, lower = 1e-3)   # 基线 SD
  if (i %% 6 == 0 || i == length(yrs_an)) log("  算子栅格 ", t, " 完成")
}
keep <- !vapply(vel_l, is.null, TRUE)
vel <- rast(vel_l[keep]); names(vel) <- as.character(yrs_an[keep])
nov <- rast(nov_l[keep]); names(nov) <- as.character(yrs_an[keep])
log("速度 km/yr 分位: ", paste(round(quantile(values(vel), c(.05,.5,.95), na.rm = TRUE), 2), collapse = " / "))
log("新颖度 SD 分位:  ", paste(round(quantile(values(nov), c(.05,.5,.95), na.rm = TRUE), 2), collapse = " / "))

# ---- 4. 提取到省与物种分布区 / extract ----
grid <- st_make_valid(st_transform(readRDS(file.path(DYN, "data/derived_v2/china_grid_100km_v2.rds")), 4326))
g2p  <- fread(file.path(RB, "data", "grid_province_lookup.csv"), encoding = "UTF-8")
grid <- grid[grid$grid_cell %in% g2p$grid_cell, ]
d0   <- as.data.table(read_parquet(file.path(SS, "data", "model_thr50.parquet")))
rng  <- st_make_valid(st_read(BOTW, quiet = TRUE)); names(rng)[names(rng) == "sci_name"] <- "species"
rng  <- rng[rng$species %in% unique(d0$species), ]

ex_long <- function(r, obj, idcol, ids, vname) {
  m <- as.data.table(exactextractr::exact_extract(r, obj, "mean", progress = FALSE))
  setnames(m, sub("^mean\\.", "", names(m))); m[[idcol]] <- ids
  lg <- melt(m, id.vars = idcol, variable.name = "year", value.name = vname)
  lg[, year := as.integer(as.character(year))][is.finite(year)]
}
gv_g <- ex_long(vel, grid, "grid_cell", grid$grid_cell, "gvel")
nv_g <- ex_long(nov, grid, "grid_cell", grid$grid_cell, "novel")
gv_s <- ex_long(vel, rng,  "species",   rng$species,    "gvel")
nv_s <- ex_long(nov, rng,  "species",   rng$species,    "novel")

gp <- merge(merge(gv_g, nv_g, by = c("grid_cell", "year")), g2p[, .(grid_cell, province)], by = "grid_cell")
prov <- gp[, .(gvel_p = mean(gvel, na.rm = TRUE), novel_p = mean(novel, na.rm = TRUE)),
           by = .(province, year)]
spp  <- merge(gv_s, nv_s, by = c("species", "year"))
setnames(spp, c("gvel", "novel"), c("gvel_s", "novel_s"))
log("省级算子 ", nrow(prov), " 行 | 物种算子 ", nrow(spp), " 行")

ops <- CJ(species = unique(d0$species), province = unique(d0$province), year = yrs_an, unique = TRUE)
ops <- merge(ops, prov, by = c("province", "year"))
ops <- merge(ops, spp,  by = c("species", "year"))
ops[, `:=`(gvel_diff = gvel_p - gvel_s, novel_diff = novel_p - novel_s)]
fwrite(ops, file.path(OUT, "data", "operators_velocity_novelty.csv"))
log("wrote operators_velocity_novelty.csv: ", format(nrow(ops), big.mark = ","), " 行")

# ---- 5. 检验 / fit ----
cmp <- as.data.table(read_parquet(file.path(OUT, "data", "components_tavg_annual_W15.parquet")))
fitq <- function(f, d) tryCatch(glmmTMB(as.formula(f), d, family = binomial("cloglog")),
                                error = function(e) { log("   FAIL: ", conditionMessage(e)); NULL })
grab <- function(m, term) {
  cf <- fixef(m)$cond; se <- sqrt(diag(vcov(m)$cond)); i <- which(names(cf) == term)
  if (!length(i)) { ic <- grep(":", names(cf), value = TRUE)
    a <- sub(":.*", "", term); b <- sub(".*:", "", term)
    j <- ic[grepl(a, ic, fixed = TRUE) & grepl(b, ic, fixed = TRUE)]
    if (!length(j)) return(rep(NA_real_, 4)); i <- which(names(cf) == j[1]) }
  c(exp(cf[i]), exp(cf[i] - 1.96*se[i]), exp(cf[i] + 1.96*se[i]), 2*pnorm(-abs(cf[i]/se[i])))
}

OPS <- list(
  velocity_province = "gvel_p",     velocity_speciesdiff = "gvel_diff",
  novelty_province  = "novel_p",    novelty_speciesdiff  = "novel_diff")
res <- list()
for (thr in c(50L, 100L, 200L)) for (nm in names(OPS)) {
  v <- OPS[[nm]]
  b <- as.data.table(read_parquet(file.path(SS, "data", sprintf("model_thr%d.parquet", thr))))
  d <- merge(b, cmp[, .(species, province, year, clim_var)], by = c("species", "province", "year"))
  d <- merge(d, ops[, c("species", "province", "year", v), with = FALSE],
             by = c("species", "province", "year"))
  setnames(d, v, "op")
  d <- d[is.finite(op) & is.finite(clim_var) & is.finite(eff_visits)]
  if (nrow(d) < 5000) { log("  ", nm, " thr", thr, " 行数不足"); next }
  d[, `:=`(op_z = as.numeric(scale(op)), clim_var_z = as.numeric(scale(clim_var)),
           effort_z = as.numeric(scale(eff_visits)))]
  m  <- fitq("event ~ op_z * effort_z + clim_var_z + (1|species) + (1|province)", d)
  m1 <- fitq("event ~ effort_z + (1|species) + (1|province)", d)
  if (is.null(m) || is.null(m1)) next
  a <- grab(m, "op_z"); i <- grab(m, "op_z:effort_z"); e <- grab(m, "effort_z")
  r <- data.table(operator = nm, threshold = thr, rows = nrow(d), events = sum(d$event),
    op_hr = a[1], op_lo = a[2], op_hi = a[3], op_p = a[4],
    int_hr = i[1], int_lo = i[2], int_hi = i[3], int_p = i[4],
    effort_hr = e[1], effort_p = e[4],
    AIC = AIC(m), dAIC_vs_effort = AIC(m) - AIC(m1))
  res[[paste(nm, thr)]] <- r
  log(sprintf("  %-20s thr%-3d 算子 HR=%.3f(P=%.2g) | 交互 %.3f(P=%.2g) | 努力 %.2f | dAIC=%+.1f",
      nm, thr, r$op_hr, r$op_p, r$int_hr, r$int_p, r$effort_hr, r$dAIC_vs_effort))
}
tt <- rbindlist(res, fill = TRUE)
print(tt); fwrite(tt, file.path(TAB, "tbl_I_velocity_novelty.csv"))
log("wrote tbl_I_velocity_novelty.csv | DONE")
