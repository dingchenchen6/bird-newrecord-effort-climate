# Separating discovery from redistribution: survey effort and decadal climate change jointly generate new bird distribution records

**Chen-Chen Ding**
Institute of Ecology and State Key Laboratory for Vegetation Structure, Function and
Construction, College of Urban and Environmental Sciences, Peking University, Beijing 100871, China
Correspondence: dccpanther@163.com

---

## Abstract

New distribution records are the primary currency with which the Wallacean shortfall is repaid,
and they are increasingly read as evidence of climate-driven range shifts. Yet a new record is
a joint product of two processes — a species arriving, and an observer looking — and studies to
date have attributed it to one or the other. Here we identify both simultaneously. Using a
discrete-time survival framework over 182,485 species × province × year exposures and 655 first
records of Chinese birds (2002–2024), we show that survey effort accounts for 78% of explained
variation in when and where a new record appears, but that accumulated climate change over the
preceding decade independently raises the hazard by 39% per standard deviation. The climate
signal is invisible to the specification the field conventionally uses: a contemporaneous annual
anomaly yields a hazard ratio of 0.97 (*P* = 0.47), because accumulation and interannual
variability act in opposite directions and cancel. Critically, the climate effect is steepest
where survey effort is lowest, inverting the intuition that better-sampled regions reveal
climate signals more clearly. Gradient-based climate velocity shows no effect, and local climate
novelty — the strongest nominal result in our analysis — proves to be a temporal artefact. New
records therefore index discovery and redistribution simultaneously, in proportions that shift
predictably along the survey-effort gradient, and this shift defines where monitoring investment
converts most efficiently into ecological information.

---

## Introduction

Knowledge of where species occur is incomplete and inaccurate almost everywhere, a deficit
formalised as the Wallacean shortfall [1,2]. New distribution records — the first confirmed
occurrence of a known species in a region where it had not been documented — are the main
mechanism by which that shortfall is repaid [3,4]. Their number is rising steeply, at a time
when species are being redistributed worldwide by warming [34–36]. In China, provincial-level
new bird records have accumulated at an accelerating rate over the past two decades, alongside
an order-of-magnitude expansion of biodiversity monitoring networks and citizen-science
participation.

This creates an attribution problem that the field has not resolved. A new record is, by
construction, a detection event, and detection requires both that the species be present and
that someone be looking [5,6]. The same record can therefore arise from an ecological process
(climate-driven change in distribution) or from an observation process (increased survey effort,
improved detection technology, expanded monitoring coverage), and these two explanations imply
opposite conclusions about the state of biodiversity. Opportunistic records can support reliable
inference about distributional trends, but only when the observation process is modelled
explicitly [37].

Existing studies commit to one explanation or the other, and reach correspondingly opposite
attributions from data of the same kind. Analyses of Chinese provincial new records for resident
birds interpret their spatial pattern as evidence of poleward range shifts driven by warming,
without modelling observation bias [7]. Analyses of Chinese mammal new records interpret them as
a signature of historical survey gaps, concentrated in small-bodied and nocturnal species, without
modelling climate [8]. Neither conclusion is wrong on its own terms; but neither can be evaluated
without the other, because the two processes are confounded in every such dataset. More broadly,
the recording of range shifts is itself geographically and thematically biased [9], imperfect
detection systematically distorts inferred relationships between biodiversity and global-change
drivers [10], and causal attribution in biodiversity change remains methodologically unsettled
[11,12].

Two obstacles have blocked joint identification. First, survey effort and calendar time are
almost collinear in opportunistic and literature-derived data, so any monotonic biological trend
is difficult to separate from a monotonic sampling trend [5,13]. Second — and less widely
recognised — the climate covariate itself is conventionally specified as a contemporaneous
anomaly, the deviation of a single year from a long-term baseline. This conflates two
mechanistically distinct processes. Sustained warming that gradually renders a region
climatically accessible is not the same thing as an anomalously warm year that triggers a single
dispersal or detection event, and there is no reason for them to act in the same direction.

