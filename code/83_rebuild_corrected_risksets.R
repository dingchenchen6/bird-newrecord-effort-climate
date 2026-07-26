#!/usr/bin/env Rscript
# ============================================================
# Script 83: 用修正后的努力与气候面板重建三档阈值完整风险集
# Rebuild the complete risk sets (thr 50/100/200) on corrected panels
# ============================================================
# Scientific question / 科学问题:
#   物种×省×年风险集在多大程度上因协变量面板缺格而被隐式截断?
#   修正后风险集的结构完整性能否达到 100%?
#   To what extent was the risk set implicitly truncated by covariate gaps?
#
# Objective / 分析目标:
#   复刻 code/71 的候选口径, 但用修正面板替换协变量, 并去掉
#   `is.finite(climate) & is.finite(effort)` 这一隐式过滤,
#   使每一个结构性风险行都进入分析。
#
# 与 code/71 的差异 / Differences from code/71:
#   1. 努力面板 -> 81 重建版: 内地缺格补结构性零(0), 港/台/澳缺格标 no_data
#      努力源仍为 combined (effort_occupancy_model_province_year_combined.csv),
#      由 records / visits / observers / birding-days 四个观测代理量化
#   2. 气候面板 -> 82 装配版: 温度类用 CRU 重建(逐年真值), 降水类沿用并标注
#   3. 头条气候 climate_z 由 temp_anom_z 提供(旧 temp_grad_prov 是其别名)
#   4. 分析范围按【单位面积记录密度】判定(详见下方 SCOPE), 排除台湾与澳门,
#      保留香港。原口径把香港按绝对计数误判为"低努力", 实为面积效应。
#   5. 不做 is.finite 过滤; 保留完整骨架并输出完整性诊断
#   6. 事件全部纳入(强制纳入规则不变), 三档阈值事件数恒定
#
# Input data / 输入数据:
#   analysis_rebuilt/data/effort_province_year_rebuilt.csv     (script 81)
#   analysis_rebuilt/data/climate_province_year_assembled.csv  (script 82)
#   ../bird_hazard_model_effort_upgrade/data/events_100km_grid_assigned.csv
#   ../bird_new_record_hazard_model/results/combined_threshold_{50,100,200}_test/
#     derived_inputs/sdm_province.csv
#
# Workflow / 主要流程:
#   1. 候选构建(同 71): 基础候选 + 事件强制纳入 + SDM 建模种并集
#   2. 展开 species × province × year, 事件后删失
#   3. 限定内地, 连接修正面板, 迁徙类型缺失设为显式 Unknown 层
#   4. 完整性诊断: 逐协变量缺失率、省×年格覆盖、事件保留
#   5. 输出 parquet + 诊断表
#
# Expected output / 预期输出:
#   analysis_rebuilt/data/riskset_corrected_thr{50,100,200}.parquet
#   analysis_rebuilt/tables/qa_riskset_corrected.csv
#
# Key assumptions / 关键假设:
#   - 事件强制纳入规则沿用 71(保证三档阈值事件数一致), 便于与已发表结果对比
#   - 迁徙类型缺失用 Unknown 显式层, 而非丢弃 -> 分层分析覆盖全部事件
#
# Main packages / 主要包: data.table, arrow
# Output directory / 输出路径: analysis_rebuilt/
# 运行 / Run: Rscript --no-init-file code/83_rebuild_corrected_risksets.R
# ============================================================

suppressPackageStartupMessages({ library(data.table); library(arrow) })
options(warn = 1)

V2  <- normalizePath(".", mustWork = TRUE)
V1  <- normalizePath(file.path(V2, "..", "bird_hazard_model_effort_upgrade"), mustWork = TRUE)
SDM <- normalizePath(file.path(V2, "..", "bird_new_record_hazard_model"), mustWork = TRUE)
BW  <- normalizePath(file.path(V2, "..", "bird_sdm_distribution_modeling_birdwatch_2002_2025"), mustWork = TRUE)
RS  <- normalizePath(file.path(V2, "..", "bird_sdm_distribution_modeling_rescue_1980_2025_gbif"), mustWork = TRUE)
OUT <- file.path(V2, "analysis_rebuilt")
log <- function(...) cat(sprintf("[83 %s] ", format(Sys.time(), "%H:%M:%S")), ..., "\n")

YMIN <- 2002L; YMAX <- 2024L; YRS <- YMIN:YMAX

# ---- 输入 / inputs ----
eff  <- fread(file.path(OUT, "data", "effort_province_year_rebuilt.csv"),    encoding = "UTF-8")
clim <- fread(file.path(OUT, "data", "climate_province_year_assembled.csv"), encoding = "UTF-8")
ev   <- fread(file.path(V1, "data", "events_100km_grid_assigned.csv"),       encoding = "UTF-8")
setnames(ev, tolower(names(ev)))
if (!"year" %in% names(ev) && "pub_year" %in% names(ev)) setnames(ev, "pub_year", "year")
ev <- ev[year >= YMIN & year <= YMAX]

mbw <- fread(file.path(BW, "data", "tables", "table_model_occurrence_points_used_all_species.csv"), encoding = "UTF-8")
mrs <- fread(file.path(RS, "data", "tables", "table_model_occurrence_points_used_all_species.csv"), encoding = "UTF-8")
modelled <- union(unique(mbw$species), unique(mrs$species))

v2ref  <- fread(file.path(V1, "data", "hazard_risk_upgraded_complete_case.csv"), encoding = "UTF-8")
sp_mig <- unique(v2ref[mig != "" & !is.na(mig), .(species, mig)])

