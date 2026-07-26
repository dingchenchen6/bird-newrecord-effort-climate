#!/usr/bin/env Rscript
# ============================================================
# Script 128: 天真模型 vs 联合识别模型 —— 整体解释力比较
# Naive single-process models vs joint identification: overall explanatory power
# ============================================================
# 科学问题 / Scientific question:
#   过去研究多只建模一个过程: 或只放气候(归因于分布变化), 或只放调查努力
#   (归因于采样偏差)。若忽略调查努力, 气候【系数】未必有偏(本研究的物种特异
#   算子与努力近乎正交), 但【整体解释力】与【归因份额】会如何变化?
#   这是判断"单过程模型能否支撑其结论"的关键证据。
#
# 比较的模型 / Models compared:
#   M0 null            仅随机效应
#   M1 climate-only    只放气候(累积变化 + 年度变异) —— 归因于生态过程的典型做法
#   M2 effort-only     只放调查努力               —— 归因于观测过程的典型做法
#   M3 additive        气候 + 努力
#   M4 joint (final)   气候 x 努力 + 年度变异     —— 本研究的联合识别模型
#   M1n naive-anomaly  只放【当年气候异常】(不分解) —— 文献最常见设定
#
# 报告指标 / Metrics:
#   AIC, dAIC; 相对空模型的偏差解释率 D2 = 1 − dev/dev_null;
#   条件/边际 pseudo-R2 (Nakagawa, 经 performance::r2 若可用);
#   判别力 AUC (样本内, 仅作相对比较); 各模型对总可解释偏差的覆盖比例
#
# Input / 输入:
#   analysis_final/data/components_tavg_annual_W15.parquet
#   analysis_species_specific/data/model_thr{50,100,200}.parquet
# Output / 输出:
#   analysis_final/tables/tbl_J_naive_vs_joint.csv
#
# Main packages / 主要包: data.table, arrow, glmmTMB, pROC
# 运行 / Run: Rscript --no-init-file code/128_naive_vs_joint_model_comparison.R
# ============================================================

suppressPackageStartupMessages({
  library(data.table); library(arrow); library(glmmTMB); library(pROC)
})
options(warn = 1)

V2  <- normalizePath(".", mustWork = TRUE)
SS  <- file.path(V2, "analysis_species_specific")
OUT <- file.path(V2, "analysis_final")
TAB <- file.path(OUT, "tables")
log <- function(...) cat(sprintf("[128 %s] ", format(Sys.time(), "%H:%M:%S")), ..., "\n")

cmp <- as.data.table(read_parquet(file.path(OUT, "data", "components_tavg_annual_W15.parquet")))
has_perf <- requireNamespace("performance", quietly = TRUE)

FORMS <- c(
  M0_null          = "event ~ 1 + (1|species) + (1|province)",
  M1n_naive_anom   = "event ~ anom_z + (1|species) + (1|province)",
  M1_climate_only  = "event ~ clim_change_z + clim_var_z + (1|species) + (1|province)",
  M2_effort_only   = "event ~ effort_z + (1|species) + (1|province)",
  M3_additive      = "event ~ clim_change_z + clim_var_z + effort_z + (1|species) + (1|province)",
  M4_joint_final   = "event ~ clim_change_z * effort_z + clim_var_z + (1|species) + (1|province)")