Here we address both obstacles and test four hypotheses:

> **H1** Survey effort is the dominant condition for a new record to be generated.
> **H2** Accumulated climate change raises the hazard of a new record independently of effort.
> **H3** The strength of the climate effect varies with survey effort.
> **H4** Interannual climate variability acts through a channel separate from the long-term trend.

We construct a complete discrete-time risk set in which every species × province × year
combination that could have produced a first record is retained, model the hazard with a
complementary log-log link, and decompose a species-referenced climate gradient into a
strictly backward-looking accumulation term, an interannual variability term, and a static
mismatch term. This decomposition is the analytical core of the study: we show that without it
the accumulated and variability components cancel and the climate signal vanishes entirely.

---

## Results

### Both processes operate, in unequal measure

The analysis set comprises 182,485 species × province × year exposures, 655 first-record events,
394 species and 32 provincial units over 2002–2024, drawn from a curated, peer-reviewed
compilation of Chinese provincial new bird records [14]. Baseline annual hazard is 0.272%.

Survey effort carries a hazard ratio of 1.788 per standard deviation (95% CI 1.639–1.951,
*P* = 7.7 × 10⁻³⁹), confirming H1. Accumulated climate change over the preceding 15 years raises
the hazard independently, HR = 1.394 (1.244–1.562, *P* = 1.0 × 10⁻⁸), confirming H2. Interannual
climate variability acts in the opposite direction, HR = 0.850 (0.781–0.926, *P* = 1.8 × 10⁻⁴),
confirming H4 (Fig. 1a).

Drop-term partitioning of explained deviance attributes 78% to survey effort, 15% to accumulated
climate change, 7% to interannual variability and 4% to their interaction, with these shares
stable across three species-distribution-model thresholds (Fig. 1c). The observation process
therefore dominates the generation of new records — but it does not exhaust it, and a study that
attributed the entire phenomenon to climate would misallocate roughly four-fifths of the
explained signal.

### The conventional specification is blind to the climate signal

Fitting the same data with a contemporaneous annual climate anomaly — the specification used in
most range-shift analyses — returns a hazard ratio of 0.970 (0.894–1.052, *P* = 0.47). The
climate effect is not merely weakened; it is absent.

The reason is cancellation. Decomposed, the accumulation term acts positively (HR 1.39) and the
interannual term negatively (HR 0.85); summed into a single annual anomaly they offset, leaving
nothing to detect. This is not a power problem — the decomposed model is fitted to identical rows
— but a specification problem, and it implies that the absence of a climate signal in analyses
using contemporaneous anomalies is uninformative about whether one exists.

Notably, omitting survey effort altogether does *not* bias the climate coefficient
(HR 1.385 vs 1.394 with effort included), because the species-referenced climate operator is
nearly orthogonal to effort by construction. The cost of ignoring the observation process is
therefore not a distorted climate coefficient but a distorted account of the phenomenon: without
effort in the model there is no way to know that four-fifths of the explained variation is
observational.

### The signal is decadal, not annual

The accumulation window matters more than the choice of climate variable (Fig. 2a,b). At five
years the climate effect is indistinguishable from zero (HR = 1.054, *P* = 0.30). It emerges at
ten years (HR = 1.269, *P* = 1.6 × 10⁻⁵), peaks at fifteen (HR = 1.397, *P* = 8.7 × 10⁻⁹;
ΔAIC = −42.1 against an effort-only model) and plateaus at twenty. New records respond to
sustained decadal warming rather than to individual warm years — consistent with reported lags
between climate change and community-level responses in birds [15,16], and a further reason why
contemporaneous anomalies have little diagnostic value here.

Annual mean temperature outperformed seasonal and extreme indices; warmest-month maximum
temperature carried a weaker signal (ΔAIC = −29.8), and neither winter mean nor coldest-month
minimum temperature contributed under this decomposition.

### Climate matters most where observation is weakest

