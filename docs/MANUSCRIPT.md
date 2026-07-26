# Separating range expansion from observation: survey effort and decadal climate change jointly generate new bird distribution records

**Chen-Chen Ding**
Institute of Ecology and State Key Laboratory for Vegetation Structure, Function and
Construction, College of Urban and Environmental Sciences, Peking University, Beijing 100871, China
Correspondence: dccpanther@163.com

---

## Abstract

New distribution records are the main currency with which the Wallacean shortfall is repaid, and
they are increasingly read as evidence of climate-driven range shifts. Yet every new record is a
detection event, jointly produced by a species arriving and an observer looking, and studies to
date have attributed it to one process or the other. Here we identify both simultaneously. Across
182,485 species × province × year exposures and 655 first records of Chinese birds (2002–2024),
survey effort raises the hazard of a new record by 79% per standard deviation and accounts for
78% of the jointly explainable deviance; accumulated climate change over the preceding decade
raises it independently by 39%. A single-process model built on climate alone recovers an
essentially unbiased climate coefficient but captures only 22.6% of the explainable signal
(marginal *R*² = 0.061 against 0.191 for the joint model), and so cannot support the attribution
it is used to make. A model using the contemporaneous annual anomaly conventional in range-shift
analyses fits worse than an intercept-only model, because accumulation and interannual
variability act in opposite directions and cancel. Critically, the climate effect is steepest
where survey effort is lowest — inverting the intuition that well-sampled regions reveal climate
signals most clearly — and this gradient identifies where monitoring investment converts most
efficiently into ecological information. Separating redistribution from observation is therefore
not a statistical nicety but a precondition for using biodiversity records as climate indicators.

---

## Introduction

Knowledge of where species occur remains incomplete and inaccurate almost everywhere, a deficit
formalised as the Wallacean shortfall [1,2]. New distribution records — the first confirmed
occurrence of a known species in a region where it had not been documented — are the principal
mechanism by which that shortfall is repaid [3,4], and their number is rising steeply worldwide
at a time when species are being redistributed by warming [5–8], with consequences that extend
from range boundaries to population trends and extinction risk [58–62]. In China, provincial-level new
bird records have accumulated at an accelerating rate over the past two decades [9,10], alongside
an order-of-magnitude expansion of monitoring networks and citizen-science participation [11,12].
Such data can reveal genuine climate responses when the sampling process is modelled [66,70].

This coincidence poses an attribution problem the field has not resolved. A new record is, by
construction, a detection event: it requires both that the species be present and that someone be
looking [13–15]. The same record can therefore arise from an **ecological process** — range
expansion or redistribution under climate change — or from an **observation process** — growth in
survey effort, expanded spatial coverage, improved detection technology [16–19]. These
explanations imply opposite conclusions about the state of biodiversity, and they are confounded
in every opportunistic or literature-derived dataset [20–23]. Statistical remedies exist —
occupancy formulations, effort covariates, record filtering and coordinate cleaning [63,65,67,68] —
but they require that the observation process be represented in the model at all.

Existing analyses commit to one process and reach correspondingly opposite attributions from data
of the same kind. Chinese provincial new records for resident birds have been interpreted as
evidence of poleward range shifts driven by warming, without modelling observation [9]. Chinese
mammal new records have been interpreted as a signature of historical survey gaps, concentrated
in small-bodied and nocturnal species, without modelling climate [10]. Neither conclusion is
wrong on its own terms; but neither can be evaluated without the other. More broadly, the
recording of range shifts is itself geographically and taxonomically biased [16,23], imperfect
detection systematically distorts inferred relationships between biodiversity and global-change
drivers [15], and causal attribution in biodiversity change remains methodologically unsettled
[21,24].

Two obstacles have blocked joint identification. First, survey effort and calendar time are
nearly collinear in such data, so a monotonic biological trend is difficult to separate from a
monotonic sampling trend [13,20]. Second — and less widely recognised — the climate covariate is
conventionally specified as a *contemporaneous anomaly*, the deviation of a single year from a
long-term baseline. This conflates two mechanistically distinct processes: sustained warming that
gradually renders a region climatically accessible, and an anomalously warm year that triggers a
single dispersal or detection event. There is no reason for these to act in the same direction,
and if they do not, a summed anomaly will detect neither.

Here we address both obstacles. We construct a complete discrete-time risk set retaining every
species × province × year combination that could have produced a first record, model the hazard
with a complementary log-log link, and decompose a species-referenced climate gradient into a
strictly backward-looking accumulation term, an interannual variability term, and a static
mismatch term. We test four hypotheses:

> **H1 (observation process)** Survey effort is the dominant condition for a new record to be generated.
> **H2 (ecological process)** Accumulated climate change raises new-record hazard independently of effort.
> **H3 (process coupling)** The strength of the climate effect varies with survey effort.
> **H4 (timescale separation)** Interannual climate variability acts through a channel distinct from the long-term trend.

Our contribution is threefold. **Conceptually**, we show that new records index redistribution and
discovery simultaneously, in proportions that vary predictably across the survey-effort gradient,
and we quantify what each single-process model can and cannot conclude. **Methodologically**, we
show that the climate covariate must be specified at a decadal timescale and in a
species-referenced frame for the ecological signal to be identifiable at all, and we provide
diagnostics — temporal-confounding checks, variance-component inspection — that separate real
effects from artefacts. **Practically**, we translate the effort–climate coupling into an explicit
criterion for where monitoring investment yields ecological rather than merely descriptive
information, and project where new records are expected to arise.

