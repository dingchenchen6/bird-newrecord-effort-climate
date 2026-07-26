# Data dictionary

Generated directly from the shipped files by `tests/../docs` build step; every column is listed
with its storage type and a one-line meaning.

## `data/climate_province_year_assembled.csv`

29 columns, 782 rows

| column | type | meaning |
|---|---|---|
| `province` | character | Provincial-level administrative unit (English name) |
| `year` | integer | Calendar year of the exposure row (2002-2024) |
| `mainland` | logical | TRUE for mainland provincial units |
| `climate_z` | numeric | Standardised headline climate term entering the model |
| `temp_anom` | numeric | Annual mean temperature anomaly relative to 1980-2000 (degC), CRU-rebuilt |
| `warming_rate` | numeric | 15-year rolling linear temperature trend ending in this year (degC per decade) |
| `climate_exposure` | numeric | |warming_rate/10| / temp_sd_roll: signal-to-noise ratio of local warming |
| `climate_velocity` | numeric | |warming_rate/10| / spatial_temp_grad: gradient-based climate velocity (km per year) |
| `thermal_novelty` | numeric | |temp_anom| / baseline_sd: departure expressed in baseline interannual SDs |
| `temp_sd_roll` | numeric | 15-year rolling standard deviation of annual temperature (degC) |
| `spatial_temp_grad` | numeric | Spatial gradient of the baseline temperature field (degC per km; static by construction) |
| `prec_anom` | numeric | Annual precipitation anomaly relative to the WorldClim 1970-2000 climatology (mm), legacy panel |
| `prec_grad_prov` | numeric | Provincial precipitation gradient term (legacy panel; retained for provenance, not used) |
| `precip_velocity` | numeric | Precipitation analogue of climate_velocity (legacy panel; province-constant, not identifiable) |
| `spatial_prec_grad` | numeric | Spatial gradient of the baseline precipitation field (legacy panel; static) |
| `mahalanobis_dist` | numeric | Multivariate climatic displacement from the legacy panel; retained for provenance, not used |
| `in_scope` | logical | TRUE if the unit lies inside the analysis scope |
| `temp_anom_z` | numeric | Standardised (z-scored) covariate |
| `warming_rate_z` | numeric | Standardised (z-scored) covariate |
| `climate_exposure_z` | numeric | Standardised (z-scored) covariate |
| `climate_velocity_z` | numeric | Standardised (z-scored) covariate |
| `thermal_novelty_z` | numeric | Standardised (z-scored) covariate |
| `temp_sd_roll_z` | numeric | Standardised (z-scored) covariate |
| `spatial_temp_grad_z` | numeric | Standardised (z-scored) covariate |
| `prec_anom_z` | numeric | Standardised (z-scored) covariate |
| `prec_grad_prov_z` | numeric | Standardised (z-scored) covariate |
| `precip_velocity_z` | numeric | Standardised (z-scored) covariate |
| `spatial_prec_grad_z` | numeric | Standardised (z-scored) covariate |
| `mahalanobis_dist_z` | numeric | Standardised (z-scored) covariate |

## `data/components_tavg_annual_W10.parquet`

7 columns, 187,473 rows

| column | type | meaning |
|---|---|---|
| `species` | character | Scientific name, harmonised across Catalogue of Life China, HBW/BirdLife and eBird/Clements |
| `province` | character | Provincial-level administrative unit (English name) |
| `year` | integer | Calendar year of the exposure row (2002-2024) |
| `x` | numeric | Species-referenced climate gradient for this file's indicator (degC) |
| `b_static` | numeric | T_base(province) minus N_base(species): historical climate mismatch (degC, time-invariant) |
| `clim_change` | numeric | Trailing W-year mean of x: accumulated climate change (degC) |
| `clim_var` | numeric | x minus clim_change: interannual climate variability (degC) |

## `data/components_tavg_annual_W15.parquet`

7 columns, 187,473 rows

| column | type | meaning |
|---|---|---|
| `species` | character | Scientific name, harmonised across Catalogue of Life China, HBW/BirdLife and eBird/Clements |
| `province` | character | Provincial-level administrative unit (English name) |
| `year` | integer | Calendar year of the exposure row (2002-2024) |
| `x` | numeric | Species-referenced climate gradient for this file's indicator (degC) |
| `b_static` | numeric | T_base(province) minus N_base(species): historical climate mismatch (degC, time-invariant) |
| `clim_change` | numeric | Trailing W-year mean of x: accumulated climate change (degC) |
| `clim_var` | numeric | x minus clim_change: interannual climate variability (degC) |

## `data/components_tavg_annual_W20.parquet`

7 columns, 187,473 rows

| column | type | meaning |
|---|---|---|
| `species` | character | Scientific name, harmonised across Catalogue of Life China, HBW/BirdLife and eBird/Clements |
| `province` | character | Provincial-level administrative unit (English name) |
| `year` | integer | Calendar year of the exposure row (2002-2024) |
| `x` | numeric | Species-referenced climate gradient for this file's indicator (degC) |
| `b_static` | numeric | T_base(province) minus N_base(species): historical climate mismatch (degC, time-invariant) |
| `clim_change` | numeric | Trailing W-year mean of x: accumulated climate change (degC) |
| `clim_var` | numeric | x minus clim_change: interannual climate variability (degC) |

