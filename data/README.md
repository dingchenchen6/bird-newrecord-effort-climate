# Data

Compact derived panels sufficient to reproduce the headline model. Raw occurrence records,
SDM outputs and climate rasters are not redistributed (licensing and size).

| File | Content |
|---|---|
| `components_tavg_annual_W15.parquet` | species x province x year climate components (`x`, `b_static`, `clim_change`, `clim_var`) for the final specification (annual mean temperature, 15-yr window) |
| `effort_province_year_rebuilt.csv` | province-year survey-effort panel with `effort_status` (observed / structural_zero / no_data) and all proxies |
| `species_native_anom_panel.csv` | species x year native-range temperature anomaly (394 species x 23 years, complete) |
| `panel_full_species.csv.gz` | full 1980-2024 species-range annual temperature series used to build the rolling windows |
| `list_excluded_vagrants.csv` | the 69 species without a Chinese historical range that were excluded |

The species x province x year risk sets themselves are rebuilt by `code/83_rebuild_corrected_risksets.R`
and `code/90_build_modelling_datasets.R` from the upstream archives.
