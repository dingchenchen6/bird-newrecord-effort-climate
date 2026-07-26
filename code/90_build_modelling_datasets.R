#!/usr/bin/env Rscript
# ============================================================
# Script 90: 建立物种特异口径的标准建模数据集 (三档阈值)
# Build the canonical modelling datasets with the species-specific climate term
# ============================================================
# Scientific question / 科学问题:
#   下游所有分析必须共用同一份【完整风险集 + 物种特异气候项】数据,
#   且 event=1 与 event=0 两类行的协变量口径完全一致、标准化在同一总体上完成。
#   All downstream analyses must share one dataset in which the species-specific
#   climate term is defined for event and non-event rows alike.
#
# Objective / 分析目标:
#   为 thr 50/100/200 各产出一份建模数据集, 含:
#     - 物种特异气候项 temp_anom_grad = temp_anom(省,年) - temp_native_anom(种,年)
#       及其他可构造的物种特异代理
#     - 全部调查努力代理 (combined 源, 多观测指标)
#     - 迁徙分层 (缺失为显式 Unknown)
#     - 全部 z 标准化【在完整风险集上进行】(含 event=0 与 event=1)
#
# 关键口径 / Key conventions (已逐项核实):
#   - temp_anom_grad 对 event=0 与 event=1 行【同样计算】, 覆盖率 100%
#   - 迷鸟(无中国历史分布区, 69 种)已排除, 不做替代估计
#   - z 标准化总体 = 该阈值下的完整建模行集, 而非仅事件行
#   - 省级异常与原生异常同源同基线 (CRU TS4.09, 1970-2000)
#
# Input data / 输入数据:
#   analysis_rebuilt/data/riskset_corrected_thr{50,100,200}.parquet  (script 83)
#   analysis_rebuilt/data/species_native_anom_panel.csv              (script 88)
#   analysis_rebuilt/data/climate_province_year_assembled.csv        (script 82)
#   analysis_rebuilt/data/effort_province_year_rebuilt.csv           (script 81)
#
# Expected output / 预期输出:
#   analysis_species_specific/data/model_thr{50,100,200}.parquet
#   analysis_species_specific/tables/qa_modelling_datasets.csv
#
# Main packages / 主要包: data.table, arrow
# Output directory / 输出路径: analysis_species_specific/
# 运行 / Run: Rscript --no-init-file code/90_build_modelling_datasets.R
# ============================================================

suppressPackageStartupMessages({ library(data.table); library(arrow) })
options(warn = 1)

V2  <- normalizePath(".", mustWork = TRUE)
RB  <- file.path(V2, "analysis_rebuilt")
OUT <- file.path(V2, "analysis_species_specific")
for (d in c("data", "tables", "figures", "logs"))
  dir.create(file.path(OUT, d), recursive = TRUE, showWarnings = FALSE)
log <- function(...) cat(sprintf("[90 %s] ", format(Sys.time(), "%H:%M:%S")), ..., "\n")

nat  <- fread(file.path(RB, "data", "species_native_anom_panel.csv"), encoding = "UTF-8")
clim <- fread(file.path(RB, "data", "climate_province_year_assembled.csv"), encoding = "UTF-8")
eff  <- fread(file.path(RB, "data", "effort_province_year_rebuilt.csv"), encoding = "UTF-8")
log("原生异常面板 ", nrow(nat), " 行 / ", uniqueN(nat$species), " 种 | 气候 ", nrow(clim),
    " | 努力 ", nrow(eff))

# 努力代理 / effort proxies
EFF <- c(visits = "log_effort_visits_z", records = "log_effort_record_z",
         observers = "log_effort_observers_z", days = "log_effort_days_z",
         pca = "effort_pc1_z")

qa <- list()
for (thr in c(50L, 100L, 200L)) {
  d <- as.data.table(read_parquet(file.path(RB, "data",
        sprintf("riskset_corrected_thr%d.parquet", thr))))
  n_raw <- nrow(d)

  # 1) 排除迷鸟 / drop vagrants without a Chinese historical range
  d <- d[species %in% unique(nat$species)]
  n_sp <- nrow(d)

  # 2) 物种特异气候项: 对 event=0 与 event=1 同样计算
  d <- merge(d, nat[, .(species, year, temp_native_anom, native_baseline = baseline)],
             by = c("species", "year"), all.x = TRUE)
  d <- merge(d, clim[, .(province, year, prov_temp_anom = temp_anom,
                         prov_prec_anom = prec_anom)],
             by = c("province", "year"), all.x = TRUE)
  d[, temp_anom_grad := prov_temp_anom - temp_native_anom]

  # 3) 标准化【在完整风险集上】/ standardise over the complete risk set
  d[, climate_z := as.numeric(scale(temp_anom_grad))]
  d[, prov_anom_z := as.numeric(scale(prov_temp_anom))]   # 省级参照项 / province-level reference
  for (nm in names(EFF)) {
    src <- EFF[[nm]]
    if (src %in% names(d)) d[, (paste0("eff_", nm)) := as.numeric(scale(get(src)))]
  }
  d[, effort_z := eff_visits]                              # 头条努力 / headline effort

  # 4) 迁徙分层已在 83 设为显式 Unknown / migratory stratum
  d[, mig_grp := factor(mig_grp, levels = c("Resident", "Partial", "Long-distance", "Unknown"))]

  keep_cols <- c("species", "province", "year", "year_c", "event", "threshold",
                 "effort_status", "mig_grp", "temp_native_anom", "native_baseline",
                 "prov_temp_anom", "prov_prec_anom", "temp_anom_grad",
                 "climate_z", "prov_anom_z", "effort_z",
                 paste0("eff_", names(EFF)))
  keep_cols <- intersect(keep_cols, names(d))
  d <- d[, ..keep_cols]
  write_parquet(d, file.path(OUT, "data", sprintf("model_thr%d.parquet", thr)))

  q <- data.table(
    threshold = thr, rows_riskset = n_raw, rows_after_vagrant_drop = n_sp,
    rows_final = nrow(d), species = uniqueN(d$species), provinces = uniqueN(d$province),
    events = sum(d$event), nonevents = sum(d$event == 0),
    grad_cov_event = round(100 * mean(is.finite(d$temp_anom_grad[d$event == 1])), 2),
    grad_cov_nonevent = round(100 * mean(is.finite(d$temp_anom_grad[d$event == 0])), 2),
    grad_uniq_per_provyear = as.integer(median(d[, uniqueN(temp_anom_grad), by = .(province, year)]$V1)),
    climate_z_mean = signif(mean(d$climate_z, na.rm = TRUE), 3),
    climate_z_sd   = round(stats::sd(d$climate_z, na.rm = TRUE), 4),
    effort_z_miss  = round(100 * mean(is.na(d$effort_z)), 3),
    mig_unknown_events = sum(d$event[d$mig_grp == "Unknown"]))
  qa[[as.character(thr)]] <- q
  log(sprintf("thr=%d -> %s 行 | %d 种 | %d 事件 | grad 覆盖 event %.1f%% / nonevent %.1f%% | 物种特异度 %d",
      thr, format(nrow(d), big.mark = ","), uniqueN(d$species), sum(d$event),
      q$grad_cov_event, q$grad_cov_nonevent, q$grad_uniq_per_provyear))
}
st <- rbindlist(qa)
print(st)
fwrite(st, file.path(OUT, "tables", "qa_modelling_datasets.csv"))
log("wrote qa_modelling_datasets.csv")
log("DONE")