## `data/components_tavg_annual_W5.parquet`

7 columns, 187,473 rows

| column | type | meaning |
|---|---|---|
| `species` | character | Scientific name, harmonised across Catalogue of Life China, HBW/BirdLife and eBird/Clements |
| `province` | character | Provincial-level administrative unit (English name) |
| `year` | integer | Calendar year of the exposure row (2002-2024) |
| `x` | numeric | Species-referenced climate gradient for this file's indicator (degC) |
| `b_static` | numeric | T_base(province) minus N_base(species): historical climate mismatch (degC, time-invariant) |
| `clim_change` | numeric | Trailing W-year mean of x: accumulated climate change (degC) |
| `clim_var` | numeric | x minus clim_change: interannual climate variability (degC) |

## `data/effort_province_year_rebuilt.csv`

20 columns, 782 rows

| column | type | meaning |
|---|---|---|
| `province` | character | Provincial-level administrative unit (English name) |
| `year` | integer | Calendar year of the exposure row (2002-2024) |
| `effort_status` | character | observed | structural_zero | no_data (see Methods) |
| `mainland` | logical | TRUE for mainland provincial units |
| `observed` | logical | TRUE if the province-year appears in the source effort panel |
| `effort_record` | integer | Number of records in the province-year (raw count; 0 = structural zero) |
| `n_visits` | integer | Number of observer visits in the province-year (raw count) |
| `n_observers` | integer | Number of distinct observers in the province-year (raw count) |
| `n_birding_days` | integer | Number of birding-days in the province-year (raw count) |
| `effort_pc1` | numeric | First principal component of the four raw effort proxies |
| `log_effort_record_z` | numeric | Standardised (z-scored) covariate |
| `log_effort_visits_z` | numeric | Standardised (z-scored) covariate |
| `log_effort_observers_z` | numeric | Standardised (z-scored) covariate |
| `log_effort_days_z` | numeric | Standardised (z-scored) covariate |
| `effort_pc1_z` | numeric | Standardised (z-scored) covariate |
| `in_scope` | logical | TRUE if the unit lies inside the analysis scope |
| `log_effort_record` | numeric | log1p(effort_record) |
| `log_n_visits` | numeric | log1p(n_visits) |
| `log_n_observers` | numeric | log1p(n_observers) |
| `log_n_birding_days` | numeric | log1p(n_birding_days) |

## `data/grid_province_lookup.csv`

3 columns, 1,697 rows

| column | type | meaning |
|---|---|---|
| `grid_cell` | integer | 100 km analysis grid cell identifier |
| `province` | character | Provincial-level administrative unit (English name) |
| `olap` | numeric | Area of overlap used to assign a grid cell to a province (m^2) |

## `data/list_excluded_vagrants.csv`

2 columns, 69 rows

| column | type | meaning |
|---|---|---|
| `species` | character | Scientific name, harmonised across Catalogue of Life China, HBW/BirdLife and eBird/Clements |
| `reason` | character | Why the species was excluded |

## `data/model_thr100.parquet`

21 columns, 171,353 rows

| column | type | meaning |
|---|---|---|
| `species` | character | Scientific name, harmonised across Catalogue of Life China, HBW/BirdLife and eBird/Clements |
| `province` | character | Provincial-level administrative unit (English name) |
| `year` | integer | Calendar year of the exposure row (2002-2024) |
| `year_c` | integer | year minus 2013 (centred) |
| `event` | integer | 1 if the first record for this species-province pair occurred in this year, otherwise 0 |
| `threshold` | integer | SDM binarisation threshold defining the candidate pool (50 / 100 / 200) |
| `effort_status` | character | observed | structural_zero | no_data (see Methods) |
| `mig_grp` | factor | Migratory stratum: Resident / Partial / Long-distance / Unknown |
| `temp_native_anom` | numeric | Annual temperature anomaly over the species' Chinese range, relative to 1980-2000 (degC) |
| `native_baseline` | numeric | 1980-2000 mean annual temperature over the species' Chinese range (degC) |
| `prov_temp_anom` | numeric | Provincial annual temperature anomaly relative to 1980-2000 (degC) |
| `prov_prec_anom` | numeric | Provincial annual precipitation anomaly relative to the WorldClim 1970-2000 climatology (mm) |
| `temp_anom_grad` | numeric | prov_temp_anom minus temp_native_anom: species-referenced climate gradient (degC) |
| `climate_z` | numeric | Standardised headline climate term entering the model |
| `prov_anom_z` | numeric | Standardised provincial anomaly, retained as a reference term |
| `effort_z` | numeric | Standardised headline survey-effort term (observer visits, log1p) |
| `eff_visits` | numeric | Standardised log1p number of observer visits |
| `eff_records` | numeric | Standardised log1p number of records |
| `eff_observers` | numeric | Standardised log1p number of distinct observers |
| `eff_days` | numeric | Standardised log1p number of birding-days |
| `eff_pca` | numeric | Standardised first principal component of the four effort proxies |

