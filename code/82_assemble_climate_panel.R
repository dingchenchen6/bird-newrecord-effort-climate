#!/usr/bin/env Rscript
# ============================================================
# Script 82: 装配完整省×年气候面板 (CRU 重建 + 遗留指标显式标注)
# Assemble the complete province-year climate panel
# ============================================================
# Scientific question / 科学问题:
#   旧气候面板中哪些指标是真实时变的、哪些是被填充或时间恒定的?
#   把可重建的换成 CRU 真值, 不可重建的必须显式标注质量等级。
#   Which climate indicators carry real interannual signal, and which
#   are fill values or province-constant (hence unidentifiable)?
#
# Objective / 分析目标:
#   产出一张【每个指标都带 provenance 与质量标记】的完整气候面板,
#   使下游模型不会把"不可识别"误读为"无生态效应"。
#
# 已核实事实 / Verified facts (见 QA 输出):
#   旧面板 climate_metrics_province_year.csv:
#     - temp_anom / temp_grad_prov / prec_anom / prec_grad_prov /
#       mahalanobis_dist : 48.6% 省×年为填充值(等于该省众数), 每省中位 12
#       个唯一值 / 23 年
#     - climate_velocity / precip_velocity / climate_exposure / warming_rate /
#       spatial_temp_grad / spatial_prec_grad : 100% 填充, **每省仅 1 个唯一值**
#       => 时间恒定, 被 (1|province) 完全吸收 => 其"无交互"首先是可识别性
#          问题, 不是生态结论
#     - temp_grad_prov 与 temp_anom 逐行完全相同 (max|diff| = 0), 是别名
#   CRU 重建面板 (code/80, CRU TS 4.09 逐月 0.5°, 1970-2000 基线):
#     - temp_anom / warming_rate / climate_exposure / climate_velocity /
#       thermal_novelty : 每省 23 个唯一值 => 真正时变
#     - spatial_temp_grad : 每省 1 值, 但这是【设计使然】(基线栅格的空间梯度)
#
# 本机数据边界 / Local data boundary:
#   CRU TS 4.09 本机只有 tmp (月均温) 与 tmx (月最高温), **无降水 .pre**,
#   故 prec_anom / prec_grad_prov / precip_velocity / spatial_prec_grad
#   **无法重建**, 只能沿用旧值并标记为 legacy_filled。
#   mahalanobis_dist 依赖多元气候矩阵, 同样无法在本机重建。
#
# Input data / 输入数据:
#   analysis_rebuilt/data/climate_province_year_rebuilt.csv        (CRU 重建)
#   ../bird_hazard_model_effort_upgrade/data/climate_metrics_province_year.csv (旧)
#
# Workflow / 主要流程:
#   1. 读入两份面板, 统一省份命名 (Macau -> Macao)
#   2. 逐指标计算填充率与省内唯一值数, 生成质量标记
#   3. CRU 可重建指标取重建值, 其余取旧值并标 legacy
#   4. 在【分析总体 = 内地 31 省】上重算 z (与努力面板口径一致)
#   5. 输出面板 + provenance 表
#
# Expected output / 预期输出:
#   analysis_rebuilt/data/climate_province_year_assembled.csv
#   analysis_rebuilt/tables/qa_climate_provenance.csv
#
# Key assumptions / 关键假设:
#   - "等于该省众数"作为填充判据, 会把真实的重复值误判为填充, 故填充率是上界
#   - z 标准化总体必须与努力面板一致, 否则两者的 SD 不可比, 交互项失去尺度含义
#
# Main packages / 主要包: data.table
# Output directory / 输出路径: analysis_rebuilt/
# 运行 / Run: Rscript --no-init-file code/82_assemble_climate_panel.R
# ============================================================

suppressPackageStartupMessages({ library(data.table) })
options(warn = 1)

V2  <- normalizePath(".", mustWork = TRUE)
V1  <- normalizePath(file.path(V2, "..", "bird_hazard_model_effort_upgrade"), mustWork = TRUE)
OUT <- file.path(V2, "analysis_rebuilt")
log <- function(...) cat(sprintf("[82 %s] ", format(Sys.time(), "%H:%M:%S")), ..., "\n")

YRS <- 2002:2024
NON_MAINLAND <- c("Hong Kong", "Macao", "Macau", "Taiwan")

new <- fread(file.path(OUT, "data", "climate_province_year_rebuilt.csv"), encoding = "UTF-8")
old <- fread(file.path(V1, "data", "climate_metrics_province_year.csv"),  encoding = "UTF-8")

# ---- 1. 统一省份命名 / harmonise province naming ----
new[province == "Macau", province := "Macao"]
stopifnot(setequal(unique(new$province), unique(old$province)))
log("省份命名统一后一致: ", uniqueN(new$province), " 省")