---

## Results

### Both processes operate, in unequal measure

The analysis set comprises 182,485 species × province × year exposures, 655 first-record events,
394 species and 31 provincial units over 2002–2024, drawn from a curated, peer-reviewed
compilation of Chinese provincial new bird records [25]. Baseline annual hazard is 0.272%.

Survey effort carries a hazard ratio of 1.788 per standard deviation (95% CI 1.639–1.951,
*P* = 7.7 × 10⁻³⁹), supporting H1. Accumulated climate change over the preceding 15 years raises
hazard independently, HR = 1.394 (1.244–1.562, *P* = 1.0 × 10⁻⁸), supporting H2. Interannual
climate variability acts in the opposite direction, HR = 0.850 (0.781–0.926, *P* = 1.8 × 10⁻⁴),
supporting H4 (Fig. 1a). Drop-term partitioning attributes 78% of explained deviance to survey
effort, 15% to accumulated climate change, 7% to interannual variability and 4% to their
interaction, with shares stable across three species-distribution-model thresholds (Fig. 1c).

### What single-process models can and cannot conclude

We fitted the models the literature actually uses and compared their explanatory power against
the joint model on identical rows (Table 1).

**Table 1 | Single-process and joint models compared (SDM threshold 50).**

| Model | df | AIC | ΔAIC | Deviance explained (%) | Share of jointly explainable deviance (%) | Marginal *R*² | AUC |
|---|---:|---:|---:|---:|---:|---:|---:|
| Intercept only | 3 | 8621.6 | 214.4 | 0 | 0 | 0 | 0.683 |
| **Contemporaneous anomaly only** | 4 | 8623.1 | **215.9** | **0.006** | **0.2** | **0.0005** | 0.683 |
| Climate only (decomposed) | 5 | 8575.4 | 168.2 | 0.583 | **22.6** | 0.061 | 0.678 |
| Survey effort only | 4 | 8449.7 | 42.5 | 2.019 | **78.2** | 0.132 | 0.725 |
| Climate + effort (additive) | 6 | 8413.5 | 6.3 | 2.485 | 96.2 | 0.165 | 0.734 |
| **Joint model (final)** | 7 | **8407.2** | **0** | **2.582** | **100** | **0.191** | 0.731 |

Three results follow, each replicated at thresholds 100 and 200.

First, **a climate-only analysis recovers an essentially unbiased climate coefficient**
(HR 1.385 with effort omitted against 1.394 with it included), because the species-referenced
operator is nearly orthogonal to effort — but it captures only 22.6% of the explainable signal,
with a marginal *R*² of 0.061 against 0.191 for the joint model. The cost of omitting the
observation process is therefore not a distorted coefficient but an unsupportable attribution:
such a model explains less than a quarter of what is explainable while implicitly assigning all
of it to climate.

Second, **an effort-only analysis captures 78.2%** and would be internally consistent, yet would
miss a real ecological effect entirely. The two existing literatures [9,10] are thus each
capturing a genuine component of the same process, and neither is in a position to bound the
other.

Third, and most consequentially, **the conventional contemporaneous-anomaly specification fits
worse than an intercept-only model** (ΔAIC +1.5 against the null; marginal *R*² = 0.0005;
HR = 0.970, *P* = 0.47). The climate effect is not weakened but erased. The cause is cancellation:
decomposed, accumulation acts positively (HR 1.39) and interannual variability negatively
(HR 0.85); summed into one annual anomaly they offset. An absence of climate signal under this
specification is therefore uninformative about whether one exists — a point that bears directly
on how negative results in the range-shift literature should be read.

### The ecological signal is decadal

The accumulation window matters more than the choice of climate variable (Fig. 2a,b). At five
years the climate effect is indistinguishable from zero (HR = 1.054, *P* = 0.30); it emerges at
ten (HR = 1.269, *P* = 1.6 × 10⁻⁵), peaks at fifteen (HR = 1.397, *P* = 8.7 × 10⁻⁹;
ΔAIC = −42.1 against effort-only) and plateaus at twenty. New records respond to sustained
decadal warming rather than to individual warm years, consistent with documented lags between
climate change and avian community responses [26–28]. Annual mean temperature outperformed
seasonal and extreme indices; warmest-month maximum temperature carried a weaker signal
(ΔAIC = −29.8), and neither winter mean nor coldest-month minimum temperature contributed.

### Climate matters most where observation is weakest

The interaction between accumulated climate change and survey effort is negative,
HR = 0.876 (0.801–0.959, *P* = 3.9 × 10⁻³), supporting H3 but in the direction opposite to
intuition. The climate gradient is steepest in poorly surveyed provinces and flattens as effort
rises (Fig. 1b; Extended Data Fig. 1): at two standard deviations above mean effort the climate
slope is 0.77 times that at the mean.

The mechanism is direct. Where recording is intense, a species present in a province will be
detected sooner or later; effort saturates detection and climate is not the limiting step. Where
recording is sparse, detection requires that the species become sufficiently established for a
chance encounter, and climate-driven change in suitability is what makes that happen. The
ecological signal is therefore most legible precisely where the data are weakest.