The interaction between accumulated climate change and survey effort is negative,
HR = 0.876 (0.801–0.959, *P* = 3.9 × 10⁻³), confirming H3 but in the direction opposite to the
usual expectation. The climate gradient is steepest in poorly surveyed provinces and flattens as
effort rises (Fig. 1b, Fig. A1). At two standard deviations above mean effort the climate slope
is 0.77 times that at the mean.

The mechanism is straightforward. Where recording is intense, a species present in a province
will be detected sooner or later and effort saturates the detection process; climate is not the
limiting step. Where recording is sparse, detection requires that the species become sufficiently
established for a chance encounter, and climate-driven change in suitability is what makes that
happen. The climate signal is therefore most legible precisely where the data are weakest — an
inversion with direct consequences for monitoring design.

### Standard climate-change operators fail or mislead

We evaluated two operators widely used in the range-shift literature. Gradient-based climate
velocity [17,18], computed as the trailing 15-year temperature trend divided by the
latitude-corrected spatial gradient of the baseline field (median 2.11 km yr⁻¹), showed no effect
at either provincial or species-referenced level (HR 0.95–0.97, *P* ≥ 0.34). Velocity describes
how fast an isotherm traverses a landscape; it carries no information about whether a particular
location is becoming more suitable for a particular species, and for detection-based data at
administrative resolution this distinction appears decisive.

Local climate novelty [19,20] produced the strongest nominal result in the entire study at
provincial level (HR = 1.768, *P* = 9.6 × 10⁻¹²). It is an artefact. Provincial novelty
accumulates monotonically with warming and is therefore correlated with calendar year
(*r* = 0.73) and with survey effort itself (*r* = 0.62); in the same model the effort hazard
ratio collapses from 1.79 to 1.27, and adding a year term worsens fit. Its species-referenced
counterpart, which removes the spatially common warming signal, is only marginal
(HR = 1.114, *P* = 0.065).

By contrast the accumulation operator adopted here is almost uncorrelated with calendar year
(*r* = 0.066), precisely because it is differenced against the anomaly over each species' own
range. Among the operators examined it is the only one that is both strongly supported and free
of temporal confounding — a criterion we suggest should be reported routinely for any covariate
that increases monotonically over a study period.

### Robustness

Estimates were invariant to the species-distribution-model binarisation threshold (climate change
HR 1.397 / 1.411 / 1.406 at thresholds 50 / 100 / 200; interaction 0.873 / 0.875 / 0.874) and to
the choice of effort metric (climate change 1.371–1.408, all *P* ≤ 5 × 10⁻⁸; interaction
0.839–0.895, all *P* ≤ 0.033, across records, visits, observers, birding-days and a
principal-component composite; Fig. 2c).

Model comparison placed the interaction model ahead of the additive model at every threshold
(Fig. 3). A species-by-province frailty term produced a large nominal AIC gain but a degenerate
fit — species and province variances collapsed to zero, the pair standard deviation exceeded 11
on the log-hazard scale and the effort hazard ratio inflated beyond 11 — the signature of complete
separation at the pair level under rare events; it was rejected. Residual diagnostics were
satisfactory (uniformity *P* = 0.66; dispersion *P* = 0.41; province-grouped residuals *P* = 0.96;
temporal autocorrelation *P* = 0.62; spatial autocorrelation *P* = 0.79), with residual
among-species heterogeneity in detectability the main remaining deviation (*P* = 0.0011).

### Where new records will emerge

Projecting the fitted model under a four-model CMIP6 ensemble, with the warming increment applied
to both the focal province and each species' range and effort growing under
scenario-differentiated trajectories, yields a coherent spatial expectation: relative hazard rises
fastest in central, southern and eastern provinces and least in the western interior (Fig. 4a).
A gradient-boosted counterpart fitted to the same predictors reproduces the spatial pattern
(Fig. 4b,d), but attributes differently — exact TreeSHAP [21,22] assigns survey effort 48.5% of
mean absolute attribution against 78% in the deviance partition, because the boosted trees lack
random effects and the climate features partly encode species and province identity. The
discrepancy is a caution against reading tree-based importance as a mechanistic decomposition.

