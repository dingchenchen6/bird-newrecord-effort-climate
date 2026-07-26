# Decadal climate change raises the discovery rate of new bird distribution records, but only where survey effort is low

**Chen-Chen Ding**
Institute of Ecology, Peking University, Beijing, China
Correspondence: chenchending1992@gmail.com

---

## Abstract

New provincial distribution records are accumulating rapidly for Chinese birds, but it is
unclear whether they index intensifying observation or genuine range change. Using a
discrete-time survival framework over 182,485 species × province × year exposures and 655
first-record events (2002–2024), we separate the two processes by decomposing a
species-specific climate gradient into a backward-looking 15-year accumulation term and an
interannual variability term. Survey effort dominates, accounting for 78% of explained
deviance (hazard ratio 1.79 per standard deviation). Accumulated climate change nevertheless
raises hazard independently (HR 1.39), and does so most steeply where effort is low
(interaction HR 0.88). The climate signal requires at least a decade of accumulation: a
five-year window detects nothing. Gradient-based climate velocity shows no effect, and the
apparent strength of local climate novelty proves to be a time artefact. New records therefore
index both monitoring intensity and climate change, with the balance between them shifting
systematically along the survey-effort gradient.

**Keywords** citizen science · discrete-time survival · detection bias · range shift ·
climate velocity · China

---

## Introduction

Species are redistributing as the climate warms, and the rate at which they do so is now a
central quantity in ecology and conservation planning [1–4]. Range shifts are most often
inferred from repeated structured surveys, but such surveys are rare over the extents and
durations that matter. Increasingly, inference rests instead on opportunistic occurrence data
contributed by observers [5–7]. This creates a well-known inferential hazard: the same social
processes that generate the data — growth in participation, uneven spatial coverage, changing
observer skill — also generate apparent biological change [8–11].

New distribution records sit at the sharp end of this problem. A first record of a species in
an administrative unit is, by construction, a detection event. It can arise because the species
newly arrived, or because someone finally looked. In China the ambiguity is acute: the number
of new provincial bird records has risen steeply over the past two decades, and so has
participation in bird recording, by more than an order of magnitude. Whether the two are
causally linked, or merely coincident, determines whether new records can be read as an
indicator of climate-driven redistribution at all.

Two features of the problem have prevented a clean answer. First, survey effort and calendar
time are almost perfectly confounded in opportunistic datasets, so any monotonic biological
trend is difficult to distinguish from a monotonic sampling trend [8,12]. Second, the climate
covariate itself is usually specified as a contemporaneous anomaly — the deviation of a given
year from a baseline — which conflates two mechanistically distinct processes. Sustained
warming that gradually renders a region climatically accessible is not the same thing as an
anomalously warm year that triggers a single dispersal or detection event, and the two need
not act in the same direction.

Here we address both. We construct a complete discrete-time risk set in which every
species × province × year combination that could have produced a first record is retained, and
we model the hazard of a first record with a complementary log-log link. We then decompose a
species-specific climate gradient — the focal province's temperature anomaly relative to the
anomaly over that species' own Chinese range — into three orthogonal components: a static
historical mismatch, an accumulated change term computed from a strictly backward-looking
rolling window, and the residual interannual variability. This decomposition is the analytical
core of the study. We show that without it the accumulated and variability components cancel,
and the climate signal disappears entirely.

---

## Results

### A complete risk set

The analysis set comprises 182,485 species × province × year exposures, 655 first-record
events, 394 species and 32 provincial units over 2002–2024 (baseline event hazard 0.272% per
year). Species without a Chinese historical range (n = 69) were excluded because no
native-range climate baseline can be defined for them; the events analysed therefore represent
range expansion and newly detected populations rather than vagrancy. Province-years with no
recorded effort in mainland provinces were treated as structural zeros rather than missing
data — every raw effort measure has a minimum of one and contains no zeros, showing that the
panel is a record aggregation in which an inactive province-year simply produces no row.
Treating these as missing, as is conventional, silently discards the lower tail of the effort
distribution and, in this dataset, eleven genuine events.

### Survey effort dominates but does not exhaust the signal

