#!/usr/bin/env Rscript
# ============================================================
# Script 81: 重建完整省×年调查努力面板
# Rebuild the complete province-year survey-effort panel
# ============================================================
# Scientific question / 科学问题:
#   风险集中"省×年缺格"到底是【零调查努力】还是【无调查数据】?
#   这两者对 climate × effort 交互的识别有完全相反的含义。
#   Are missing province-year cells structural zeros or unmeasured data?
#
# Objective / 分析目标:
#   把 719/782 格的努力面板补成完整面板, 并对每格标注来源状态,
#   使下游风险集不再因 is.finite() 隐式过滤而丢掉努力分布的最低端。
#
# 判据 / Diagnostic evidence (已核实, 见脚本内 QA):
#   (a) 原始努力量 effort_record / n_visits / n_observers / n_birding_days
#       的最小值均为 1, 全panel 无任何 0 值
#       => 面板由"观测记录聚合"生成, 零记录的省×年不产生行, 而非产生 0 行
#       => 内地省份的缺格 = 结构性零努力 (structural zero), 应补 0
#   (b) 台湾 12 个有数据年份的 n_visits = 1,1,2,1,3,5,22,17,24,1,57,301
#       香港 16 年 = 1,2,1,3,3,2,2,13,3,12,27,5,6,16,127,763
#       与两地真实观鸟活动量严重矛盾 (eBird 台湾/香港观鸟会均极活跃)
#       => 港澳台缺格 = 源覆盖缺口 (no data), 不可补 0
#   (c) 对比宁夏 = 1,6,4,3,6,8,12,2,9,34,55,48,78,46,135,521 是合理增长曲线
#       => 内地低值是真实的低努力
#
# Input data / 输入数据:
#   ../bird_hazard_model_effort_upgrade/data/effort_panel_upgraded.csv  (719 格)
#
# Workflow / 主要流程:
#   1. 读入原面板, 反查 z 变换公式 (log1p -> scale) 并验证
#   2. 展开为完整 province × year 网格 (34 省 × 23 年 = 782)
#   3. 按上述判据分类每格: observed / structural_zero / no_data
#   4. 结构性零格的原始计数填 0; no_data 格保持 NA
#   5. 在【分析总体 = 内地 31 省】上重算 log1p 与 z 标准化
#   6. 输出完整面板 + QA 表
#
# Expected output / 预期输出:
#   analysis_rebuilt/data/effort_province_year_rebuilt.csv
#   analysis_rebuilt/tables/qa_effort_rebuild.csv
#
# Key assumptions / 关键假设:
#   - 内地省份在 2002-2024 任一年至少存在"零努力"这一真实状态
#     (即缺格不是行政区划变更或数据传输失败)
#   - 港澳台的努力测量不可用于本研究的努力代理, 故其行标为 no_data
#     并在主分析中排除; 保留标记以便做敏感性分析
#
# Main packages / 主要包: data.table
# Output directory / 输出路径: analysis_rebuilt/
# 运行 / Run: Rscript --no-init-file code/81_rebuild_effort_panel.R
# ============================================================

suppressPackageStartupMessages({ library(data.table) })
options(warn = 1)

V2  <- normalizePath(".", mustWork = TRUE)
V1  <- normalizePath(file.path(V2, "..", "bird_hazard_model_effort_upgrade"), mustWork = TRUE)
OUT <- file.path(V2, "analysis_rebuilt")
for (d in c("data", "tables", "logs")) dir.create(file.path(OUT, d), recursive = TRUE, showWarnings = FALSE)
log <- function(...) cat(sprintf("[81 %s] ", format(Sys.time(), "%H:%M:%S")), ..., "\n")

YR_FROM <- 2002L; YR_TO <- 2024L
YRS     <- YR_FROM:YR_TO
# 港澳台: 努力源覆盖不到, 不可当作零努力 / SARs+Taiwan: source coverage gap, not zero
NON_MAINLAND <- c("Hong Kong", "Macao", "Macau", "Taiwan")