## `data/model_thr200.parquet`

21 columns, 161,187 rows

| column | type | meaning |
|---|---|---|
| `species` | character | Scientific name, harmonised across Catalogue of Life China, HBW/BirdLife and eBird/Clements |
| `province` | character | Provincial-level administrative unit (English name) |
| `year` | integer | Calendar year of the exposure row (2002-2024) |
| `year_c` | integer | year minus 2013 (centred) |
| `event` | integer | 1 if the first record for this species-province pair occurred in this year, otherwise 0 |
| `threshold` | integer | SDM binarisation threshold defining the candidate pool (50 / 100 / 200) |
| `effort_status` | character | observed | structural_zero | no_data (see Methods) |
| `mig_grp` | factor | Migratory stratum: Resident / Partial / Long-distance / Unknown |
| `temp_native_anom` | numeric | Annual temperature anomaly over the species' Chinese range, relative to 1980-2000 (degC) |
| `native_baseline` | numeric | 1980-2000 mean annual temperature over the species' Chinese range (degC) |
| `prov_temp_anom` | numeric | Provincial annual temperature anomaly relative to 1980-2000 (degC) |
| `prov_prec_anom` | numeric | Provincial annual precipitation anomaly relative to the WorldClim 1970-2000 climatology (mm) |
| `temp_anom_grad` | numeric | prov_temp_anom minus temp_native_anom: species-referenced climate gradient (degC) |
| `climate_z` | numeric | Standardised headline climate term entering the model |
| `prov_anom_z` | numeric | Standardised provincial anomaly, retained as a reference term |
| `effort_z` | numeric | Standardised headline survey-effort term (observer visits, log1p) |
| `eff_visits` | numeric | Standardised log1p number of observer visits |
| `eff_records` | numeric | Standardised log1p number of records |
| `eff_observers` | numeric | Standardised log1p number of distinct observers |
| `eff_days` | numeric | Standardised log1p number of birding-days |
| `eff_pca` | numeric | Standardised first principal component of the four effort proxies |

## `data/model_thr50.parquet`

21 columns, 186,602 rows

| column | type | meaning |
|---|---|---|
| `species` | character | Scientific name, harmonised across Catalogue of Life China, HBW/BirdLife and eBird/Clements |
| `province` | character | Provincial-level administrative unit (English name) |
| `year` | integer | Calendar year of the exposure row (2002-2024) |
| `year_c` | integer | year minus 2013 (centred) |
| `event` | integer | 1 if the first record for this species-province pair occurred in this year, otherwise 0 |
| `threshold` | integer | SDM binarisation threshold defining the candidate pool (50 / 100 / 200) |
| `effort_status` | character | observed | structural_zero | no_data (see Methods) |
| `mig_grp` | factor | Migratory stratum: Resident / Partial / Long-distance / Unknown |
| `temp_native_anom` | numeric | Annual temperature anomaly over the species' Chinese range, relative to 1980-2000 (degC) |
| `native_baseline` | numeric | 1980-2000 mean annual temperature over the species' Chinese range (degC) |
| `prov_temp_anom` | numeric | Provincial annual temperature anomaly relative to 1980-2000 (degC) |
| `prov_prec_anom` | numeric | Provincial annual precipitation anomaly relative to the WorldClim 1970-2000 climatology (mm) |
| `temp_anom_grad` | numeric | prov_temp_anom minus temp_native_anom: species-referenced climate gradient (degC) |
| `climate_z` | numeric | Standardised headline climate term entering the model |
| `prov_anom_z` | numeric | Standardised provincial anomaly, retained as a reference term |
| `effort_z` | numeric | Standardised headline survey-effort term (observer visits, log1p) |
| `eff_visits` | numeric | Standardised log1p number of observer visits |
| `eff_records` | numeric | Standardised log1p number of records |
| `eff_observers` | numeric | Standardised log1p number of distinct observers |
| `eff_days` | numeric | Standardised log1p number of birding-days |
| `eff_pca` | numeric | Standardised first principal component of the four effort proxies |

## `data/species_native_anom_panel.csv`

6 columns, 9,062 rows

| column | type | meaning |
|---|---|---|
| `species` | character | Scientific name, harmonised across Catalogue of Life China, HBW/BirdLife and eBird/Clements |
| `year` | integer | Calendar year of the exposure row (2002-2024) |
| `n_cells` | integer | Number of 100 km grid cells covered by the unit |
| `baseline` | numeric | 1980-2000 mean of the indicator for this unit |
| `annual_temp` | numeric | Annual mean temperature for this unit and year (degC) |
| `temp_native_anom` | numeric | Annual temperature anomaly over the species' Chinese range, relative to 1980-2000 (degC) |