In the final model (Fig. 1a) survey effort carries a hazard ratio of 1.788 per standard
deviation (95% CI 1.639–1.951, *P* = 7.7 × 10⁻³⁹). Accumulated climate change over the
preceding 15 years raises hazard independently, HR = 1.394 (1.244–1.562,
*P* = 1.0 × 10⁻⁸), while interannual climate variability acts in the opposite direction,
HR = 0.850 (0.781–0.926, *P* = 1.8 × 10⁻⁴). The interaction between accumulated change and
effort is negative, HR = 0.876 (0.801–0.959, *P* = 3.9 × 10⁻³): the climate gradient is
steepest in poorly surveyed provinces and flattens as effort rises (Fig. 1b).

Drop-term partitioning of explained deviance gives survey effort 78%, accumulated climate
change 15%, interannual variability 7% and the interaction 4%, with these shares stable across
all three species-distribution-model thresholds (Fig. 1c).

### The climate signal is decadal

The accumulation window matters more than the choice of climate variable (Fig. 2a,b). At a
five-year window the climate effect is indistinguishable from zero (HR = 1.054, *P* = 0.30).
It emerges at ten years (HR = 1.269, *P* = 1.6 × 10⁻⁵), peaks at fifteen
(HR = 1.397, *P* = 8.7 × 10⁻⁹; ΔAIC = −42.1 relative to an effort-only model) and plateaus at
twenty. New records therefore respond to sustained decadal warming rather than to individual
warm years — a result that also explains why contemporaneous anomalies have limited diagnostic
power in this setting.

Annual mean temperature outperformed seasonal and extreme indices. Warmest-month maximum
temperature carried a weaker signal (ΔAIC = −29.8) and neither winter mean temperature nor
coldest-month minimum temperature contributed under this decomposition.

### Robustness

Estimates were essentially invariant to the species-distribution-model binarisation threshold
(climate change HR 1.397 / 1.411 / 1.406 at thresholds 50 / 100 / 200; interaction 0.873 /
0.875 / 0.874) and to the choice of effort metric (climate change 1.371–1.408, all
*P* ≤ 5 × 10⁻⁸; interaction 0.839–0.895, all *P* ≤ 0.033 across records, visits, observers,
birding-days and a principal-component composite; Fig. 2c).

Model comparison (Fig. 3) placed the interaction model ahead of the additive model at every
threshold. Adding an interaction between effort and interannual variability did not improve fit
and was dropped. A pair-level frailty term produced a large nominal AIC gain but a degenerate
fit — species and province variances collapsed to zero, the pair standard deviation exceeded 11
on the log-hazard scale, and the effort hazard ratio inflated beyond 11 — a consequence of
complete separation at the pair level under rare events; it was rejected.

Residual diagnostics were satisfactory: uniformity *P* = 0.66, dispersion *P* = 0.41,
province-grouped residuals *P* = 0.96, temporal autocorrelation *P* = 0.62, spatial
autocorrelation *P* = 0.79. Year- and species-grouped residuals deviated
(*P* = 0.031 and 0.0011), indicating residual among-species heterogeneity in detectability.

### Standard climate-change operators do not reproduce the signal

We tested two operators widely used in the range-shift literature as alternatives to the
accumulation term. Gradient-based climate velocity [1,2], computed as the trailing 15-year
temperature trend divided by the latitude-corrected spatial temperature gradient of the
baseline field (median 2.11 km yr⁻¹), showed no effect at either the provincial or the
species-specific level (HR 0.95–0.97, *P* ≥ 0.34).

Local climate novelty [13,14], the standardized departure of the trailing window from the
baseline distribution, appeared far stronger at the provincial level (HR = 1.768,
*P* = 9.6 × 10⁻¹²). This is an artefact. Provincial novelty accumulates monotonically with
warming and is therefore highly correlated with calendar year (*r* = 0.73) and with survey
effort itself (*r* = 0.62); in the same model the effort hazard ratio collapses from 1.79 to
1.27, and adding a year term worsens fit. Its species-specific counterpart, which removes the
spatially common warming signal, is only marginal (HR = 1.114, *P* = 0.065).

By contrast, the accumulation term used here is almost uncorrelated with calendar year
(*r* = 0.066), precisely because it is differenced against the anomaly over each species' own
range. Among the operators examined it is the only one that is both strongly supported and free
of temporal confounding.

### Projections

