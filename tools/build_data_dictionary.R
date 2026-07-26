suppressPackageStartupMessages({library(data.table); library(arrow)})
out <- c("# Data dictionary","",
"Generated directly from the shipped files by `tests/../docs` build step; every column is listed",
"with its storage type and a one-line meaning.","")
desc <- list(
 species="Scientific name, harmonised across Catalogue of Life China, HBW/BirdLife and eBird/Clements",
 province="Provincial-level administrative unit (English name)",
 year="Calendar year of the exposure row (2002-2024)",
 year_c="year minus 2013 (centred)",
 event="1 if the first record for this species-province pair occurred in this year, otherwise 0",
 threshold="SDM binarisation threshold defining the candidate pool (50 / 100 / 200)",
 effort_status="observed | structural_zero | no_data (see Methods)",
 mig_grp="Migratory stratum: Resident / Partial / Long-distance / Unknown",
 temp_native_anom="Annual temperature anomaly over the species' Chinese range, relative to 1980-2000 (degC)",
 native_baseline="1980-2000 mean annual temperature over the species' Chinese range (degC)",
 prov_temp_anom="Provincial annual temperature anomaly relative to 1980-2000 (degC)",
 prov_prec_anom="Provincial annual precipitation anomaly relative to the WorldClim 1970-2000 climatology (mm)",
 temp_anom_grad="prov_temp_anom minus temp_native_anom: species-referenced climate gradient (degC)",
 climate_z="Standardised headline climate term entering the model",
 prov_anom_z="Standardised provincial anomaly, retained as a reference term",
 effort_z="Standardised headline survey-effort term (observer visits, log1p)",
 eff_visits="Standardised log1p number of observer visits",
 eff_records="Standardised log1p number of records",
 eff_observers="Standardised log1p number of distinct observers",
 eff_days="Standardised log1p number of birding-days",
 eff_pca="Standardised first principal component of the four effort proxies",
 x="Species-referenced climate gradient for this file's indicator (degC)",
 b_static="T_base(province) minus N_base(species): historical climate mismatch (degC, time-invariant)",
 clim_change="Trailing W-year mean of x: accumulated climate change (degC)",
 clim_var="x minus clim_change: interannual climate variability (degC)",
 grid_cell="100 km analysis grid cell identifier",
 baseline="1980-2000 mean of the indicator for this unit",
 annual_temp="Annual mean temperature for this unit and year (degC)",
 n_cells="Number of 100 km grid cells covered by the unit",
 mainland="TRUE for mainland provincial units",
 in_scope="TRUE if the unit lies inside the analysis scope",
 observed="TRUE if the province-year appears in the source effort panel",
 olap="Area of overlap used to assign a grid cell to a province (m^2)",
 reason="Why the species was excluded",
 effort_record="Number of records in the province-year (raw count; 0 = structural zero)",
 n_visits="Number of observer visits in the province-year (raw count)",
 n_observers="Number of distinct observers in the province-year (raw count)",
 n_birding_days="Number of birding-days in the province-year (raw count)",
 effort_pc1="First principal component of the four raw effort proxies",
 log_effort_record="log1p(effort_record)",
 log_n_visits="log1p(n_visits)",
 log_n_observers="log1p(n_observers)",
 log_n_birding_days="log1p(n_birding_days)",
 temp_anom="Annual mean temperature anomaly relative to 1980-2000 (degC), CRU-rebuilt",
 prec_anom="Annual precipitation anomaly relative to the WorldClim 1970-2000 climatology (mm), legacy panel",
 prec_grad_prov="Provincial precipitation gradient term (legacy panel; retained for provenance, not used)",
 warming_rate="15-year rolling linear temperature trend ending in this year (degC per decade)",
 temp_sd_roll="15-year rolling standard deviation of annual temperature (degC)",
 climate_exposure="|warming_rate/10| / temp_sd_roll: signal-to-noise ratio of local warming",
 thermal_novelty="|temp_anom| / baseline_sd: departure expressed in baseline interannual SDs",
 climate_velocity="|warming_rate/10| / spatial_temp_grad: gradient-based climate velocity (km per year)",
 spatial_temp_grad="Spatial gradient of the baseline temperature field (degC per km; static by construction)",
 spatial_prec_grad="Spatial gradient of the baseline precipitation field (legacy panel; static)",
 precip_velocity="Precipitation analogue of climate_velocity (legacy panel; province-constant, not identifiable)",
 mahalanobis_dist="Multivariate climatic displacement from the legacy panel; retained for provenance, not used"
)
fs <- list.files("data", pattern = "[.](parquet|csv)$", full.names = TRUE)
for (f in sort(fs)) {
  if (grepl("README", f)) next
  d <- tryCatch(if (grepl("parquet$", f)) as.data.table(read_parquet(f)) else fread(f),
                error = function(e) NULL)
  if (is.null(d)) next
  out <- c(out, sprintf("## `data/%s`", basename(f)), "",
           sprintf("%d columns, %s rows", ncol(d), format(nrow(d), big.mark = ",")), "",
           "| column | type | meaning |", "|---|---|---|")
  for (cn in names(d)) {
    ty <- class(d[[cn]])[1]
    dc <- if (!is.null(desc[[cn]])) desc[[cn]] else if (grepl("_z$", cn)) "Standardised (z-scored) covariate" else "-"
    out <- c(out, sprintf("| `%s` | %s | %s |", cn, ty, dc))
  }
  out <- c(out, "")
}
writeLines(out, "docs/DATA_DICTIONARY.md")
cat("wrote docs/DATA_DICTIONARY.md with", length(out), "lines\n")
