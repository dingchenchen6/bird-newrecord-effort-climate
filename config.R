# ============================================================
# config.R — paths to external archives that are NOT redistributed here
# ============================================================
# Scripts 81–90, 110, 120 and 127 rebuild the analysis from primary sources.
# Those sources are large and/or third-party licensed and are therefore not
# included in this repository. Set the paths below to your own copies, then
# `source("config.R")` at the top of those scripts (they do this automatically
# when the file is present).
#
# Scripts 121–126 and 128 do NOT need any of this: they run entirely on the
# data shipped in the repository after `Rscript setup_workspace.R`.
#
# Environment variables of the same name override these defaults, so the paths
# can also be set without editing this file:
#   export CBNR_BOTW=/path/to/BOTW_clean.gpkg
# ============================================================

.p <- function(var, default) {
  v <- Sys.getenv(var, unset = "")
  if (nzchar(v)) v else default
}

CFG <- list(

  # --- Species range polygons (BirdLife International, clipped to China) -----
  # Not redistributable. Obtain from http://datazone.birdlife.org/species/requestdis
  BOTW = .p("CBNR_BOTW",
            "~/data/BOTW_clean.gpkg"),

  # --- CRU TS 4.09 monthly climate (NetCDF) ---------------------------------
  # https://crudata.uea.ac.uk/cru/data/hrg/  (also on CEDA)
  CRU_TMP = .p("CBNR_CRU_TMP",
               "~/data/cru_ts/cru_ts4.09.1901.2024.tmp.dat.nc"),

  # --- WorldClim 2.1 downscaling of CRU TS 4.09 (10 arc-min monthly) --------
  # https://www.worldclim.org/data/monthlywth.html
  # Expected subfolders: historical_tmin/, historical_tmax/, historical_prec/,
  #                      baseline_tavg/, baseline_prec/
  WORLDCLIM_10M = .p("CBNR_WORLDCLIM",
                     "~/data/worldclim_10m/unzipped"),

  # --- CMIP6 future bioclimatic surfaces (WorldClim downscaling) ------------
  # https://www.worldclim.org/data/cmip6/cmip6climate.html
  CMIP6 = .p("CBNR_CMIP6",
             "~/data/cmip6_worldclim"),

  # --- 100 km analysis grid for China (sf object, EPSG:4326) ----------------
  # Regenerable: a regular 100 km grid intersected with the national boundary.
  GRID_100KM = .p("CBNR_GRID",
                  "~/data/china_grid_100km_v2.rds"),

  # --- Official base map, GS(2019)1822 --------------------------------------
  # Provincial boundaries, national outline and South China Sea nine-dash line.
  # Required only for the map figures (scripts 122, 126).
  # Source: Ministry of Natural Resources standard map service,
  #         http://bzdt.ch.mnr.gov.cn/
  BASEMAP = .p("CBNR_BASEMAP",
               "~/data/basemap_GS2019_1822"),

  # --- Upstream event, SDM and effort archives ------------------------------
  # CBNR event table, species-distribution-model outputs and the province-year
  # survey-effort compilation. Needed only by scripts 81–90.
  CBNR_EVENTS = .p("CBNR_EVENTS", "~/data/cbnr/events_100km_grid_assigned.csv"),
  SDM_ROOT    = .p("CBNR_SDM",    "~/data/bird_new_record_hazard_model"),
  EFFORT_ROOT = .p("CBNR_EFFORT", "~/data/bird_survey_effort_integration")
)

# Report which external inputs are actually resolvable, without failing.
cfg_status <- function() {
  x <- vapply(CFG, function(p) file.exists(path.expand(p)), logical(1))
  data.frame(input = names(CFG), path = unlist(CFG), available = x, row.names = NULL)
}

if (identical(Sys.getenv("CFG_VERBOSE"), "1")) print(cfg_status())
