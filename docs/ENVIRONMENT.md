# Computational environment

The analysis was produced and verified under the following environment. Scripts are run with
`Rscript --no-init-file` so that no user profile is sourced.

```
R version 4.5.1 (2025-06-13)
Platform: aarch64-apple-darwin20 (macOS, Apple silicon)
```

## Required packages

| Package | Version | Needed for |
|---|---|---|
| data.table | 1.18.4 | all scripts |
| arrow | 24.0.0 | reading/writing `.parquet` |
| glmmTMB | 1.1.14 | all hazard models |
| ggplot2 | 4.0.1 | figures |
| patchwork | 1.3.2 | multi-panel figures |
| sf | 1.0.23 | spatial joins, maps |
| terra | 1.8.86 | raster handling |
| exactextractr | 0.10.1 | zonal extraction (upstream scripts only) |
| officer | 0.7.4 | editable PPTX export |
| rvg | 0.4.2 | editable PPTX export |
| xgboost | 3.2.1.1 | machine-learning comparison |
| pROC | 1.19.0.1 | AUC |
| DHARMa | 0.4.7 | residual diagnostics |
| performance | 0.15.2 | marginal / conditional R² |
| climetrics | 1.0.15 | conceptual reference only — its numerical output is **not** used (see Methods) |
| scales, viridisLite | 1.4.0, 0.4.2 | figure scales |

Install with:

```r
install.packages(c("data.table","arrow","glmmTMB","ggplot2","patchwork","sf","terra",
                   "exactextractr","officer","rvg","xgboost","pROC","DHARMa",
                   "performance","scales","viridisLite"))
```

## Reproducibility notes

- **Runtime.** A single `glmmTMB` fit on the 182,485-row threshold-50 dataset takes roughly
  60–90 s on the reference machine. Script 121 fits ~45 models and takes about 1.5 h; it writes
  results incrementally and skips completed rows if restarted.
- **Determinism.** Seeds are set where randomness enters (cross-validation folds, XGBoost
  subsampling, DHARMa simulation). `glmmTMB` optimisation is deterministic given the data.
- **Numerical tolerance.** `tests/smoke_test.R` accepts hazard ratios within ±0.02 of the
  published values, which comfortably covers cross-platform optimiser differences.
- **Known platform issue.** With `--no-init-file` the PROJ database may not be discoverable, in
  which case `terra::project()` fails. This affects only optional reprojection steps; all analyses
  in this repository run in geographic coordinates with explicit latitude correction where
  distances matter.
