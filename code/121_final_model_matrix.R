#!/usr/bin/env Rscript
# ============================================================
# Script 121: 最终流水线 (2/4) —— 全模型矩阵与相对重要性
# Final pipeline (2/4): full model matrix and relative importance
# ============================================================
# 科学问题与假设 / Scientific question and hypotheses:
#   H1 调查努力是新纪录被发现的主导条件        -> effort_z
#   H2 累积气候变化独立提高新纪录风险          -> clim_change_z
#   H3 气候作用的强度随调查努力而变            -> clim_change_z : effort_z
#   H4 年度气候变异是独立于长期趋势的另一通道  -> clim_var_z (+ 交互)
#
# 主模型 / Main model (b_static 已按用户意见去掉):
#   event ~ clim_change_z * effort_z + clim_var_z * effort_z
#           + (1|species) + (1|province),  family = binomial("cloglog")
#
# 矩阵设计 / Matrix (分层, 避免 240 次全组合的算力浪费):
#   A 指标 x 窗口 (thr50, 努力=visits)      4 x 4 = 16
#   B 努力代理    (thr50, 最优指标/窗口)     5
#   C 阈值        (最优指标/窗口, visits)    3
#   D 模型阶梯    (最优规格, 3 阈值)         7 x 3
#   E 相对重要性  (偏差分解, 3 阈值)
#
# Input / 输入:
#   analysis_final/data/components_{indicator}_W{5,10,15,20}.parquet  (script 120)
#   analysis_species_specific/data/model_thr{50,100,200}.parquet
#
# Output / 输出:
#   analysis_final/tables/tbl_A_indicator_window.csv
#   analysis_final/tables/tbl_B_effort_proxy.csv
#   analysis_final/tables/tbl_C_threshold.csv
#   analysis_final/tables/tbl_D_ladder.csv
#   analysis_final/tables/tbl_E_importance.csv
#
# Key assumptions / 关键假设:
#   - 所有 z 在各自建模集内标准化(含 event=0 与 event=1 全部行)
#   - 头条努力代理为 visits (用户指定)
#   - 相对重要性用偏差解释率, 不用 marginal R2(后者在本项目无持久化先例)
#
# Main packages / 主要包: data.table, arrow, glmmTMB
# 运行 / Run: Rscript --no-init-file code/121_final_model_matrix.R
# ============================================================

suppressPackageStartupMessages({
  library(data.table); library(arrow); library(glmmTMB)
})
options(warn = 1)

V2  <- normalizePath(".", mustWork = TRUE)
SS  <- file.path(V2, "analysis_species_specific")
OUT <- file.path(V2, "analysis_final")
TAB <- file.path(OUT, "tables")
log <- function(...) cat(sprintf("[121 %s] ", format(Sys.time(), "%H:%M:%S")), ..., "\n")
app <- function(dt, f) fwrite(dt, file.path(TAB, f), append = file.exists(file.path(TAB, f)))
donev <- function(f, val) {
  p <- file.path(TAB, f); if (!file.exists(p)) return(FALSE)
  d <- tryCatch(fread(p), error = function(e) NULL)
  !is.null(d) && "run_key" %in% names(d) && val %in% d$run_key
}

INDS <- c("tavg_annual", "tavg_winter", "tmax_warm", "tmin_cold")
WINS <- c(5L, 10L, 15L, 20L)
EFFS <- c("eff_visits", "eff_records", "eff_observers", "eff_days", "eff_pca")
HEAD_EFF <- "eff_visits"                        # 头条努力代理 / headline proxy

MAIN <- paste("event ~ clim_change_z * effort_z + clim_var_z * effort_z",
              "+ (1|species) + (1|province)")

assemble <- function(thr, ind, W, ep) {
  b <- as.data.table(read_parquet(file.path(SS, "data", sprintf("model_thr%d.parquet", thr))))
  cmp <- as.data.table(read_parquet(file.path(OUT, "data",
          sprintf("components_%s_W%d.parquet", ind, W))))
  d <- merge(b, cmp[, .(species, province, year, clim_change, clim_var)],
             by = c("species", "province", "year"))
  d <- d[is.finite(clim_change) & is.finite(clim_var) & is.finite(get(ep))]
  d[, `:=`(clim_change_z = as.numeric(scale(clim_change)),
           clim_var_z    = as.numeric(scale(clim_var)),
           effort_z      = as.numeric(scale(get(ep))))]
  d
}
fitq <- function(f, d) tryCatch(glmmTMB(as.formula(f), d, family = binomial("cloglog")),
                                error = function(e) { log("    FAIL: ", conditionMessage(e)); NULL })