Applying a four-model CMIP6 ensemble under SSP2-4.5 and SSP5-8.5, with the warming increment
applied to both the focal province and each species' range, the mechanistic model and a
gradient-boosted counterpart agree closely on the spatial pattern of change (Fig. 4).
Attribution differs, however: TreeSHAP [15,16] assigns survey effort 48.5% of mean absolute
attribution against 78% in the deviance partition, because the boosted trees lack random
effects and the climate features partly encode species and province identity. Late-century
projections extrapolate survey effort 1.7–3.4 standard deviations beyond the observed range and
should be read as scenario illustrations rather than forecasts.

---

## Discussion

New distribution records are not a clean signal of range change, but neither are they only an
artefact of observation. In this dataset survey effort accounts for roughly four-fifths of the
explained variation in whether and when a first record appears, which is a strong caution
against reading raw record counts as biological trend [8–11]. Yet after effort is controlled,
accumulated warming over the preceding decade still raises the hazard by about 39% per standard
deviation. The two processes are additive, not alternative.

The negative interaction has a straightforward reading. Where recording is intense, a species
present in a province will be detected sooner or later regardless of climate; effort saturates
the detection process and climate is not the limiting step. Where recording is sparse, detection
requires that the species become sufficiently common or sufficiently established for a chance
encounter, and climate-driven change in suitability is what makes that happen. The climate
signal is therefore most legible precisely in the regions where the data are weakest — an
inversion of the usual expectation, and one with practical consequences for where monitoring
investment yields ecological, as opposed to merely descriptive, information [17,18].

That the effect requires a decade of accumulation is consistent with the lags reported between
climate change and community-level responses in birds [19,20]. It also has a methodological
implication: studies that regress occurrence on contemporaneous annual anomalies are looking at
the wrong timescale, and — as we show — at a quantity in which the accumulation and variability
components partly cancel.

The failure of climate velocity here deserves comment. Velocity is a property of the climate
field, not of the species, and it describes how fast an isotherm moves across a landscape [1,2].
It has proved informative for aggregate biogeographic patterns [3,21], but it carries no
information about whether a given location is becoming more or less suitable for a given
species. The operator that does work in our setting is explicitly relational: the focal
province's anomaly relative to the anomaly over that species' own range. The contrast suggests
that for detection-based data at administrative resolution, species-referenced measures are more
useful than landscape-referenced ones.

The novelty result is a caution of a different kind. Provincial novelty produced the strongest
nominal effect in the entire study, and it is not real. Because it accumulates monotonically it
tracks calendar time, and therefore tracks the growth of recording effort, which is the very
confounder the analysis exists to remove. Any operator that increases monotonically over the
study period is vulnerable to this, and reporting its coefficient without a temporal-confounding
diagnostic would have been misleading.

Several limitations bound these conclusions. Survey effort and calendar year are collinear
(*r* = 0.79); including a linear year term attenuates the effort coefficient to 1.21 while
leaving the climate terms essentially unchanged, so the partition between "effort" and "time" is
not fully identified by these data. Events are resolved to province, which is coarse relative to
the ecological processes involved. Among-species heterogeneity in detectability remains in the
residuals. And precipitation, though assembled, contributed nothing under this decomposition.

The broader point is methodological. Opportunistic biodiversity data can support inference about
climate-driven change, but only when the observation process is modelled at the same level of
care as the ecological one, and when the climate covariate is specified at a timescale and in a
reference frame that match the hypothesised mechanism. In this study, changing the climate
operator from a contemporaneous anomaly to a decadal, species-referenced accumulation moved the
estimated effect from indistinguishable from zero to among the best-supported terms in the
model — without any change to the data.

---

## Methods

### Events and risk set

An event is the first documented occurrence of a species in a Chinese provincial unit between
2002 and 2024. The risk set is the full species × province × year expansion of the candidate
pool, with absorbing exit after the event. Candidates were defined as species–province pairs
with modelled potential presence and no historical presence, augmented by forced inclusion of
every observed event, and restricted to the union of species for which distribution models were
available. Model binarisation thresholds of 50, 100 and 200 suitable cells were carried through
the analysis as a sensitivity [22,23].

### Survey effort

Effort was compiled at province-year resolution from the union of eBird/GBIF records [5,24] and
the China Bird Report archive, and quantified with four observation proxies — number of records,
visits, distinct observers and birding-days — plus their first principal component. Counts were
log₁ₚ-transformed and standardized over the analysis population. Province-years absent from the
panel in mainland provinces were assigned zero effort; those in Taiwan and Macau were treated as
unmeasured and excluded, on the basis of recorded effort density per unit area (0.13 records
km⁻² for Taiwan against 29.7 for Beijing), which indicates a source-coverage gap rather than low
activity. Hong Kong, whose low absolute counts reflect its small area (16.5 records km⁻²), was
retained.