# 努力代理: 原始计数列 -> 目标 z 列 / raw count -> target z column
PROXY <- data.table(
  raw = c("effort_record", "n_visits", "n_observers", "n_birding_days"),
  z   = c("log_effort_record_z", "log_effort_visits_z", "log_effort_observers_z", "log_effort_days_z")
)

# ---- 1. 读入并验证 z 变换公式 / load and verify the z transform ----
eff <- fread(file.path(V1, "data", "effort_panel_upgraded.csv"), encoding = "UTF-8")
log("原面板: ", nrow(eff), " 行 | ", uniqueN(eff$province), " 省 | ",
    uniqueN(eff$year), " 年")

verify <- rbindlist(lapply(seq_len(nrow(PROXY)), function(i) {
  raw <- eff[[PROXY$raw[i]]]; z <- eff[[PROXY$z[i]]]
  ok  <- is.finite(raw) & is.finite(z)
  # scale(log1p(x)) 是否精确复现原 z 列 / does scale(log1p(x)) reproduce the shipped z?
  dev <- max(abs(as.numeric(scale(log1p(raw[ok]))) - z[ok]))
  data.table(proxy = PROXY$raw[i], n_used = sum(ok), max_abs_dev = dev,
             transform_ok = dev < 1e-8)
}))
print(verify)
if (!all(verify$transform_ok))
  stop("z 变换公式未能复现, 停止 / z transform could not be reproduced; aborting")
log("z 变换确认: z = scale(log1p(count)), 全部 4 个代理精确复现")

# 原始计数确无 0 值 —— 这是"缺格=零努力"判据的基础
zero_counts <- PROXY[, .(proxy = raw, n_zero = sapply(raw, function(v) sum(eff[[v]] == 0, na.rm = TRUE)),
                         min_val = sapply(raw, function(v) min(eff[[v]], na.rm = TRUE)))]
print(zero_counts)
if (any(zero_counts$n_zero > 0))
  log("警告: 面板中已存在 0 值, '缺格=零努力'判据需重新审视")

# ---- 2. 展开完整网格 / expand to the full province x year grid ----
provs <- sort(unique(eff$province))
full  <- CJ(province = provs, year = YRS)
pan   <- merge(full, eff, by = c("province", "year"), all.x = TRUE)
log("完整网格: ", nrow(pan), " 格 (", length(provs), " 省 × ", length(YRS), " 年)")

# ---- 3. 分类每格状态 / classify each cell ----
pan[, observed := !is.na(n_visits)]
pan[, mainland := !(province %in% NON_MAINLAND)]
pan[, effort_status := fifelse(observed, "observed",
                        fifelse(mainland, "structural_zero", "no_data"))]
print(pan[, .N, by = .(effort_status, mainland)][order(effort_status)])

# ---- 4. 结构性零填 0, no_data 保持 NA / fill structural zeros, keep no_data as NA ----
for (v in PROXY$raw)
  pan[effort_status == "structural_zero", (v) := 0]
# effort_pc1 是派生合成量, 结构性零格无法由 PCA 载荷外推, 显式置 NA 并标注
# effort_pc1 is a derived composite; cannot be extrapolated for zero cells
pan[effort_status == "structural_zero", effort_pc1 := NA_real_]

# effort_record 在 17 个【已观测】格中缺失 —— 属该代理特有的数据缺口, 不做插补
rec_gap <- pan[effort_status == "observed" & is.na(effort_record), .(province, year, n_visits)]
log("effort_record 在已观测格中的缺口: ", nrow(rec_gap), " 格 (保持 NA, 不插补)")
if (nrow(rec_gap)) print(rec_gap)