grab <- function(m, term) {
  cf <- fixef(m)$cond; se <- sqrt(diag(vcov(m)$cond))
  i <- which(names(cf) == term)
  if (!length(i)) { ic <- grep(":", names(cf), value = TRUE)
    a <- sub(":.*", "", term); b2 <- sub(".*:", "", term)
    j <- ic[grepl(a, ic, fixed = TRUE) & grepl(b2, ic, fixed = TRUE)]
    if (!length(j)) return(c(NA, NA, NA, NA)); i <- which(names(cf) == j[1]) }
  c(exp(cf[i]), exp(cf[i] - 1.96 * se[i]), exp(cf[i] + 1.96 * se[i]),
    2 * pnorm(-abs(cf[i] / se[i])))
}
row_of <- function(m, m1, extra) {
  g <- function(t) grab(m, t)
  e <- g("effort_z"); cc <- g("clim_change_z"); cv <- g("clim_var_z")
  ic <- g("clim_change_z:effort_z"); iv <- g("clim_var_z:effort_z")
  cbind(extra, data.table(
    effort_hr = e[1], effort_lo = e[2], effort_hi = e[3], effort_p = e[4],
    change_hr = cc[1], change_lo = cc[2], change_hi = cc[3], change_p = cc[4],
    var_hr = cv[1], var_lo = cv[2], var_hi = cv[3], var_p = cv[4],
    int_change_hr = ic[1], int_change_lo = ic[2], int_change_hi = ic[3], int_change_p = ic[4],
    int_var_hr = iv[1], int_var_lo = iv[2], int_var_hi = iv[3], int_var_p = iv[4],
    AIC = AIC(m), dAIC_vs_effort = AIC(m) - AIC(m1)))
}

# ============ A: 指标 x 窗口 (thr50, visits) ============
log("=== A 指标 x 窗口 (thr50, 努力 = visits) ===")
for (ind in INDS) for (W in WINS) {
  key <- paste0(ind, "_W", W)
  if (donev("tbl_A_indicator_window.csv", key)) { log("  跳过 ", key); next }
  d <- assemble(50L, ind, W, HEAD_EFF)
  m <- fitq(MAIN, d); m1 <- fitq("event ~ effort_z + (1|species) + (1|province)", d)
  if (is.null(m) || is.null(m1)) next
  r <- row_of(m, m1, data.table(run_key = key, indicator = ind, window = W,
        threshold = 50L, effort = HEAD_EFF, rows = nrow(d), events = sum(d$event)))
  app(r, "tbl_A_indicator_window.csv")
  log(sprintf("  %-12s W=%2d 努力 %.2f(%.1g) | 变化 %.3f(%.2g) 交互 %.3f(%.2g) | 变异 %.3f(%.2g) | dAIC=%+.1f",
      ind, W, r$effort_hr, r$effort_p, r$change_hr, r$change_p,
      r$int_change_hr, r$int_change_p, r$var_hr, r$var_p, r$dAIC_vs_effort))
}

# 选最优指标/窗口: dAIC 最小 / pick best by dAIC
A <- fread(file.path(TAB, "tbl_A_indicator_window.csv"))
best <- A[which.min(dAIC_vs_effort)]
BEST_IND <- best$indicator; BEST_W <- best$window
log("最优规格: 指标 = ", BEST_IND, " | 窗口 = ", BEST_W, " (dAIC = ", round(best$dAIC_vs_effort, 1), ")")

# ============ B: 努力代理 ============
log("=== B 努力代理 (最优指标/窗口, thr50) ===")
for (ep in EFFS) {
  key <- paste0("eff_", ep)
  if (donev("tbl_B_effort_proxy.csv", key)) { log("  跳过 ", key); next }
  d <- assemble(50L, BEST_IND, BEST_W, ep)
  m <- fitq(MAIN, d); m1 <- fitq("event ~ effort_z + (1|species) + (1|province)", d)
  if (is.null(m) || is.null(m1)) next
  r <- row_of(m, m1, data.table(run_key = key, indicator = BEST_IND, window = BEST_W,
        threshold = 50L, effort = ep, rows = nrow(d), events = sum(d$event)))
  app(r, "tbl_B_effort_proxy.csv")
  log(sprintf("  %-14s 努力 %.2f(%.1g) | 变化 %.3f(%.2g) 交互 %.3f(%.2g) | 变异 %.3f(%.2g) | dAIC=%+.1f",
      ep, r$effort_hr, r$effort_p, r$change_hr, r$change_p,
      r$int_change_hr, r$int_change_p, r$var_hr, r$var_p, r$dAIC_vs_effort))
}