Late-century projections extrapolate survey effort 1.7–3.4 standard deviations beyond the
observed range and should be read as scenario illustrations rather than forecasts; the 2050
horizon remains within a defensible extrapolation window.

---

## Discussion

New distribution records are neither a clean signal of range change nor merely an artefact of
observation. In this dataset the observation process accounts for roughly four-fifths of the
explained variation in whether and when a first record appears, which is a strong caution against
reading record counts as biological trend [5,9,10]. Yet after effort is controlled, accumulated
warming over the preceding decade still raises the hazard by about 39% per standard deviation.
The two processes are additive, not alternative, and their relative weight shifts systematically
across the survey-effort gradient.

**Implications for attribution.** Studies that attribute new records to climate without modelling
observation, or to survey gaps without modelling climate, are not simply incomplete — they are
answering different questions from the same data. Our results suggest the direction of a climate
coefficient may survive the omission of effort, because a species-referenced climate operator is
close to orthogonal to effort. What does not survive is the interpretation: the fraction of the
phenomenon attributable to each process is unrecoverable from a single-process model. Given the
rate at which new-record compilations are appearing for vertebrates worldwide [3,4,23], and the
documented geographical bias in which range shifts get recorded at all [9], joint identification
should become the default rather than the exception.

**Implications for monitoring design.** The negative interaction has an actionable corollary. If
the climate signal is steepest where effort is lowest, then additional survey investment in
already well-covered provinces yields records that are mostly informative about observers, while
investment in under-surveyed provinces yields records that carry proportionally more ecological
information. This is the opposite of the usual efficiency argument, which favours adding effort
where detection probability is already high. For national monitoring networks being designed
against biodiversity-inventory targets, the relevant optimisation is not the number of records
gained but the ecological signal per unit of effort [24,25], which in turn favours survey designs
that record effort explicitly rather than presence alone [38].

**Implications for conservation planning.** Projections identify where the joint process is
expected to accelerate. Because the same model contains both drivers, these surfaces can be read
two ways: as a forecast of where new records will be reported, and — by holding effort constant —
as a forecast of where distributional change is expected irrespective of who is looking. The
difference between the two is precisely the observational component, and mapping it locates the
regions where present knowledge is most likely to understate real change.

**Methodological generality.** Three findings transfer beyond this system. First, a climate
covariate for a detection-based response should be specified at the timescale of the hypothesised
mechanism; a decadal accumulation term and a contemporaneous anomaly are not interchangeable, and
here they differ between a well-supported effect and nothing at all. Second, any covariate that
increases monotonically through a study period requires an explicit temporal-confounding
diagnostic before its coefficient is interpreted — the novelty result in our analysis would
otherwise have been the headline. Third, information criteria alone are insufficient for
random-effect structure selection under rare events; the pair-frailty model that AIC preferred was
degenerate, and only the variance components revealed it.

**Limitations.** Survey effort and calendar year are collinear (*r* = 0.79); including a linear
year term attenuates the effort coefficient to 1.21 while leaving the climate terms essentially
unchanged, so the partition between "effort" and "time" is not fully identified by these data,
although the climate conclusions are insensitive to the choice. Events are resolved to province,
which is coarse relative to the ecological processes involved, and grid-level refitting was not
feasible for this event set. Among-species heterogeneity in detectability remains in the residuals.
Species without a Chinese historical range were excluded because no native-range climate baseline
can be defined for them, so the events analysed represent range expansion and newly detected
populations rather than vagrancy. Precipitation, though assembled, contributed nothing under this
decomposition.

The Wallacean shortfall is repaid one record at a time, and each record carries information about
both the biota and the people watching it. Separating the two is not a nuisance-variable exercise;
it determines whether a rising curve of new records is read as a warning about redistribution or
as a report on our own improving attention. Here it is both — in a ratio that itself varies
predictably, and that can therefore be planned around.

---

## Methods

### Events and risk set