### Standard climate-change operators fail or mislead

We evaluated two operators widely used in the range-shift literature. Gradient-based climate
velocity [29,30], computed as the trailing 15-year temperature trend divided by the
latitude-corrected spatial gradient of the baseline field (median 2.11 km yr⁻¹), showed no effect
at either provincial or species-referenced level (HR 0.95–0.97, *P* ≥ 0.34). Velocity describes
how fast an isotherm traverses a landscape and has proved informative for aggregate biogeographic
patterns [31,32]; it carries no information about whether a particular location is becoming more
suitable for a particular species, and for detection-based data at administrative resolution this
distinction appears decisive.

Local climate novelty [33,34] produced the strongest nominal result in the study at provincial
level (HR = 1.768, *P* = 9.6 × 10⁻¹²). It is an artefact. Provincial novelty accumulates
monotonically with warming and is correlated with calendar year (*r* = 0.73) and with survey
effort itself (*r* = 0.62); in the same model the effort hazard ratio collapses from 1.79 to 1.27
and adding a year term worsens fit. Its species-referenced counterpart is only marginal
(HR = 1.114, *P* = 0.065). By contrast the accumulation operator adopted here is almost
uncorrelated with calendar year (*r* = 0.066), because it is differenced against the anomaly over
each species' own range. Among the operators examined it is the only one both strongly supported
and free of temporal confounding.

### Robustness

Estimates were invariant to SDM binarisation threshold (climate change HR 1.397 / 1.411 / 1.406;
interaction 0.873 / 0.875 / 0.874) and to effort metric (climate change 1.371–1.408, all
*P* ≤ 5 × 10⁻⁸; interaction 0.839–0.895, all *P* ≤ 0.033, across records, visits, observers,
birding-days and a principal-component composite; Fig. 2c). Model comparison placed the
interaction model ahead of the additive model at every threshold (Fig. 3).

A species-by-province frailty term produced a large nominal AIC gain but a degenerate fit —
species and province variances collapsed to zero, the pair standard deviation exceeded 11 on the
log-hazard scale and the effort hazard ratio inflated beyond 11 — the signature of complete
separation at the pair level under rare events; it was rejected. Residual diagnostics were
satisfactory (uniformity *P* = 0.66; dispersion *P* = 0.41; province-grouped residuals *P* = 0.96;
temporal autocorrelation *P* = 0.62; spatial autocorrelation *P* = 0.79), with residual
among-species heterogeneity in detectability the main remaining deviation (*P* = 0.0011).

### Where new records are expected to emerge

Projecting the fitted model under a four-model CMIP6 ensemble, with the warming increment applied
to both the focal province and each species' range and effort growing under
scenario-differentiated trajectories, yields a coherent spatial expectation: relative hazard rises
fastest in central, southern and eastern provinces and least in the western interior (Fig. 4a). A
gradient-boosted counterpart reproduces the spatial pattern (Fig. 4b,d) but attributes
differently — exact TreeSHAP [35,36] assigns survey effort 48.5% of mean absolute attribution
against 78% in the deviance partition, because boosted trees lack random effects and climate
features partly encode species and province identity. The discrepancy is a caution against
reading tree-based importance as a mechanistic decomposition. Late-century projections
extrapolate effort 1.7–3.4 standard deviations beyond the observed range and are scenario
illustrations rather than forecasts; the 2050 horizon remains within a defensible window.

---

## Discussion

New distribution records are neither a clean signal of range change nor merely an artefact of
observation. Here the observation process accounts for roughly four-fifths of the explained
variation in whether and when a first record appears, a strong caution against reading record
counts as biological trend [13,16,20]. Yet after effort is controlled, accumulated warming over
the preceding decade still raises hazard by about 39% per standard deviation. The two processes
are additive, not alternative, and their relative weight shifts systematically along the
survey-effort gradient.

**Attribution requires joint identification.** Our comparison of single-process and joint models
makes the cost of the conventional approach explicit and quantitative. A climate-only model may
return an unbiased coefficient, yet it explains 22.6% of the explainable signal while attributing
the whole phenomenon to climate; an effort-only model explains 78.2% while missing a real
ecological effect. Neither can adjudicate between range expansion and improved observation,
because the quantity that distinguishes them — the share of variation each process accounts for —
is not estimable from a model containing only one. Given the rate at which new-record
compilations are appearing for vertebrates worldwide [3,4,9,10,37] and the documented geographic
bias in which range shifts get recorded at all [16,23], joint identification should become the
default rather than the exception. The same logic applies wherever occurrence-based indicators —
first detections, colonisations, range-edge extensions — are used to infer redistribution
[14,15,19,38].

**Specification determines detectability.** That the conventional contemporaneous anomaly fits
worse than an intercept-only model reframes how negative results should be read. A study
reporting no climate effect on colonisation may have specified the covariate at a timescale on
which no effect exists, rather than demonstrating that none exists at any timescale. Decadal
accumulation and interannual variability are separable, act in opposite directions, and must be
modelled separately; summing them guarantees mutual cancellation. This may contribute to the
heterogeneity of reported climate effects on range dynamics across systems [6,7,39,40], where
range boundaries are set by an interplay of climatic and non-climatic constraints [71].