### Climate data and the species-specific gradient

Monthly minimum and maximum temperature at 10 arc-minutes for 1980–2024 were obtained from the
WorldClim 2.1 downscaling of CRU TS 4.09 [25,26]; annual means were derived as the mean of
monthly (Tmin + Tmax)/2. Species ranges were taken from BirdLife International polygons clipped
to China. For province *p*, species *s* and year *t*, with a 1980–2000 baseline,

  x(s,p,t) = [T(p,t) − T̄(p)] − [N(s,t) − N̄(s)],

where T is the area-weighted provincial mean and N the mean over the species' Chinese range.
This quantity is the province's anomaly expressed relative to the anomaly experienced across the
species' own range, and is therefore species-specific.

### Three-way decomposition

x was decomposed using strictly backward-looking information, as required for a covariate in a
survival model:

  clim_change(s,p,t) = mean of x over [t − W + 1, t]
  clim_var(s,p,t)    = x(s,p,t) − clim_change(s,p,t)
  b_static(s,p)      = T̄(p) − N̄(s)

with W ∈ {5, 10, 15, 20} years. Because the climate series extends back to 1980, all 23 analysis
years retain complete windows at every W. The static term was retained only as a sensitivity
check: it is a time-invariant pair-level quantity that indexes which provinces are climatically
suitable for a species in the first place, and the risk set is itself constructed from
distribution models, so it acts as a confounder rather than a mechanism.

### Statistical model

Hazard was modelled with a complementary log-log link, the canonical form for discrete-time
proportional hazards, using glmmTMB [27]:

  event ~ clim_change_z × effort_z + clim_var_z + (1 | species) + (1 | province)

All covariates were standardized within the analysis set, over event and non-event rows alike.
Random-effect structures including a year effect, random slopes for effort and for climate
sensitivity, and a species-by-province frailty were compared by AIC alongside convergence and
variance-component diagnostics. Residuals were assessed with simulation-based diagnostics
(DHARMa, 500 simulations), including grouped uniformity by province, year and species, and tests
for temporal and spatial autocorrelation.

### Alternative climate operators

Gradient-based velocity was computed as the ordinary-least-squares temperature trend over the
trailing window divided by the magnitude of the spatial gradient of the baseline temperature
field, the latter obtained by central differences with latitude correction and expressed in
°C km⁻¹, following Loarie et al. [1] and Burrows et al. [2]. Local novelty was computed as the
absolute departure of the trailing-window mean from the baseline mean, standardized by the
baseline interannual standard deviation [13,14]. Both were evaluated at provincial level and as
species-referenced differences. We note that the `climetrics` implementation of gradient velocity,
applied to unprojected geographic coordinates, returned values roughly four orders of magnitude
smaller than the latitude-corrected calculation and correlated with it at only *r* = 0.49; the
formulations above were therefore implemented directly.

### Projections and machine-learning comparison

Future covariates used the median of a four-model CMIP6 ensemble (ACCESS-CM2, MPI-ESM1-2-HR,
MIROC6, UKESM1-0-LL) under SSP2-4.5 and SSP5-8.5 for 2030, 2050 and 2080. The warming increment
was applied to both the provincial and the species-range terms; applying it only to the province
would manufacture a climate effect, because near-uniform warming cancels in a differenced
operator (measured increments differed by less than 0.1 °C between the two ends). Effort was
projected under scenario-differentiated growth. A gradient-boosted model [28] fitted to the same
three predictors was interpreted with exact TreeSHAP [15,16]. Spatial analyses used sf [29] and
terra; maps carry the GS(2019)1822 national boundary and South China Sea nine-dash line.

### Data and code availability

All analysis code, derived data panels, result tables and figures are available at
https://github.com/dingchenchen6/bird-newrecord-effort-climate. Figures are provided as
raster, vector and editable formats with accompanying source data.

---

## References

