# Figures

Every figure ships as **PNG (450 dpi) + vector PDF + editable PPTX + source-data CSV**.
PPTX files are generated with `rvg::dml()`, so each element is a native PowerPoint shape and
can be recoloured, retyped or rearranged directly in PowerPoint.

## main/ — primary results
| Figure | Content |
|---|---|
| `Fig1_main_results` | (a) coefficient forest across three SDM thresholds; (b) interaction as marginal effect curves; (c) relative importance |
| `Fig2_specification_robustness` | (a) climate indicator x accumulation window; (b) dAIC; (c) five effort proxies |
| `Fig3_model_ladder` | model selection ladder with the selected model annotated |
| `FigS1_dharma_panel` | DHARMa residual diagnostics (six panels) |

## alternative/ — alternative visual encodings of the same results
| Figure | Content |
|---|---|
| `FigA1_interaction_surface` | filled iso-hazard surface over (climate change x effort) with observed events overlaid |
| `FigA2_specification_landscape` | heatmap of HR and dAIC across indicators and windows |
| `FigA3_akaike_weights` | model evidence as Akaike weights instead of dAIC |
| `FigA4_effort_dumbbell` | dumbbell comparison of main and interaction effects across effort proxies |
| `FigA5_importance_waterfall` | cumulative deviance contribution |

## future/ — CMIP6 scenario projections
| Figure | Content |
|---|---|
| `FigM1_future_mechanistic` | mechanistic hazard relative to 2024, SSP x horizon |
| `FigM2_future_ml` | machine-learning projection, identical layout |
| `FigM3_shap_interpretability` | TreeSHAP global importance and dependence |
| `FigM4_mech_vs_ml_agreement` | province-level agreement and divergence map |

Maps carry the official GS(2019)1822 national boundary and South China Sea nine-dash line.
SVG versions are omitted from the repository (map SVGs exceed 60 MB each) and are regenerated
by the figure scripts.