# ---- 2. 逐指标质量诊断 / per-indicator quality diagnostics ----
diag_one <- function(dt, v, tag) {
  if (!v %in% names(dt)) return(NULL)
  d <- dt[year %in% YRS, .(province, year, x = get(v))]
  # 填充判据: 等于该省众数 / fill criterion: equals the within-province mode
  d[, md := as.numeric(names(sort(table(x), decreasing = TRUE))[1]), by = province]
  uq <- d[, uniqueN(x), by = province]$V1
  data.table(indicator = v, source = tag,
             fill_pct        = round(100 * mean(abs(d$x - d$md) < 1e-9, na.rm = TRUE), 1),
             uniq_per_prov   = as.integer(median(uq)),
             min_uniq        = as.integer(min(uq)),
             time_varying    = median(uq) > 1L,
             missing_pct     = round(100 * mean(is.na(d$x)), 2))
}

OLD_VARS <- c("temp_anom", "temp_grad_prov", "prec_anom", "prec_grad_prov",
              "mahalanobis_dist", "climate_velocity", "precip_velocity",
              "climate_exposure", "warming_rate", "spatial_temp_grad", "spatial_prec_grad")
NEW_VARS <- c("temp_anom", "warming_rate", "climate_exposure", "climate_velocity",
              "thermal_novelty", "temp_sd_roll", "spatial_temp_grad")

qa <- rbindlist(c(
  lapply(OLD_VARS, function(v) diag_one(old, v, "legacy")),
  lapply(NEW_VARS, function(v) diag_one(new, v, "cru_rebuilt"))
), fill = TRUE)
print(qa)

# 别名核验 / alias check
alias_dev <- max(abs(old$temp_grad_prov - old$temp_anom), na.rm = TRUE)
log("别名核验 temp_grad_prov vs temp_anom: max|diff| = ", alias_dev,
    if (alias_dev < 1e-9) "  => 确认为别名, 非独立轴" else "")

# ---- 3. 组装 / assemble ----
# CRU 可重建的温度类指标取重建值; 降水类与 mahalanobis 沿用旧值并标 legacy
REBUILT <- c("temp_anom", "warming_rate", "climate_exposure", "climate_velocity",
             "thermal_novelty", "temp_sd_roll", "spatial_temp_grad")
LEGACY  <- c("prec_anom", "prec_grad_prov", "precip_velocity",
             "spatial_prec_grad", "mahalanobis_dist")

pan <- merge(new[year %in% YRS, c("province", "year", REBUILT), with = FALSE],
             old[year %in% YRS, c("province", "year", LEGACY),  with = FALSE],
             by = c("province", "year"), all = TRUE)
pan[, mainland := !(province %in% NON_MAINLAND)]
log("组装面板: ", nrow(pan), " 行 | 重建指标 ", length(REBUILT),
    " 个 | 遗留指标 ", length(LEGACY), " 个")

# ---- 4. 在分析范围上重算 z / recompute z on the analysis population ----
# 范围必须与努力面板(script 81)一致, 否则两者 SD 不可比、交互项失去尺度含义。
# 按单位面积记录密度判定: 保留香港(16.5 条/km2 ≈ 北京 29.7), 排除台湾(0.13)与澳门。
EXCLUDE  <- c("Taiwan", "Macao", "Macau")
pan[, in_scope := !(province %in% EXCLUDE)]
ANALYSIS <- pan$in_scope
log("z 标准化总体: ", sum(ANALYSIS), " 格 (",
    uniqueN(pan[in_scope == TRUE, province]), " 省, 与 script 81 一致)")
for (v in c(REBUILT, LEGACY)) {
  mu <- mean(pan[[v]][ANALYSIS], na.rm = TRUE)
  sd <- stats::sd(pan[[v]][ANALYSIS], na.rm = TRUE)
  zv <- paste0(v, "_z")
  if (!is.finite(sd) || sd == 0) {           # 常数指标无法 z 化 / constant -> no z
    pan[, (zv) := NA_real_]
    log(sprintf("  %-20s sd=0 或不可用, z 置 NA (该指标在省内无变异)", v))
  } else {
    pan[, (zv) := (get(v) - mu) / sd]
    pan[!ANALYSIS, (zv) := NA_real_]
  }
}
# 头条气候 = 温度异常 z (旧口径 temp_grad_prov_z 的正确来源)
pan[, climate_z := temp_anom_z]
log("头条气候 climate_z := temp_anom_z (取代旧的 temp_grad_prov_z 别名)")

setcolorder(pan, c("province", "year", "mainland", "climate_z"))
fwrite(pan, file.path(OUT, "data", "climate_province_year_assembled.csv"))
log("wrote climate_province_year_assembled.csv: ", nrow(pan), " 行")

qa[, usable_for_interaction := time_varying]
qa[, note := fifelse(source == "cru_rebuilt", "CRU TS4.09 重建, 逐年真值",
              fifelse(fill_pct >= 99, "省内时间恒定, 被 (1|province) 吸收, 交互不可识别",
                      "48.6% 填充, 交互估计向 0 衰减(保守)"))]
fwrite(qa, file.path(OUT, "tables", "qa_climate_provenance.csv"))
log("wrote qa_climate_provenance.csv")
log("DONE")