**Implications for monitoring design.** The negative interaction has an actionable corollary. If
the climate signal is steepest where effort is lowest, then additional survey investment in
already well-covered provinces yields records that are largely informative about observers, while
investment in under-surveyed provinces yields records carrying proportionally more ecological
information. This inverts the usual efficiency argument, which favours adding effort where
detection probability is already high. For national monitoring networks designed against
biodiversity-inventory targets [41–43], the relevant optimisation is not records gained but
ecological signal per unit effort — which in turn favours designs that record effort explicitly
rather than presence alone [12,44,45,64].

**Implications for conservation planning.** Because the fitted model contains both drivers, the
projected surfaces can be read two ways: as a forecast of where new records will be *reported*,
and — holding effort constant — as a forecast of where distributional change is *expected*
irrespective of who is looking. The difference between the two maps the observational component
directly, locating regions where present knowledge most understates real change. For a country
whose biodiversity strategy explicitly targets inventory completion and monitoring-network
optimisation [41,46], this distinction is operationally consequential, and it is the kind of
model output that decision-facing workflows are designed to consume [69].

**Methodological generality.** Three findings transfer beyond this system. First, a climate
covariate for a detection-based response must be specified at the timescale of the hypothesised
mechanism; here a decadal accumulation term and a contemporaneous anomaly differ between a
well-supported effect and nothing at all. Second, any covariate increasing monotonically through
a study period requires an explicit temporal-confounding diagnostic before interpretation — the
novelty result would otherwise have been our headline. Third, information criteria alone are
insufficient for random-effect selection under rare events: the pair-frailty model AIC preferred
was degenerate, and only variance components revealed it.

**Limitations.** Survey effort and calendar year are collinear (*r* = 0.79); including a linear
year term attenuates the effort coefficient to 1.21 while leaving climate terms essentially
unchanged, so the effort–time partition is not fully identified, although climate conclusions are
insensitive to the choice. Events resolve to province, coarse relative to the ecological processes
involved, and grid-level refitting was not feasible for this event set. Among-species
heterogeneity in detectability remains in the residuals; trait-mediated variation in detectability
is a natural extension [10,47]. Species without a Chinese historical range were excluded because
no native-range climate baseline can be defined, so the events analysed represent range expansion
and newly detected populations rather than vagrancy. Precipitation, though assembled, contributed
nothing under this decomposition. Finally, our design identifies association with the
record-generating process, not causation; formal causal frameworks for biodiversity attribution
remain an active area [21,24].

The Wallacean shortfall is repaid one record at a time, and each record carries information about
both the biota and the people watching it. Separating the two determines whether a rising curve
of new records is read as a warning about redistribution or as a report on our own improving
attention. Here it is both — in a ratio that varies predictably, and that can therefore be
planned around.

---

## Methods

### Events and risk set

An event is the first documented occurrence of a species in a Chinese provincial-level
administrative unit between 2002 and 2024, taken from a curated, peer-reviewed compilation
applying explicit evidence, taxonomic-harmonisation and duplicate-resolution rules [25]. The risk
set is the full species × province × year expansion of the candidate pool, with absorbing exit
after the event. Candidates comprise species–province pairs with modelled potential presence and
no historical presence, augmented by forced inclusion of every observed event, restricted to the
union of species with available distribution models. Binarisation thresholds of 50, 100 and 200
suitable cells were carried through as a sensitivity [48–51].

### Survey effort

Effort was compiled at province-year resolution from the union of eBird/GBIF records [11,52] and
the China Bird Report archive, quantified with four observation proxies — records, visits,
distinct observers, birding-days — and their first principal component. Counts were
log₁ₚ-transformed and standardized over the analysis population. Province-years absent from the
panel in mainland provinces were assigned zero effort: every raw effort measure has a minimum of
one and contains no zeros, showing the panel to be a record aggregation in which an inactive
province-year produces no row rather than a missing value. Treating such rows as missing, the
conventional choice, truncates the lower tail of the effort distribution and here discards eleven
genuine events. Taiwan and Macau were excluded on recorded effort density per unit area
(0.13 records km⁻² for Taiwan against 29.7 for Beijing), indicating source-coverage gaps rather
than low activity; Hong Kong, whose low absolute counts reflect its small area (16.5 records
km⁻²), was retained in the effort panel and risk set. It does not, however, enter the
fitted models: at 1,100 km² Hong Kong is smaller than a single 100-km analysis grid cell, so no
cell is assigned to it by largest-overlap and it acquires no grid-derived climate value. It
contributes no events, so estimates are unaffected, and the analysis set comprises 31 provincial
units.

### Climate data and the species-referenced gradient

Monthly minimum and maximum temperature at 10 arc-minutes for 1980–2024 came from the WorldClim
2.1 downscaling of CRU TS 4.09 [53,54]; annual means were computed as the mean of monthly
(Tmin + Tmax)/2. Species ranges were BirdLife International polygons clipped to China. For
province *p*, species *s* and year *t*, with a 1980–2000 baseline,

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
retain complete windows at every W. The components are near-orthogonal (|*r*| ≤ 0.08 across all
indicator × window combinations). The static term was retained only as a sensitivity check: it is
a time-invariant pair-level quantity indexing which provinces are climatically suitable for a
species in the first place, and the risk set is itself constructed from distribution models, so it
acts as a confounder rather than a mechanism.