# ---- 分析范围 / analysis scope ----
# 按【单位面积记录密度】而非绝对计数判定努力可用性 (2026-07-25 核实):
#   香港 2024: 18,142 条 / 1,100 km2 = 16.5 条/km2  ~  北京 29.7 条/km2  => 保留
#     (绝对计数低只是因为面积小, 不是测量失真)
#   台湾 2024:  4,836 条 / 36,000 km2 = 0.13 条/km2 (低约 100 倍)       => 排除
#     且 Combined 网格源中台湾 23 年有 12 年为 0, 属源覆盖缺口
#   澳门: 23 年仅 2 年有数据, 且在风险集中无候选对                      => 排除
EXCLUDE  <- c("Taiwan", "Macao", "Macau")
SCOPE    <- setdiff(sort(unique(eff$province)), EXCLUDE)
log("分析范围: ", length(SCOPE), " 省 (排除 ", paste(EXCLUDE, collapse = "/"),
    ") | 事件表 ", nrow(ev), " 条 | 建模种 ", length(modelled))

EFF_Z  <- c("log_effort_record_z", "log_effort_visits_z",
            "log_effort_observers_z", "log_effort_days_z", "effort_pc1_z")
CLIM_Z <- grep("_z$", names(clim), value = TRUE)
first_arr <- ev[, .(arrival_year = min(year, na.rm = TRUE)), by = .(species, province)]

build_one <- function(thr) {
  p   <- file.path(SDM, "results", sprintf("combined_threshold_%d_test", thr),
                   "derived_inputs", "sdm_province.csv")
  sdm <- fread(p, encoding = "UTF-8")
  base   <- unique(sdm[potential == 1L & historical_presence == 0L, .(species, province)])
  evp    <- unique(ev[, .(species, province)])
  cand   <- unique(rbind(base, evp))
  cand   <- cand[species %in% modelled]
  n_before_scope <- nrow(cand)
  cand   <- cand[province %in% SCOPE]          # 限定分析范围 / restrict to scope

  rs <- cand[rep(seq_len(.N), each = length(YRS))]
  rs[, year := rep(YRS, times = nrow(cand))]
  rs <- merge(rs, first_arr, by = c("species", "province"), all.x = TRUE)
  rs <- rs[is.na(arrival_year) | year <= arrival_year]   # 事件后删失 / absorbing exit
  rs[, event := as.integer(!is.na(arrival_year) & year == arrival_year)]
  n_skeleton <- nrow(rs)

  rs <- merge(rs, eff[,  c("province", "year", "effort_status", EFF_Z), with = FALSE],
              by = c("province", "year"), all.x = TRUE)
  # 注意: climate_z 本身以 _z 结尾, 已包含在 CLIM_Z 中, 不可重复指定
  rs <- merge(rs, clim[, c("province", "year", CLIM_Z), with = FALSE],
              by = c("province", "year"), all.x = TRUE)
  rs <- merge(rs, sp_mig, by = "species", all.x = TRUE)

  # 迁徙: 缺失设为显式 Unknown 层, 不丢事件 / explicit Unknown level
  rs[, mig_grp := fifelse(mig == "Resident_low", "Resident",
                   fifelse(mig == "Partial_migrant", "Partial",
                    fifelse(mig == "Long_distance_migrant", "Long-distance", "Unknown")))]
  rs[is.na(mig_grp), mig_grp := "Unknown"]
  rs[, year_c := year - 2013L]
  rs[, threshold := thr]

  summ <- data.table(
    threshold          = thr,
    candidate_pairs    = nrow(cand),
    pairs_dropped_scope= n_before_scope - nrow(cand),
    skeleton_rows      = n_skeleton,
    rows_final         = nrow(rs),
    rows_dropped       = n_skeleton - nrow(rs),
    structural_complete= n_skeleton == nrow(rs),
    species            = uniqueN(rs$species),
    provinces          = uniqueN(rs$province),
    prov_year_cells    = uniqueN(rs[, .(province, year)]),
    events             = sum(rs$event),
    rows_zero_effort   = sum(rs$effort_status == "structural_zero"),
    miss_climate_pct   = round(100 * mean(is.na(rs$climate_z)), 3),
    miss_visits_pct    = round(100 * mean(is.na(rs$log_effort_visits_z)), 3),
    miss_record_pct    = round(100 * mean(is.na(rs$log_effort_record_z)), 3),
    mig_unknown_events = sum(rs$event[rs$mig_grp == "Unknown"])
  )
  list(rs = rs, summ = summ)
}

summ <- list()
for (thr in c(50L, 100L, 200L)) {
  r <- build_one(thr)
  write_parquet(r$rs, file.path(OUT, "data", sprintf("riskset_corrected_thr%d.parquet", thr)))
  summ[[as.character(thr)]] <- r$summ
  log(sprintf("thr=%d -> %s 行 | %d 种 | %d 省 | %d 事件 | 零努力行 %s | 结构完整=%s",
      thr, format(nrow(r$rs), big.mark = ","), uniqueN(r$rs$species),
      uniqueN(r$rs$province), sum(r$rs$event),
      format(r$summ$rows_zero_effort, big.mark = ","), r$summ$structural_complete))
}
st <- rbindlist(summ)
print(st)
fwrite(st, file.path(OUT, "tables", "qa_riskset_corrected.csv"))
log("wrote qa_riskset_corrected.csv")
log("DONE")