1. Loarie, S. R. et al. The velocity of climate change. *Nature* **462**, 1052–1055 (2009). https://doi.org/10.1038/nature08649
2. Burrows, M. T. et al. The pace of shifting climate in marine and terrestrial ecosystems. *Science* **334**, 652–655 (2011). https://doi.org/10.1126/science.1210288
3. Chen, I.-C., Hill, J. K., Ohlemüller, R., Roy, D. B. & Thomas, C. D. Rapid range shifts of species associated with high levels of climate warming. *Science* **333**, 1024–1026 (2011). https://doi.org/10.1126/science.1206432
4. Lenoir, J. et al. Species better track climate warming in the oceans than on land. *Nature Ecology & Evolution* **4**, 1044–1059 (2020). https://doi.org/10.1038/s41559-020-1198-2
5. Sullivan, B. L. et al. eBird: a citizen-based bird observation network in the biological sciences. *Biological Conservation* **142**, 2282–2292 (2009). https://doi.org/10.1016/j.biocon.2009.05.006
6. van Strien, A. J., van Swaay, C. A. M. & Termaat, T. Opportunistic citizen science data of animal species produce reliable estimates of distribution trends if analysed with occupancy models. *Journal of Applied Ecology* **50**, 1450–1458 (2013). https://doi.org/10.1111/1365-2664.12158
7. Callaghan, C. T., Poore, A. G. B., Major, R. E., Rowley, J. J. L. & Cornwell, W. K. Optimizing future biodiversity sampling by citizen scientists. *Proceedings of the Royal Society B* **286**, 20191487 (2019). https://doi.org/10.1098/rspb.2019.1487
8. Isaac, N. J. B., van Strien, A. J., August, T. A., de Zeeuw, M. P. & Roy, D. B. Statistics for citizen science: extracting signals of change from noisy ecological data. *Methods in Ecology and Evolution* **5**, 1052–1060 (2014). https://doi.org/10.1111/2041-210X.12254
9. Boakes, E. H. et al. Distorted views of biodiversity: spatial and temporal bias in species occurrence data. *PLoS Biology* **8**, e1000385 (2010). https://doi.org/10.1371/journal.pbio.1000385
10. Bird, T. J. et al. Statistical solutions for error and bias in global citizen science datasets. *Biological Conservation* **173**, 144–154 (2014). https://doi.org/10.1016/j.biocon.2013.07.037
11. Beck, J., Böller, M., Erhardt, A. & Schwanghart, W. Spatial bias in the GBIF database and its effect on modeling species' geographic distributions. *Ecological Informatics* **19**, 10–15 (2014). https://doi.org/10.1016/j.ecoinf.2013.11.002
12. Tingley, M. W. & Beissinger, S. R. Detecting range shifts from historical species occurrences: new perspectives on old data. *Trends in Ecology & Evolution* **24**, 625–633 (2009). https://doi.org/10.1016/j.tree.2009.05.009
13. Williams, J. W. & Jackson, S. T. Novel climates, no-analog communities, and ecological surprises. *Frontiers in Ecology and the Environment* **5**, 475–482 (2007). https://doi.org/10.1890/070037
14. Mahony, C. R., Cannon, A. J., Wang, T. & Aitken, S. N. A closer look at novel climates: new methods and insights at continental to landscape scales. *Global Change Biology* **23**, 3934–3955 (2017). https://doi.org/10.1111/gcb.13645
15. Lundberg, S. M. et al. From local explanations to global understanding with explainable AI for trees. *Nature Machine Intelligence* **2**, 56–67 (2020). https://doi.org/10.1038/s42256-019-0138-9
16. Chen, T. & Guestrin, C. XGBoost: a scalable tree boosting system. In *Proceedings of the 22nd ACM SIGKDD International Conference on Knowledge Discovery and Data Mining* 785–794 (2016). https://doi.org/10.1145/2939672.2939785
17. Amano, T., Lamming, J. D. L. & Sutherland, W. J. Spatial gaps in global biodiversity information and the role of citizen science. *BioScience* **66**, 393–400 (2016). https://doi.org/10.1093/biosci/biw022
18. Kelling, S. et al. Using semistructured surveys to improve citizen science data for monitoring biodiversity. *BioScience* **69**, 170–179 (2019). https://doi.org/10.1093/biosci/biz010
19. Devictor, V. et al. Differences in the climatic debts of birds and butterflies at a continental scale. *Nature Climate Change* **2**, 121–124 (2012). https://doi.org/10.1038/nclimate1347
20. La Sorte, F. A. & Thompson, F. R. Poleward shifts in winter ranges of North American birds. *Ecology* **88**, 1803–1812 (2007). https://doi.org/10.1890/06-1072.1
21. Poloczanska, E. S. et al. Global imprint of climate change on marine life. *Nature Climate Change* **3**, 919–925 (2013). https://doi.org/10.1038/nclimate1958
22. Guisan, A. & Thuiller, W. Predicting species distribution: offering more than simple habitat models. *Ecology Letters* **8**, 993–1009 (2005). https://doi.org/10.1111/j.1461-0248.2005.00792.x
23. Guillera-Arroita, G. et al. Is my species distribution model fit for purpose? Matching data and models to applications. *Global Ecology and Biogeography* **24**, 276–292 (2015). https://doi.org/10.1111/geb.12268
24. Johnston, A. et al. Analytical guidelines to increase the value of community science data: an example using eBird data to estimate species distributions. *Diversity and Distributions* **27**, 1265–1277 (2021). https://doi.org/10.1111/ddi.13271
25. Harris, I., Osborn, T. J., Jones, P. & Lister, D. Version 4 of the CRU TS monthly high-resolution gridded multivariate climate dataset. *Scientific Data* **7**, 109 (2020). https://doi.org/10.1038/s41597-020-0453-3
26. Fick, S. E. & Hijmans, R. J. WorldClim 2: new 1-km spatial resolution climate surfaces for global land areas. *International Journal of Climatology* **37**, 4302–4315 (2017). https://doi.org/10.1002/joc.5086
27. Brooks, M. E. et al. glmmTMB balances speed and flexibility among packages for zero-inflated generalized linear mixed modeling. *The R Journal* **9**, 378–400 (2017). https://doi.org/10.32614/RJ-2017-066
28. Freeman, B. G., Scholer, M. N., Ruiz-Gutierrez, V. & Fitzpatrick, J. W. Climate change causes upslope shifts and mountaintop extirpations in a tropical bird community. *Proceedings of the National Academy of Sciences* **115**, 11982–11987 (2018). https://doi.org/10.1073/pnas.1804224115
29. Pebesma, E. Simple Features for R: standardized support for spatial vector data. *The R Journal* **10**, 439–446 (2018). https://doi.org/10.32614/RJ-2018-009
30. Thomas, C. D. Climate, climate change and range boundaries. *Diversity and Distributions* **16**, 488–495 (2010). https://doi.org/10.1111/j.1472-4642.2010.00642.x
31. Sofaer, H. R. et al. Development and delivery of species distribution models to inform decision-making. *BioScience* **69**, 544–557 (2019). https://doi.org/10.1093/biosci/biz045
32. Hurlbert, A. H. & Liang, Z. Spatiotemporal variation in avian migration phenology: citizen science reveals effects of climate change. *PLoS ONE* **7**, e31662 (2012). https://doi.org/10.1371/journal.pone.0031662
33. Bowler, D. E. et al. Mapping human pressures on biodiversity across the planet uncovers anthropogenic threat complexes. *People and Nature* **2**, 380–394 (2020). https://doi.org/10.1002/pan3.10071