### Statistical models

Hazard was modelled with a complementary log-log link, the canonical form for discrete-time
proportional hazards, in glmmTMB [55]:

  event ~ clim_change_z × effort_z + clim_var_z + (1 | species) + (1 | province)

Covariates were standardized within the analysis set over event and non-event rows alike. The
single-process comparison (Table 1) fitted intercept-only, contemporaneous-anomaly-only,
decomposed-climate-only, effort-only, additive and joint models to identical rows; explanatory
power was summarised as deviance explained relative to the null, share of the jointly explainable
deviance, marginal and conditional *R*² [56] and in-sample AUC. Random-effect structures including
a year effect, random slopes for effort and climate sensitivity, and a species-by-province frailty
were compared by AIC alongside convergence and variance-component diagnostics. Residuals were
assessed by simulation (500 draws), including grouped uniformity by province, year and species and
tests for temporal and spatial autocorrelation.

### Alternative climate operators

Gradient-based velocity was computed as the ordinary-least-squares temperature trend over the
trailing window divided by the magnitude of the spatial gradient of the baseline temperature
field, obtained by central differences with latitude correction and expressed in °C km⁻¹,
following Loarie et al. [29] and Burrows et al. [30]. Local novelty was the absolute departure of
the trailing-window mean from the baseline mean, standardized by baseline interannual standard
deviation [33,34]. Both were evaluated at provincial level and as species-referenced differences.
The `climetrics` implementation of gradient velocity, applied to unprojected geographic
coordinates, returned values approximately four orders of magnitude below the latitude-corrected
calculation and correlated with it at only *r* = 0.49; the formulations above were therefore
implemented directly and its numerical output was not used.

### Projections and machine-learning comparison

Future covariates used the median of a four-model CMIP6 ensemble (ACCESS-CM2, MPI-ESM1-2-HR,
MIROC6, UKESM1-0-LL) under SSP2-4.5 and SSP5-8.5 for 2030, 2050 and 2080. The warming increment
was applied to both the provincial and species-range terms; applying it only to the province would
manufacture a climate effect, because near-uniform warming cancels in a differenced operator
(measured increments differed by less than 0.1 °C between ends). A gradient-boosted model [36]
fitted to the same predictors was interpreted with exact TreeSHAP [35]. Spatial analyses used sf
[57] and terra; maps carry the GS(2019)1822 national boundary and South China Sea nine-dash line.

### Data and code availability

All code, derived data panels, result tables and figures are at
https://github.com/dingchenchen6/bird-newrecord-effort-climate. Figures are provided in raster,
vector and editable formats with accompanying source data.

---

## References