# ---- 5. 在分析总体(内地 31 省)上重算 log1p 与 z / recompute z on the analysis population ----
# 口径变更说明: 原 z 在 719 个"已观测"格上标准化(不含结构性零);
# 新 z 在【分析范围内】的 observed + structural_zero 格上标准化, 这才是模型实际总体。
#
# 分析范围按【单位面积记录密度】判定, 而非绝对计数 (2026-07-25 核实):
#   香港 2024: 18,142 条 / 1,100 km2 = 16.5 条/km2 ≈ 北京 29.7 条/km2 => 保留
#     绝对计数低只是面积小所致, 不构成测量失真
#   台湾 2024:  4,836 条 / 36,000 km2 = 0.13 条/km2 (低约 100 倍)     => 排除
#   澳门: 23 年仅 2 年有数据                                          => 排除
EXCLUDE  <- c("Taiwan", "Macao", "Macau")
pan[, in_scope := !(province %in% EXCLUDE)]
ANALYSIS <- pan$in_scope & pan$effort_status %in% c("observed", "structural_zero")
log("z 标准化总体: ", sum(ANALYSIS), " 格 (范围内 ", uniqueN(pan[in_scope == TRUE, province]),
    " 省 | 原口径 ", sum(!is.na(eff$n_visits)), " 格)")

for (i in seq_len(nrow(PROXY))) {
  rawv <- PROXY$raw[i]; zv <- PROXY$z[i]
  lg   <- paste0("log_", rawv)
  pan[, (lg) := log1p(get(rawv))]
  mu <- mean(pan[[lg]][ANALYSIS], na.rm = TRUE)
  sd <- stats::sd(pan[[lg]][ANALYSIS], na.rm = TRUE)
  pan[, (zv) := (get(lg) - mu) / sd]
  pan[!ANALYSIS, (zv) := NA_real_]   # 分析总体之外不赋 z / no z outside the analysis population
  log(sprintf("  %-16s log1p 均值=%.4f sd=%.4f | z 范围 [%.3f, %.3f]",
              rawv, mu, sd, min(pan[[zv]], na.rm = TRUE), max(pan[[zv]], na.rm = TRUE)))
}
# PCA 合成代理在内地完整格上重算 / recompute the PCA composite on complete mainland cells
zmat <- pan[, PROXY$z, with = FALSE]
pc_ok <- ANALYSIS & stats::complete.cases(zmat)   # 两者同为 782 长度 / both length 782
if (sum(pc_ok) > 10) {
  pc <- stats::prcomp(zmat[pc_ok], center = TRUE, scale. = TRUE)
  log("effort_pc1 重算: 用 ", sum(pc_ok), " 格 | PC1 解释方差 ",
      round(100 * pc$sdev[1]^2 / sum(pc$sdev^2), 1), "%")
  pan[, effort_pc1_z := NA_real_]
  pan[pc_ok, effort_pc1_z := as.numeric(scale(pc$x[, 1]))]
}

# ---- 6. 输出 / write ----
setcolorder(pan, c("province", "year", "effort_status", "mainland", "observed"))
fwrite(pan, file.path(OUT, "data", "effort_province_year_rebuilt.csv"))
log("wrote effort_province_year_rebuilt.csv: ", nrow(pan), " 行")

qa <- pan[, .(
  n_cells          = .N,
  observed         = sum(effort_status == "observed"),
  structural_zero  = sum(effort_status == "structural_zero"),
  no_data          = sum(effort_status == "no_data")
), by = .(mainland)]
qa2 <- rbindlist(lapply(PROXY$z, function(v)
  data.table(indicator = v,
             n_analysis   = sum(ANALYSIS),
             n_nonmissing = sum(!is.na(pan[[v]][ANALYSIS])),
             missing_pct  = round(100 * mean(is.na(pan[[v]][ANALYSIS])), 2))))
print(qa); print(qa2)
fwrite(rbindlist(list(
  data.table(block = "cells_by_region", metric = paste0("mainland=", qa$mainland),
             value = paste0("obs=", qa$observed, "; zero=", qa$structural_zero,
                            "; nodata=", qa$no_data)),
  data.table(block = "indicator_completeness", metric = qa2$indicator,
             value = paste0(qa2$n_nonmissing, "/", qa2$n_analysis,
                            " (missing ", qa2$missing_pct, "%)"))
)), file.path(OUT, "tables", "qa_effort_rebuild.csv"))
log("wrote qa_effort_rebuild.csv")
log("DONE")
