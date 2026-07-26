#!/usr/bin/env Rscript
# ============================================================
# tests/smoke_test.R — verify the repository can reproduce the headline result
# ============================================================
# Checks, in order:
#   1. required R packages are installed
#   2. the working layout exists (run setup_workspace.R first)
#   3. every input needed by the self-contained scripts is present
#   4. the shipped modelling data reproduce the published sample sizes
#   5. refitting the final model reproduces the published coefficients
#
# Run:  Rscript --no-init-file tests/smoke_test.R
# Takes about two minutes; nothing is written outside a temporary directory.
# ============================================================

ok <- TRUE
say <- function(status, ...) {
  cat(sprintf("  [%s] ", status), ..., "\n", sep = "")
  if (status == "FAIL") ok <<- FALSE
}

cat("\n=== 1. R packages ===\n")
need <- c("data.table", "arrow", "glmmTMB")
opt  <- c("ggplot2", "patchwork", "sf", "terra", "DHARMa", "performance",
          "xgboost", "pROC", "officer", "rvg", "exactextractr")
for (p in need)
  say(if (requireNamespace(p, quietly = TRUE)) "PASS" else "FAIL",
      sprintf("%-14s %s", p, if (requireNamespace(p, quietly = TRUE))
        as.character(packageVersion(p)) else "MISSING (required)"))
for (p in opt)
  say(if (requireNamespace(p, quietly = TRUE)) "PASS" else "WARN",
      sprintf("%-14s %s", p, if (requireNamespace(p, quietly = TRUE))
        as.character(packageVersion(p)) else "missing (needed for figures/maps only)"))

cat("\n=== 2. working layout ===\n")
need_dirs <- c("analysis_species_specific/data", "analysis_final/data", "analysis_final/tables")
for (d in need_dirs)
  say(if (dir.exists(d)) "PASS" else "FAIL",
      sprintf("%-38s %s", d, if (dir.exists(d)) "present" else "MISSING — run setup_workspace.R"))
if (!all(dir.exists(need_dirs))) { cat("\nAborting: run `Rscript --no-init-file setup_workspace.R` first.\n"); quit(status = 1) }

cat("\n=== 3. inputs for the self-contained pipeline (scripts 121-126, 128) ===\n")
inputs <- c(
  "analysis_species_specific/data/model_thr50.parquet",
  "analysis_species_specific/data/model_thr100.parquet",
  "analysis_species_specific/data/model_thr200.parquet",
  "analysis_final/data/components_tavg_annual_W5.parquet",
  "analysis_final/data/components_tavg_annual_W10.parquet",
  "analysis_final/data/components_tavg_annual_W15.parquet",
  "analysis_final/data/components_tavg_annual_W20.parquet",
  "analysis_final/tables/tbl_A_indicator_window.csv",
  "analysis_final/tables/tbl_D_ladder.csv",
  "analysis_final/tables/tbl_E_importance.csv")
for (f in inputs)
  say(if (file.exists(f)) "PASS" else "FAIL", basename(f))

cat("\n=== 4. shipped data reproduce published sample sizes ===\n")
suppressPackageStartupMessages({ library(data.table); library(arrow) })
b   <- as.data.table(read_parquet("analysis_species_specific/data/model_thr50.parquet"))
cmp <- as.data.table(read_parquet("analysis_final/data/components_tavg_annual_W15.parquet"))
d <- merge(b, cmp[, .(species, province, year, clim_change, clim_var)],
           by = c("species", "province", "year"))
d <- d[is.finite(clim_change) & is.finite(clim_var) & is.finite(eff_visits)]

chk <- function(lab, got, want, tol = 0) {
  hit <- abs(got - want) <= tol
  say(if (hit) "PASS" else "FAIL", sprintf("%-26s got %s, expected %s", lab, got, want))
}
chk("modelling rows",    nrow(d),              182485)
chk("events",            sum(d$event),         655)
chk("species",           uniqueN(d$species),   394)
chk("provincial units",  uniqueN(d$province),  31)

cat("\n=== 5. final model reproduces published coefficients ===\n")
suppressPackageStartupMessages(library(glmmTMB))
d[, `:=`(clim_change_z = as.numeric(scale(clim_change)),
         clim_var_z    = as.numeric(scale(clim_var)),
         effort_z      = as.numeric(scale(eff_visits)))]
cat("  fitting (about 90 s) ...\n")
m <- glmmTMB(event ~ clim_change_z * effort_z + clim_var_z + (1|species) + (1|province),
             data = d, family = binomial("cloglog"))
cf <- fixef(m)$cond
hr <- function(t) exp(cf[[t]])
int_name <- grep(":", names(cf), value = TRUE)[1]

chk2 <- function(lab, got, want, tol) {
  hit <- abs(got - want) <= tol
  say(if (hit) "PASS" else "FAIL",
      sprintf("%-26s HR = %.3f, expected %.3f (+/- %.3f)", lab, got, want, tol))
}
chk2("survey effort",            hr("effort_z"),      1.788, 0.02)
chk2("accumulated climate",      hr("clim_change_z"), 1.394, 0.02)
chk2("annual climate variability", hr("clim_var_z"),  0.850, 0.02)
chk2("climate x effort",         hr(int_name),        0.876, 0.02)

cat("\n============================================================\n")
# NB: keep `else` on the same line as the closing brace — a top-level
# `cat(...)` followed by a line starting with `else` is a parse error in R.
if (ok) {
  cat("SMOKE TEST PASSED - the shipped data reproduce the published headline model.\n")
} else {
  cat("SMOKE TEST FAILED - see [FAIL] lines above.\n")
}
cat("============================================================\n")
quit(status = if (ok) 0 else 1)