*All digital object identifiers were verified against Crossref on 26 July 2026.*

---

## Figure legends

**Figure 1 | Survey effort dominates, but accumulated climate change raises new-record hazard
independently.** **a**, Hazard ratios per standard deviation with 95% confidence intervals for
the four fixed effects, shown for three species-distribution-model binarisation thresholds.
**b**, Predicted annual hazard as a function of accumulated climate change at four levels of
survey effort; the flattening of the gradient at high effort is the negative interaction.
**c**, Drop-term contribution of each process to explained deviance.

**Figure 2 | Specification robustness.** **a**, Climate-change hazard ratio by climate indicator
and accumulation window; the signal requires at least a decade of accumulation. **b**, Model
improvement over an effort-only model. **c**, Climate main effect and interaction across five
survey-effort proxies.

**Figure 3 | Model selection ladder.** ΔAIC across seven candidate models at three thresholds.
The interaction model improves on the additive model at every threshold. The static-mismatch
model fits best but encodes a time-invariant pair-level confounder rather than a mechanism and
was retained only as a sensitivity check.

**Figure 4 | Scenario projections.** Provincial hazard relative to 2024 under two shared
socio-economic pathways at three horizons, from the mechanistic model (**a**) and a
gradient-boosted counterpart (**b**), with TreeSHAP attribution (**c**) and the agreement
between the two models (**d**).

**Extended Data Figure 1 | Residual diagnostics.** Simulation-based residual checks for the
final model.