An event is the first documented occurrence of a species in a Chinese provincial-level
administrative unit between 2002 and 2024, taken from a curated, peer-reviewed compilation of
provincial new bird records that applies explicit evidence, taxonomic-harmonisation and
duplicate-resolution rules [14]. The risk set is the full species × province × year expansion of
the candidate pool, with absorbing exit after the event. Candidates comprise species–province
pairs with modelled potential presence and no historical presence, augmented by forced inclusion
of every observed event, restricted to the union of species for which distribution models were
available. Model binarisation thresholds of 50, 100 and 200 suitable cells were carried through
as a sensitivity [26,27].

### Survey effort

Effort was compiled at province-year resolution from the union of eBird/GBIF records [28,29] and
the China Bird Report archive, quantified with four observation proxies — records, visits,
distinct observers, birding-days — and their first principal component. Counts were
log₁ₚ-transformed and standardized over the analysis population. Province-years absent from the
panel in mainland provinces were assigned zero effort: every raw effort measure has a minimum of
one and contains no zeros, showing the panel to be a record aggregation in which an inactive
province-year produces no row rather than a missing value. Treating such rows as missing, as is
conventional, truncates the lower tail of the effort distribution and, in these data, discards
eleven genuine events. Taiwan and Macau were excluded on the basis of recorded effort density per
unit area (0.13 records km⁻² for Taiwan against 29.7 for Beijing), indicating a source-coverage
gap rather than low activity; Hong Kong, whose low absolute counts reflect its small area
(16.5 records km⁻²), was retained.

### Climate data and the species-referenced gradient

Monthly minimum and maximum temperature at 10 arc-minutes for 1980–2024 were obtained from the
WorldClim 2.1 downscaling of CRU TS 4.09 [30,31]; annual means were computed as the mean of
monthly (Tmin + Tmax)/2. Species ranges were taken from BirdLife International polygons clipped
to China. For province *p*, species *s* and year *t*, with a 1980–2000 baseline,

  *x*(s,p,t) = [*T*(p,t) − *T̄*(p)] − [*N*(s,t) − *N̄*(s)],

where *T* is the area-weighted provincial mean and *N* the mean over the species' Chinese range.
This expresses the province's anomaly relative to the anomaly experienced across the species' own
range and is therefore species-specific.

### Three-way decomposition

*x* was decomposed using strictly backward-looking information, as required of a covariate in a
survival model:

  clim_change(s,p,t) = mean of *x* over [t − W + 1, t]
  clim_var(s,p,t)    = *x*(s,p,t) − clim_change(s,p,t)
  b_static(s,p)      = *T̄*(p) − *N̄*(s)

with W ∈ {5, 10, 15, 20} years. Because the climate series extends to 1980, all 23 analysis years
retain complete windows at every W. The three components are near-orthogonal (|*r*| ≤ 0.08 across
all indicator × window combinations). The static term was retained only as a sensitivity check: it
is a time-invariant pair-level quantity indexing which provinces are climatically suitable for a
species in the first place, and the risk set is itself constructed from distribution models, so it
acts as a confounder rather than a mechanism.

### Statistical model

Hazard was modelled with a complementary log-log link, the canonical form for discrete-time
proportional hazards, in glmmTMB [32]:

  event ~ clim_change_z × effort_z + clim_var_z + (1 | species) + (1 | province)

All covariates were standardized within the analysis set, over event and non-event rows alike.
Random-effect structures including a year effect, random slopes for effort and for climate
sensitivity, and a species-by-province frailty were compared by AIC alongside convergence and
variance-component diagnostics. Residuals were assessed by simulation (500 draws), including
grouped uniformity by province, year and species and tests for temporal and spatial
autocorrelation.

### Alternative climate operators

Gradient-based velocity was computed as the ordinary-least-squares temperature trend over the
trailing window divided by the magnitude of the spatial gradient of the baseline temperature
field, obtained by central differences with latitude correction and expressed in °C km⁻¹,
following Loarie et al. [17] and Burrows et al. [18]. Local novelty was computed as the absolute
departure of the trailing-window mean from the baseline mean, standardized by the baseline
interannual standard deviation [19,20]. Both were evaluated at provincial level and as
species-referenced differences. The `climetrics` implementation of gradient velocity, applied to
unprojected geographic coordinates, returned values approximately four orders of magnitude below
the latitude-corrected calculation and correlated with it at only *r* = 0.49; the formulations
above were therefore implemented directly and its numerical output was not used.

