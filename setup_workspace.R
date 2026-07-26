#!/usr/bin/env Rscript
# ============================================================
# setup_workspace.R — prepare the working directory layout
# ============================================================
# The analysis scripts in code/ address files through the working layout used
# during development:
#
#   analysis_rebuilt/{data,tables}/
#   analysis_species_specific/{data,tables}/
#   analysis_final/{data,tables,figures,logs}/
#
# The repository stores the same files in a flat, browsable layout (data/,
# tables/, figures/). This script builds the working layout from it, so that the
# scripts run unchanged. Files are hard-linked where the filesystem allows and
# copied otherwise, so no extra disk space is used on most systems.
#
# Run once after cloning:
#   Rscript --no-init-file setup_workspace.R
#
# Verify afterwards with:
#   Rscript --no-init-file tests/smoke_test.R
# ============================================================

msg <- function(...) cat(sprintf("[setup %s] ", format(Sys.time(), "%H:%M:%S")), ..., "\n")

ROOT <- normalizePath(".", mustWork = TRUE)
if (!dir.exists(file.path(ROOT, "code")) || !dir.exists(file.path(ROOT, "data")))
  stop("Run this script from the repository root (the folder containing code/ and data/).")

DIRS <- c("analysis_rebuilt/data", "analysis_rebuilt/tables",
          "analysis_species_specific/data", "analysis_species_specific/tables",
          "analysis_final/data", "analysis_final/tables",
          "analysis_final/figures", "analysis_final/figures_alt",
          "analysis_final/figures_future", "analysis_final/logs")
for (d in DIRS) dir.create(file.path(ROOT, d), recursive = TRUE, showWarnings = FALSE)
msg("created ", length(DIRS), " working directories")

# 目标布局 -> 仓库中的源文件 / working path <- repository path
MAP <- c(
  # modelling datasets consumed by scripts 121-128
  "analysis_species_specific/data/model_thr50.parquet"          = "data/model_thr50.parquet",
  "analysis_species_specific/data/model_thr100.parquet"         = "data/model_thr100.parquet",
  "analysis_species_specific/data/model_thr200.parquet"         = "data/model_thr200.parquet",
  # climate components (annual mean temperature, four accumulation windows)
  "analysis_final/data/components_tavg_annual_W5.parquet"       = "data/components_tavg_annual_W5.parquet",
  "analysis_final/data/components_tavg_annual_W10.parquet"      = "data/components_tavg_annual_W10.parquet",
  "analysis_final/data/components_tavg_annual_W15.parquet"      = "data/components_tavg_annual_W15.parquet",
  "analysis_final/data/components_tavg_annual_W20.parquet"      = "data/components_tavg_annual_W20.parquet",
  # panels
  "analysis_rebuilt/data/effort_province_year_rebuilt.csv"      = "data/effort_province_year_rebuilt.csv",
  "analysis_rebuilt/data/species_native_anom_panel.csv"         = "data/species_native_anom_panel.csv",
  "analysis_rebuilt/data/climate_province_year_assembled.csv"   = "data/climate_province_year_assembled.csv",
  "analysis_rebuilt/data/grid_province_lookup.csv"              = "data/grid_province_lookup.csv",
  "analysis_rebuilt/tables/list_excluded_vagrants.csv"          = "data/list_excluded_vagrants.csv",
  # CMIP6 deltas consumed by script 126
  "analysis_species_specific/tables/tbl_F_cmip6_delta.csv"      = "tables/tbl_F_cmip6_delta.csv"
)

link_or_copy <- function(from, to) {
  if (file.exists(to)) return("exists")
  ok <- suppressWarnings(file.link(from, to))
  if (isTRUE(ok)) return("linked")
  if (file.copy(from, to)) return("copied")
  "FAILED"
}

n <- c(linked = 0L, copied = 0L, exists = 0L, missing = 0L, FAILED = 0L)
for (i in seq_along(MAP)) {
  to   <- file.path(ROOT, names(MAP)[i])
  from <- file.path(ROOT, MAP[[i]])
  if (!file.exists(from)) { n["missing"] <- n["missing"] + 1L
    msg("  MISSING in repository: ", MAP[[i]]); next }
  r <- link_or_copy(from, to); n[r] <- n[r] + 1L
}
msg("data files: ", n["linked"], " linked, ", n["copied"], " copied, ",
    n["exists"], " already present, ", n["missing"], " missing")

# result tables are read by the figure scripts
tb <- list.files(file.path(ROOT, "tables"), pattern = "\\.csv$", full.names = TRUE)
for (f in tb) link_or_copy(f, file.path(ROOT, "analysis_final/tables", basename(f)))
msg("result tables staged: ", length(tb))

msg("workspace ready. Next: Rscript --no-init-file tests/smoke_test.R")