1. Hortal, J. et al. Seven shortfalls that beset large-scale knowledge of biodiversity. *Annu. Rev. Ecol. Evol. Syst.* **46**, 523–549 (2015). https://doi.org/10.1146/annurev-ecolsys-112414-054400
2. Diniz-Filho, J. A. F. et al. Macroecological links between the Linnean, Wallacean, and Darwinian shortfalls. *Front. Biogeogr.* **15**, e59566 (2023). https://doi.org/10.21425/F5FBG59566
3. Moura, M. R. & Jetz, W. Shortfalls and opportunities in terrestrial vertebrate species discovery. *Nat. Ecol. Evol.* **5**, 631–639 (2021). https://doi.org/10.1038/s41559-021-01411-5
4. Oliver, R. Y., Meyer, C., Ranipeta, A., Winner, K. & Jetz, W. Global and national trends, gaps, and opportunities in documenting and monitoring species distributions. *PLoS Biol.* **19**, e3001336 (2021). https://doi.org/10.1371/journal.pbio.3001336
5. Parmesan, C. & Yohe, G. A globally coherent fingerprint of climate change impacts across natural systems. *Nature* **421**, 37–42 (2003). https://doi.org/10.1038/nature01286
6. Chen, I.-C., Hill, J. K., Ohlemüller, R., Roy, D. B. & Thomas, C. D. Rapid range shifts of species associated with high levels of climate warming. *Science* **333**, 1024–1026 (2011). https://doi.org/10.1126/science.1206432
7. Lenoir, J. & Svenning, J.-C. Climate-related range shifts – a global multidimensional synthesis and new research directions. *Ecography* **38**, 15–28 (2015). https://doi.org/10.1111/ecog.00967
8. Pecl, G. T. et al. Biodiversity redistribution under climate change: impacts on ecosystems and human well-being. *Science* **355**, eaai9214 (2017). https://doi.org/10.1126/science.aai9214
9. Chen, S. et al. Chinese provincial-level new records for 96 resident bird species reveal poleward range shifts. *Avian Res.* **16**, 100310 (2025). https://doi.org/10.1016/j.avrs.2025.100310
10. Ding, C., Ding, J., Qiao, H., Jiang, Z. & Wang, Z. Taxonomic and spatiotemporal patterns and ecological correlates of new mammal distribution records in China. *Glob. Ecol. Biogeogr.* **34**, e70165 (2025). https://doi.org/10.1111/geb.70165
11. Sullivan, B. L. et al. eBird: a citizen-based bird observation network in the biological sciences. *Biol. Conserv.* **142**, 2282–2292 (2009). https://doi.org/10.1016/j.biocon.2009.05.006
12. Chandler, M. et al. Contribution of citizen science towards international biodiversity monitoring. *Biol. Conserv.* **213**, 280–294 (2017). https://doi.org/10.1016/j.biocon.2016.09.004
13. Isaac, N. J. B., van Strien, A. J., August, T. A., de Zeeuw, M. P. & Roy, D. B. Statistics for citizen science: extracting signals of change from noisy ecological data. *Methods Ecol. Evol.* **5**, 1052–1060 (2014). https://doi.org/10.1111/2041-210X.12254
14. MacKenzie, D. I. et al. Estimating site occupancy rates when detection probabilities are less than one. *Ecology* **83**, 2248–2255 (2002). https://doi.org/10.1890/0012-9658(2002)083[2248:ESORWD]2.0.CO;2
15. Miller-ter Kuile, A. et al. If you're rare, should I care? How imperfect detection changes relationships between biodiversity and global change drivers. *Glob. Change Biol.* **31**, e70362 (2025). https://doi.org/10.1111/gcb.70362
16. Hughes, A. C. et al. Sampling biases shape our view of the natural world. *Ecography* **44**, 1259–1269 (2021). https://doi.org/10.1111/ecog.05926
17. Lahoz-Monfort, J. J. & Magrath, M. J. L. A comprehensive overview of technologies for species and habitat monitoring and conservation. *BioScience* **71**, 1038–1062 (2021). https://doi.org/10.1093/biosci/biab073
18. Burton, A. C. et al. Wildlife camera trapping: a review and recommendations for linking surveys to ecological processes. *J. Appl. Ecol.* **52**, 675–685 (2015). https://doi.org/10.1111/1365-2664.12432
19. Tingley, M. W. & Beissinger, S. R. Detecting range shifts from historical species occurrences: new perspectives on old data. *Trends Ecol. Evol.* **24**, 625–633 (2009). https://doi.org/10.1016/j.tree.2009.05.009
20. Boakes, E. H. et al. Distorted views of biodiversity: spatial and temporal bias in species occurrence data. *PLoS Biol.* **8**, e1000385 (2010). https://doi.org/10.1371/journal.pbio.1000385
21. Bowler, D. E. et al. Treating gaps and biases in biodiversity data as a missing data problem. *Biol. Rev.* **100**, 50–67 (2025). https://doi.org/10.1111/brv.13127
22. Beck, J., Böller, M., Erhardt, A. & Schwanghart, W. Spatial bias in the GBIF database and its effect on modeling species' geographic distributions. *Ecol. Inform.* **19**, 10–15 (2014). https://doi.org/10.1016/j.ecoinf.2013.11.002
23. Meyer, C., Kreft, H., Guralnick, R. & Jetz, W. Global priorities for an effective information basis of biodiversity distributions. *Nat. Commun.* **6**, 8221 (2015). https://doi.org/10.1038/ncomms9221
24. Schrodt, F. et al. Advancing causal inference in ecology: pathways for biodiversity change detection and attribution. *Methods Ecol. Evol.* **16**, 2276–2304 (2025). https://doi.org/10.1111/2041-210X.70131
25. Ding, C. et al. A dataset of provincial-level new distribution records for birds in China from 2000 to 2025. *Scientific Data* (in review).
26. Devictor, V., Julliard, R., Couvet, D. & Jiguet, F. Birds are tracking climate warming, but not fast enough. *Proc. R. Soc. B* **275**, 2743–2748 (2008). https://doi.org/10.1098/rspb.2008.0878
27. Devictor, V. et al. Differences in the climatic debts of birds and butterflies at a continental scale. *Nat. Clim. Change* **2**, 121–124 (2012). https://doi.org/10.1038/nclimate1347
28. La Sorte, F. A. & Thompson, F. R. Poleward shifts in winter ranges of North American birds. *Ecology* **88**, 1803–1812 (2007). https://doi.org/10.1890/06-1072.1
29. Loarie, S. R. et al. The velocity of climate change. *Nature* **462**, 1052–1055 (2009). https://doi.org/10.1038/nature08649
30. Burrows, M. T. et al. The pace of shifting climate in marine and terrestrial ecosystems. *Science* **334**, 652–655 (2011). https://doi.org/10.1126/science.1210288
31. Pinsky, M. L., Worm, B., Fogarty, M. J., Sarmiento, J. L. & Levin, S. A. Marine taxa track local climate velocities. *Science* **341**, 1239–1242 (2013). https://doi.org/10.1126/science.1239352
32. Poloczanska, E. S. et al. Global imprint of climate change on marine life. *Nat. Clim. Change* **3**, 919–925 (2013). https://doi.org/10.1038/nclimate1958
33. Williams, J. W. & Jackson, S. T. Novel climates, no-analog communities, and ecological surprises. *Front. Ecol. Environ.* **5**, 475–482 (2007). https://doi.org/10.1890/070037
34. Mahony, C. R., Cannon, A. J., Wang, T. & Aitken, S. N. A closer look at novel climates: new methods and insights at continental to landscape scales. *Glob. Change Biol.* **23**, 3934–3955 (2017). https://doi.org/10.1111/gcb.13645
35. Lundberg, S. M. et al. From local explanations to global understanding with explainable AI for trees. *Nat. Mach. Intell.* **2**, 56–67 (2020). https://doi.org/10.1038/s42256-019-0138-9
36. Chen, T. & Guestrin, C. XGBoost: a scalable tree boosting system. In *Proc. 22nd ACM SIGKDD Int. Conf. Knowledge Discovery and Data Mining* 785–794 (2016). https://doi.org/10.1145/2939672.2939785
37. Xing, X. et al. Where are the provincial-level new records in China from the past 20 years? *Front. Ecol. Evol.* **12**, 1415268 (2024). https://doi.org/10.3389/fevo.2024.1415268
38. Guillera-Arroita, G. Modelling of species distributions, range dynamics and communities under imperfect detection: advances, challenges and opportunities. *Ecography* **40**, 281–295 (2017). https://doi.org/10.1111/ecog.02445
39. Rumpf, S. B. et al. Range dynamics of mountain plants decrease with elevation. *Proc. Natl Acad. Sci. USA* **115**, 1848–1853 (2018). https://doi.org/10.1073/pnas.1713936115
40. Freeman, B. G., Scholer, M. N., Ruiz-Gutierrez, V. & Fitzpatrick, J. W. Climate change causes upslope shifts and mountaintop extirpations in a tropical bird community. *Proc. Natl Acad. Sci. USA* **115**, 11982–11987 (2018). https://doi.org/10.1073/pnas.1804224115
41. Mi, X. et al. The global significance of biodiversity science in China: an overview. *Natl Sci. Rev.* **8**, nwab032 (2021). https://doi.org/10.1093/nsr/nwab032
42. Amano, T., Lamming, J. D. L. & Sutherland, W. J. Spatial gaps in global biodiversity information and the role of citizen science. *BioScience* **66**, 393–400 (2016). https://doi.org/10.1093/biosci/biw022
43. Callaghan, C. T., Poore, A. G. B., Major, R. E., Rowley, J. J. L. & Cornwell, W. K. Optimizing future biodiversity sampling by citizen scientists. *Proc. R. Soc. B* **286**, 20191487 (2019). https://doi.org/10.1098/rspb.2019.1487
44. Kelling, S. et al. Using semistructured surveys to improve citizen science data for monitoring biodiversity. *BioScience* **69**, 170–179 (2019). https://doi.org/10.1093/biosci/biz010
45. Dickinson, J. L., Zuckerberg, B. & Bonter, D. N. Citizen science as an ecological research tool: challenges and benefits. *Annu. Rev. Ecol. Evol. Syst.* **41**, 149–172 (2010). https://doi.org/10.1146/annurev-ecolsys-102209-144636
46. Bowler, D. E. et al. Mapping human pressures on biodiversity across the planet uncovers anthropogenic threat complexes. *People Nat.* **2**, 380–394 (2020). https://doi.org/10.1002/pan3.10071
47. Sunday, J. M., Bates, A. E. & Dulvy, N. K. Thermal tolerance and the global redistribution of animals. *Nat. Clim. Change* **2**, 686–690 (2012). https://doi.org/10.1038/nclimate1539
48. Guisan, A. & Thuiller, W. Predicting species distribution: offering more than simple habitat models. *Ecol. Lett.* **8**, 993–1009 (2005). https://doi.org/10.1111/j.1461-0248.2005.00792.x
49. Elith, J., Phillips, S. J., Hastie, T., Dudík, M., Chee, Y. E. & Yates, C. J. A statistical explanation of MaxEnt for ecologists. *Divers. Distrib.* **17**, 43–57 (2011). https://doi.org/10.1111/j.1472-4642.2010.00725.x
50. Guillera-Arroita, G. et al. Is my species distribution model fit for purpose? Matching data and models to applications. *Glob. Ecol. Biogeogr.* **24**, 276–292 (2015). https://doi.org/10.1111/geb.12268
51. Phillips, S. J. et al. Sample selection bias and presence-only distribution models: implications for background and pseudo-absence data. *Ecol. Appl.* **19**, 181–197 (2009). https://doi.org/10.1890/07-2153.1
52. Johnston, A. et al. Analytical guidelines to increase the value of community science data: an example using eBird data to estimate species distributions. *Divers. Distrib.* **27**, 1265–1277 (2021). https://doi.org/10.1111/ddi.13271
53. Harris, I., Osborn, T. J., Jones, P. & Lister, D. Version 4 of the CRU TS monthly high-resolution gridded multivariate climate dataset. *Sci. Data* **7**, 109 (2020). https://doi.org/10.1038/s41597-020-0453-3
54. Fick, S. E. & Hijmans, R. J. WorldClim 2: new 1-km spatial resolution climate surfaces for global land areas. *Int. J. Climatol.* **37**, 4302–4315 (2017). https://doi.org/10.1002/joc.5086
55. Brooks, M. E. et al. glmmTMB balances speed and flexibility among packages for zero-inflated generalized linear mixed modeling. *R J.* **9**, 378–400 (2017). https://doi.org/10.32614/RJ-2017-066
56. Nakagawa, S. & Schielzeth, H. A general and simple method for obtaining *R*² from generalized linear mixed-effects models. *Methods Ecol. Evol.* **4**, 133–142 (2013). https://doi.org/10.1111/j.2041-210x.2012.00261.x
57. Pebesma, E. Simple Features for R: standardized support for spatial vector data. *R J.* **10**, 439–446 (2018). https://doi.org/10.32614/RJ-2018-009
58. Lenoir, J. et al. Species better track climate warming in the oceans than on land. *Nat. Ecol. Evol.* **4**, 1044–1059 (2020). https://doi.org/10.1038/s41559-020-1198-2
59. Scheffers, B. R. et al. The broad footprint of climate change from genes to biomes to people. *Science* **354**, aaf7671 (2016). https://doi.org/10.1126/science.aaf7671
60. Román-Palacios, C. & Wiens, J. J. Recent responses to climate change reveal the drivers of species extinction and survival. *Proc. Natl Acad. Sci. USA* **117**, 4211–4217 (2020). https://doi.org/10.1073/pnas.1913007117
61. Lehikoinen, A. et al. Declining population trends of European mountain birds. *Glob. Change Biol.* **25**, 577–588 (2019). https://doi.org/10.1111/gcb.14522
62. Rosenberg, K. V. et al. Decline of the North American avifauna. *Science* **366**, 120–124 (2019). https://doi.org/10.1126/science.aaw1313
63. van Strien, A. J., van Swaay, C. A. M. & Termaat, T. Opportunistic citizen science data of animal species produce reliable estimates of distribution trends if analysed with occupancy models. *J. Appl. Ecol.* **50**, 1450–1458 (2013). https://doi.org/10.1111/1365-2664.12158
64. Kéry, M., Royle, J. A., Schmid, H. et al. Importance of sampling design and analysis in animal population studies. *J. Appl. Ecol.* **45**, 981–986 (2008). https://doi.org/10.1111/j.1365-2664.2007.01421.x
65. Steen, V. A., Elphick, C. S. & Tingley, M. W. An evaluation of stringent filtering to improve species distribution models from citizen science data. *Divers. Distrib.* **25**, 1857–1869 (2019). https://doi.org/10.1111/ddi.12985
66. Fink, D. et al. Modeling avian full annual cycle distribution and population trends with citizen science data. *Ecol. Appl.* **30**, e02056 (2020). https://doi.org/10.1002/eap.2056
67. Zizka, A. et al. CoordinateCleaner: standardized cleaning of occurrence records from biological collection databases. *Methods Ecol. Evol.* **10**, 744–751 (2019). https://doi.org/10.1111/2041-210X.13152
68. Bird, T. J. et al. Statistical solutions for error and bias in global citizen science datasets. *Biol. Conserv.* **173**, 144–154 (2014). https://doi.org/10.1016/j.biocon.2013.07.037
69. Sofaer, H. R. et al. Development and delivery of species distribution models to inform decision-making. *BioScience* **69**, 544–557 (2019). https://doi.org/10.1093/biosci/biz045
70. Hurlbert, A. H. & Liang, Z. Spatiotemporal variation in avian migration phenology: citizen science reveals effects of climate change. *PLoS ONE* **7**, e31662 (2012). https://doi.org/10.1371/journal.pone.0031662
71. Thomas, C. D. Climate, climate change and range boundaries. *Divers. Distrib.* **16**, 488–495 (2010). https://doi.org/10.1111/j.1472-4642.2010.00642.x