### Projections and machine-learning comparison

Future covariates used the median of a four-model CMIP6 ensemble (ACCESS-CM2, MPI-ESM1-2-HR,
MIROC6, UKESM1-0-LL) under SSP2-4.5 and SSP5-8.5 for 2030, 2050 and 2080. The warming increment
was applied to both the provincial and the species-range terms; applying it only to the province
would manufacture a climate effect, because near-uniform warming cancels in a differenced operator
(measured increments differed by less than 0.1 °C between the two ends). A gradient-boosted model
[22] fitted to the same three predictors was interpreted with exact TreeSHAP [21]. Spatial
analyses used sf [33] and terra; maps carry the GS(2019)1822 national boundary and South China Sea
nine-dash line.

### Data and code availability

All analysis code, derived data panels, result tables and figures are available at
https://github.com/dingchenchen6/bird-newrecord-effort-climate. Figures are provided in raster,
vector and editable formats with accompanying source data.

---

## References

1. Hortal, J. et al. Seven shortfalls that beset large-scale knowledge of biodiversity. *Annual Review of Ecology, Evolution, and Systematics* **46**, 523–549 (2015). https://doi.org/10.1146/annurev-ecolsys-112414-054400
2. Diniz-Filho, J. A. F. et al. Macroecological links between the Linnean, Wallacean, and Darwinian shortfalls. *Frontiers of Biogeography* **15**, e59566 (2023). https://doi.org/10.21425/F5FBG59566
3. Moura, M. R. & Jetz, W. Shortfalls and opportunities in terrestrial vertebrate species discovery. *Nature Ecology & Evolution* **5**, 631–639 (2021). https://doi.org/10.1038/s41559-021-01411-5
4. Oliver, R. Y., Meyer, C., Ranipeta, A., Winner, K. & Jetz, W. Global and national trends, gaps, and opportunities in documenting and monitoring species distributions. *PLoS Biology* **19**, e3001336 (2021). https://doi.org/10.1371/journal.pbio.3001336
5. Isaac, N. J. B., van Strien, A. J., August, T. A., de Zeeuw, M. P. & Roy, D. B. Statistics for citizen science: extracting signals of change from noisy ecological data. *Methods in Ecology and Evolution* **5**, 1052–1060 (2014). https://doi.org/10.1111/2041-210X.12254
6. Tingley, M. W. & Beissinger, S. R. Detecting range shifts from historical species occurrences: new perspectives on old data. *Trends in Ecology & Evolution* **24**, 625–633 (2009). https://doi.org/10.1016/j.tree.2009.05.009
7. Chen, S. et al. Chinese provincial-level new records for 96 resident bird species reveal poleward range shifts. *Avian Research* **16**, 100310 (2025). https://doi.org/10.1016/j.avrs.2025.100310
8. Ding, C., Ding, J., Qiao, H., Jiang, Z. & Wang, Z. Taxonomic and spatiotemporal patterns and ecological correlates of new mammal distribution records in China. *Global Ecology and Biogeography* **34**, e70165 (2025). https://doi.org/10.1111/geb.70165
9. Hughes, A. C. et al. Sampling biases shape our view of the natural world. *Ecography* **44**, 1259–1269 (2021). https://doi.org/10.1111/ecog.05926
10. Miller-ter Kuile, A. et al. If you're rare, should I care? How imperfect detection changes relationships between biodiversity and global change drivers. *Global Change Biology* **31**, e70362 (2025). https://doi.org/10.1111/gcb.70362
11. Schrodt, F. et al. Advancing causal inference in ecology: pathways for biodiversity change detection and attribution. *Methods in Ecology and Evolution* **16**, 2276–2304 (2025). https://doi.org/10.1111/2041-210X.70131
12. Bowler, D. E. et al. Treating gaps and biases in biodiversity data as a missing data problem. *Biological Reviews* **100**, 50–67 (2025). https://doi.org/10.1111/brv.13127
13. Boakes, E. H. et al. Distorted views of biodiversity: spatial and temporal bias in species occurrence data. *PLoS Biology* **8**, e1000385 (2010). https://doi.org/10.1371/journal.pbio.1000385
14. Ding, C. et al. A dataset of provincial-level new distribution records for birds in China from 2000 to 2025. *Scientific Data* (in review).
15. Devictor, V. et al. Differences in the climatic debts of birds and butterflies at a continental scale. *Nature Climate Change* **2**, 121–124 (2012). https://doi.org/10.1038/nclimate1347
16. La Sorte, F. A. & Thompson, F. R. Poleward shifts in winter ranges of North American birds. *Ecology* **88**, 1803–1812 (2007). https://doi.org/10.1890/06-1072.1
17. Loarie, S. R. et al. The velocity of climate change. *Nature* **462**, 1052–1055 (2009). https://doi.org/10.1038/nature08649
18. Burrows, M. T. et al. The pace of shifting climate in marine and terrestrial ecosystems. *Science* **334**, 652–655 (2011). https://doi.org/10.1126/science.1210288
19. Williams, J. W. & Jackson, S. T. Novel climates, no-analog communities, and ecological surprises. *Frontiers in Ecology and the Environment* **5**, 475–482 (2007). https://doi.org/10.1890/070037
20. Mahony, C. R., Cannon, A. J., Wang, T. & Aitken, S. N. A closer look at novel climates: new methods and insights at continental to landscape scales. *Global Change Biology* **23**, 3934–3955 (2017). https://doi.org/10.1111/gcb.13645
21. Lundberg, S. M. et al. From local explanations to global understanding with explainable AI for trees. *Nature Machine Intelligence* **2**, 56–67 (2020). https://doi.org/10.1038/s42256-019-0138-9
22. Chen, T. & Guestrin, C. XGBoost: a scalable tree boosting system. In *Proceedings of the 22nd ACM SIGKDD International Conference on Knowledge Discovery and Data Mining* 785–794 (2016). https://doi.org/10.1145/2939672.2939785
23. Meyer, C., Kreft, H., Guralnick, R. & Jetz, W. Global priorities for an effective information basis of biodiversity distributions. *Nature Communications* **6**, 8221 (2015). https://doi.org/10.1038/ncomms9221
24. Amano, T., Lamming, J. D. L. & Sutherland, W. J. Spatial gaps in global biodiversity information and the role of citizen science. *BioScience* **66**, 393–400 (2016). https://doi.org/10.1093/biosci/biw022
25. Callaghan, C. T., Poore, A. G. B., Major, R. E., Rowley, J. J. L. & Cornwell, W. K. Optimizing future biodiversity sampling by citizen scientists. *Proceedings of the Royal Society B* **286**, 20191487 (2019). https://doi.org/10.1098/rspb.2019.1487
26. Guisan, A. & Thuiller, W. Predicting species distribution: offering more than simple habitat models. *Ecology Letters* **8**, 993–1009 (2005). https://doi.org/10.1111/j.1461-0248.2005.00792.x
27. Guillera-Arroita, G. et al. Is my species distribution model fit for purpose? Matching data and models to applications. *Global Ecology and Biogeography* **24**, 276–292 (2015). https://doi.org/10.1111/geb.12268
28. Sullivan, B. L. et al. eBird: a citizen-based bird observation network in the biological sciences. *Biological Conservation* **142**, 2282–2292 (2009). https://doi.org/10.1016/j.biocon.2009.05.006
29. Johnston, A. et al. Analytical guidelines to increase the value of community science data: an example using eBird data to estimate species distributions. *Diversity and Distributions* **27**, 1265–1277 (2021). https://doi.org/10.1111/ddi.13271
30. Harris, I., Osborn, T. J., Jones, P. & Lister, D. Version 4 of the CRU TS monthly high-resolution gridded multivariate climate dataset. *Scientific Data* **7**, 109 (2020). https://doi.org/10.1038/s41597-020-0453-3
31. Fick, S. E. & Hijmans, R. J. WorldClim 2: new 1-km spatial resolution climate surfaces for global land areas. *International Journal of Climatology* **37**, 4302–4315 (2017). https://doi.org/10.1002/joc.5086
32. Brooks, M. E. et al. glmmTMB balances speed and flexibility among packages for zero-inflated generalized linear mixed modeling. *The R Journal* **9**, 378–400 (2017). https://doi.org/10.32614/RJ-2017-066
33. Pebesma, E. Simple Features for R: standardized support for spatial vector data. *The R Journal* **10**, 439–446 (2018). https://doi.org/10.32614/RJ-2018-009
34. Pecl, G. T. et al. Biodiversity redistribution under climate change: impacts on ecosystems and human well-being. *Science* **355**, eaai9214 (2017). https://doi.org/10.1126/science.aai9214
35. Chen, I.-C., Hill, J. K., Ohlemüller, R., Roy, D. B. & Thomas, C. D. Rapid range shifts of species associated with high levels of climate warming. *Science* **333**, 1024–1026 (2011). https://doi.org/10.1126/science.1206432
36. Lenoir, J. et al. Species better track climate warming in the oceans than on land. *Nature Ecology & Evolution* **4**, 1044–1059 (2020). https://doi.org/10.1038/s41559-020-1198-2
37. van Strien, A. J., van Swaay, C. A. M. & Termaat, T. Opportunistic citizen science data of animal species produce reliable estimates of distribution trends if analysed with occupancy models. *Journal of Applied Ecology* **50**, 1450–1458 (2013). https://doi.org/10.1111/1365-2664.12158
38. Kelling, S. et al. Using semistructured surveys to improve citizen science data for monitoring biodiversity. *BioScience* **69**, 170–179 (2019). https://doi.org/10.1093/biosci/biz010