res <- list()
for (thr in c(50L, 100L, 200L)) {
  b <- as.data.table(read_parquet(file.path(SS, "data", sprintf("model_thr%d.parquet", thr))))
  d <- merge(b, cmp[, .(species, province, year, clim_change, clim_var)],
             by = c("species", "province", "year"))
  d <- d[is.finite(clim_change) & is.finite(clim_var) & is.finite(eff_visits)]
  d[, anom := clim_change + clim_var]                       # 当年异常 = 两分量之和
  d[, `:=`(clim_change_z = as.numeric(scale(clim_change)),
           clim_var_z    = as.numeric(scale(clim_var)),
           anom_z        = as.numeric(scale(anom)),
           effort_z      = as.numeric(scale(eff_visits)))]
  log("thr", thr, ": ", format(nrow(d), big.mark = ","), " 行 | ", sum(d$event), " 事件")

  fits <- lapply(FORMS, function(f)
    tryCatch(glmmTMB(as.formula(f), d, family = binomial("cloglog")),
             error = function(e) { log("   FAIL ", f); NULL }))
  if (any(vapply(fits, is.null, TRUE))) { log("  有拟合失败, 跳过 thr", thr); next }

  dev <- vapply(fits, function(m) -2 * as.numeric(logLik(m)), 0)
  dev0 <- dev[["M0_null"]]
  devF <- dev[["M4_joint_final"]]
  tot  <- dev0 - devF                                        # 联合模型可解释的总偏差

  for (nm in names(FORMS)) {
    m <- fits[[nm]]
    p <- as.numeric(predict(m, type = "response"))
    auc <- tryCatch(as.numeric(pROC::auc(pROC::roc(d$event, p, quiet = TRUE))),
                    error = function(e) NA_real_)
    r2 <- c(NA_real_, NA_real_)
    if (has_perf) {
      rr <- tryCatch(performance::r2_nakagawa(m), error = function(e) NULL)
      if (!is.null(rr)) r2 <- c(as.numeric(rr$R2_marginal), as.numeric(rr$R2_conditional))
    }
    res[[paste(thr, nm)]] <- data.table(
      threshold = thr, model = nm, formula = FORMS[[nm]],
      df = attr(logLik(m), "df"), AIC = AIC(m), deviance = dev[[nm]],
      # 相对空模型的偏差解释率 / deviance explained vs null
      D2 = round(100 * (dev0 - dev[[nm]]) / dev0, 3),
      # 占联合模型可解释偏差的比例 / share of the jointly explainable deviance
      share_of_joint = round(100 * (dev0 - dev[[nm]]) / tot, 1),
      R2_marginal = round(r2[1], 4), R2_conditional = round(r2[2], 4),
      AUC = round(auc, 4))
  }
  cat("\n")
  tt <- rbindlist(res[grep(paste0("^", thr, " "), names(res))])
  tt[, dAIC := AIC - min(AIC)]
  print(tt[, .(model, df, AIC, dAIC = round(dAIC, 1), D2, share_of_joint,
               R2m = R2_marginal, AUC)])
}
out <- rbindlist(res)
out[, dAIC := AIC - min(AIC), by = threshold]
fwrite(out, file.path(TAB, "tbl_J_naive_vs_joint.csv"))
log("wrote tbl_J_naive_vs_joint.csv")

cat("\n=== 关键对比 (thr50) ===\n")
k <- out[threshold == 50L]
g <- function(m, v) k[model == m][[v]]
cat(sprintf("  只放气候(分解)   : D2=%.3f%%  占联合可解释偏差 %.1f%%  dAIC=%+.1f\n",
    g("M1_climate_only","D2"), g("M1_climate_only","share_of_joint"), g("M1_climate_only","dAIC")))
cat(sprintf("  只放当年异常     : D2=%.3f%%  占联合可解释偏差 %.1f%%  dAIC=%+.1f\n",
    g("M1n_naive_anom","D2"), g("M1n_naive_anom","share_of_joint"), g("M1n_naive_anom","dAIC")))
cat(sprintf("  只放调查努力     : D2=%.3f%%  占联合可解释偏差 %.1f%%  dAIC=%+.1f\n",
    g("M2_effort_only","D2"), g("M2_effort_only","share_of_joint"), g("M2_effort_only","dAIC")))
cat(sprintf("  联合识别(最终)   : D2=%.3f%%  占联合可解释偏差 %.1f%%  dAIC=%+.1f\n",
    g("M4_joint_final","D2"), g("M4_joint_final","share_of_joint"), g("M4_joint_final","dAIC")))
log("DONE")