*All digital object identifiers were verified against Crossref on 26 July 2026. Reference 25 is a
companion data descriptor currently in review and will be updated on acceptance.*

---

## Figure legends

**Figure 1 | Survey effort dominates, but accumulated climate change raises new-record hazard
independently.** **a**, Hazard ratios per standard deviation with 95% confidence intervals for the
four fixed effects, at three species-distribution-model thresholds. **b**, Predicted annual hazard
against accumulated climate change at four levels of survey effort; flattening at high effort is
the negative interaction. **c**, Drop-term contribution of each process to explained deviance.
Components overlap slightly, so shares sum to more than 100%.

**Figure 2 | The ecological signal is decadal and specification-dependent.** **a**, Climate-change
hazard ratio by climate indicator and accumulation window; no signal is detectable at a five-year
window. **b**, Model improvement over an effort-only model. **c**, Climate main effect and its
interaction with effort across five survey-effort proxies.

**Figure 3 | Model selection ladder.** ΔAIC across seven candidate models at three thresholds. The
interaction model improves on the additive model at every threshold. The static-mismatch model
fits best but encodes a time-invariant pair-level confounder rather than a mechanism, and was
retained only as a sensitivity check.

**Figure 4 | Where new records are expected to emerge.** Provincial hazard relative to 2024 under
two shared socio-economic pathways at three horizons, from the mechanistic model (**a**) and a
gradient-boosted counterpart (**b**), with TreeSHAP attribution (**c**) and agreement between
models (**d**). Late-century panels extrapolate effort well beyond the observed range and are
scenario illustrations rather than forecasts.

**Extended Data Figure 1 | Interaction surface.** Predicted hazard across the joint
climate-change × survey-effort plane with observed events overlaid; converging iso-hazard contours
toward high effort show the negative interaction.

**Extended Data Figure 2 | Residual diagnostics.** Simulation-based residual checks for the final
model.