*All digital object identifiers were verified against Crossref on 26 July 2026. Reference 14 is a
companion data descriptor currently in review; it will be updated on acceptance.*

---

## Figure legends

**Figure 1 | Survey effort dominates, but accumulated climate change raises new-record hazard
independently.** **a**, Hazard ratios per standard deviation with 95% confidence intervals for the
four fixed effects, at three species-distribution-model thresholds. **b**, Predicted annual hazard
as a function of accumulated climate change at four levels of survey effort; flattening of the
gradient at high effort is the negative interaction. **c**, Drop-term contribution of each process
to explained deviance. Components overlap slightly, so shares sum to more than 100%.

**Figure 2 | The climate signal is decadal and specification-dependent.** **a**, Climate-change
hazard ratio by climate indicator and accumulation window; no signal is detectable at a five-year
window. **b**, Model improvement over an effort-only model. **c**, Climate main effect and its
interaction with effort across five survey-effort proxies.

**Figure 3 | Model selection ladder.** ΔAIC across seven candidate models at three thresholds. The
interaction model improves on the additive model at every threshold. The static-mismatch model
fits best but encodes a time-invariant pair-level confounder rather than a mechanism, and was
retained only as a sensitivity check.

**Figure 4 | Where new records are expected to emerge.** Provincial hazard relative to 2024 under
two shared socio-economic pathways at three horizons, from the mechanistic model (**a**) and a
gradient-boosted counterpart (**b**), with TreeSHAP attribution (**c**) and agreement between the
two models (**d**). Late-century panels extrapolate effort well beyond the observed range and are
scenario illustrations rather than forecasts.

**Extended Data Figure 1 | Interaction surface.** Predicted hazard across the joint
climate-change × survey-effort plane, with observed events overlaid; converging iso-hazard contours
toward high effort show the negative interaction.

**Extended Data Figure 2 | Residual diagnostics.** Simulation-based residual checks for the final
model.