# ============ C: 三档阈值 ============
log("=== C 阈值稳健性 (最优规格, visits) ===")
for (thr in c(50L, 100L, 200L)) {
  key <- paste0("thr", thr)
  if (donev("tbl_C_threshold.csv", key)) { log("  跳过 ", key); next }
  d <- assemble(thr, BEST_IND, BEST_W, HEAD_EFF)
  m <- fitq(MAIN, d); m1 <- fitq("event ~ effort_z + (1|species) + (1|province)", d)
  if (is.null(m) || is.null(m1)) next
  r <- row_of(m, m1, data.table(run_key = key, indicator = BEST_IND, window = BEST_W,
        threshold = thr, effort = HEAD_EFF, rows = nrow(d), events = sum(d$event)))
  app(r, "tbl_C_threshold.csv")
  log(sprintf("  thr%-3d 行=%s 事件=%d | 努力 %.2f(%.1g) | 变化 %.3f(%.2g) 交互 %.3f(%.2g) | 变异 %.3f(%.2g) | dAIC=%+.1f",
      thr, format(r$rows, big.mark = ","), r$events, r$effort_hr, r$effort_p,
      r$change_hr, r$change_p, r$int_change_hr, r$int_change_p, r$var_hr, r$var_p, r$dAIC_vs_effort))
}

# ============ D: 模型阶梯 ============
log("=== D 模型阶梯 (最优规格, 3 阈值) ===")
LADDER <- c(
  N0_null     = "event ~ 1 + (1|species) + (1|province)",
  N1_effort   = "event ~ effort_z + (1|species) + (1|province)",
  N2_climate  = "event ~ clim_change_z + clim_var_z + (1|species) + (1|province)",
  N3_additive = "event ~ clim_change_z + clim_var_z + effort_z + (1|species) + (1|province)",
  N4_intChange= "event ~ clim_change_z * effort_z + clim_var_z + (1|species) + (1|province)",
  N5_intBoth  = "event ~ clim_change_z * effort_z + clim_var_z * effort_z + (1|species) + (1|province)",
  N6_static   = "event ~ b_static_z + clim_change_z * effort_z + clim_var_z * effort_z + (1|species) + (1|province)")
for (thr in c(50L, 100L, 200L)) {
  key <- paste0("ladder_thr", thr)
  if (donev("tbl_D_ladder.csv", key)) { log("  跳过 ", key); next }
  d <- assemble(thr, BEST_IND, BEST_W, HEAD_EFF)
  cmp <- as.data.table(read_parquet(file.path(OUT, "data",
          sprintf("components_%s_W%d.parquet", BEST_IND, BEST_W))))
  d <- merge(d, unique(cmp[, .(species, province, b_static)]), by = c("species", "province"))
  d[, b_static_z := as.numeric(scale(b_static))]
  rows <- list()
  for (nm in names(LADDER)) {
    m <- fitq(LADDER[[nm]], d); if (is.null(m)) next
    rows[[nm]] <- data.table(run_key = key, threshold = thr, model = nm,
      formula = LADDER[[nm]], AIC = AIC(m), df = attr(logLik(m), "df"),
      logLik = as.numeric(logLik(m)), nobs = nobs(m), events = sum(d$event))
    log(sprintf("  thr%d %-12s AIC=%.1f", thr, nm, AIC(m)))
  }
  r <- rbindlist(rows, fill = TRUE); r[, dAIC := AIC - min(AIC)]
  app(r, "tbl_D_ladder.csv")
}

# ============ E: 相对重要性 (偏差分解) ============
log("=== E 相对重要性 ===")
for (thr in c(50L, 100L, 200L)) {
  key <- paste0("imp_thr", thr)
  if (donev("tbl_E_importance.csv", key)) { log("  跳过 ", key); next }
  d <- assemble(thr, BEST_IND, BEST_W, HEAD_EFF)
  f <- list(
    null   = "event ~ 1 + (1|species) + (1|province)",
    full   = MAIN,
    no_eff = "event ~ clim_change_z + clim_var_z + (1|species) + (1|province)",
    no_cc  = "event ~ clim_var_z * effort_z + (1|species) + (1|province)",
    no_cv  = "event ~ clim_change_z * effort_z + (1|species) + (1|province)",
    no_int = "event ~ clim_change_z + clim_var_z + effort_z + (1|species) + (1|province)")
  ms <- lapply(f, fitq, d = d)
  if (any(vapply(ms, is.null, TRUE))) { log("  thr", thr, " 有拟合失败"); next }
  dev <- vapply(ms, function(m) -2 * as.numeric(logLik(m)), 0)
  tot <- dev[["null"]] - dev[["full"]]
  r <- data.table(run_key = key, threshold = thr, rows = nobs(ms$full), events = sum(d$event),
    dev_explained_total = tot,
    pct_effort = round(100 * (dev[["no_eff"]] - dev[["full"]]) / tot, 1),
    pct_clim_change = round(100 * (dev[["no_cc"]] - dev[["full"]]) / tot, 1),
    pct_clim_var = round(100 * (dev[["no_cv"]] - dev[["full"]]) / tot, 1),
    pct_interactions = round(100 * (dev[["no_int"]] - dev[["full"]]) / tot, 1))
  app(r, "tbl_E_importance.csv"); print(r)
}
log("DONE  最优规格: ", BEST_IND, " W=", BEST_W)
