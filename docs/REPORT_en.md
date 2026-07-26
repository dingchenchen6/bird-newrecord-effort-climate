# Survey effort, climate change and the generation of new bird distribution records in China

**Research report · 26 July 2026**

---

## 1. Question

New provincial bird distribution records in China have risen sharply over the past two decades.
Two very different readings are possible:

1. **Observation-process hypothesis** — the explosive growth of citizen science is revealing
   species that were already present;
2. **Ecological-process hypothesis** — climate change is driving genuine range shifts.

The policy implications are opposite: under the first, new records index **monitoring intensity**;
under the second, they index **climate change**. This study separates the two processes inside a
single discrete-time survival framework and tests whether they interact.

**Hypotheses**

- **H1** Survey effort is the dominant condition for a new record to be found
- **H2** Accumulated climate change independently raises new-record hazard
- **H3** The strength of the climate effect varies with survey effort
- **H4** Interannual climate variability acts through a channel separate from the long-term trend

---

## 2. Data and risk set

### 2.1 Events and risk set

An event is the **first** new distribution record of a species in a province (2002–2024). The risk
set is the full **species × province × year** expansion, with absorbing exit after the event.

The candidate pool follows three rules: SDM-predicted potential presence with no historical
presence, **plus forced inclusion of every observed event**, restricted to the union of
SDM-modelled species. SDM binarisation thresholds of **50 / 100 / 200** are carried as a
sensitivity.

Final modelling set (threshold 50): **182,485 rows, 655 events, 394 species, 32 provincial
units**; event rate 0.359 %.

### 2.2 Scope decisions

**Vagrants excluded.** 69 species with no Chinese historical range have no definable native-range
climate baseline; they are dropped rather than imputed. The events analysed therefore represent
**range expansion and newly detected populations**, not vagrancy.

**Taiwan and Macau excluded, Hong Kong retained.** The criterion is **record density per unit
area**, not absolute counts:

| Region | 2024 records | Area | Density | Decision |
|---|---|---|---|---|
| Beijing | 487,791 | 16,400 km² | 29.7 km⁻² | reference |
| Hong Kong | 18,142 | 1,100 km² | **16.5 km⁻²** | retained — low counts reflect small area |
| Taiwan | 4,836 | 36,000 km² | **0.13 km⁻²** | excluded — source-coverage gap |
| Macau | data in 2 of 23 years | — | — | excluded |

### 2.3 Survey effort

Effort comes from the combined source (eBird/GBIF ∪ China Bird Report), quantified by four
observation proxies (records, visits, observers, birding-days) plus a PCA composite.

**Key treatment: missing mainland province-years are structural zeros, not missing data.** The
diagnostic is that every raw effort measure has a minimum of 1 and contains no zeros — proof
that the panel is a record aggregation in which a province-year with no records simply produces
no row. The previous implementation dropped these rows via an `is.finite()` filter, systematically
truncating the lower tail of the effort distribution and **discarding 11 real events along with
them**. After correction, 5,675 structural-zero rows are restored and structural completeness is
100 % at all three thresholds.

---

## 3. Climate variables: definition and decomposition

### 3.1 Species-specific climate gradient

With s = species, p = province, t = year and a 1980–2000 baseline:

| Symbol | Definition |
|---|---|
| `T(p,t)` | area-weighted mean of the indicator over 100 km grid cells in province p |
| `N(s,t)` | mean over grid cells within the species' Chinese historical range (BirdLife) |
| `T_base(p)`, `N_base(s)` | respective 1980–2000 means |
| **`x(s,p,t)`** | `[T(p,t) − T_base(p)] − [N(s,t) − N_base(s)]` |

`x` measures the target province's climate anomaly **relative to the anomaly over the species'
own native range**, and is therefore species-specific.

### 3.2 Three-way decomposition (backward-looking only)

Covariates in a survival model must not contain future information, so the rolling window uses
only `[t−W+1, t]`:

| Component | Definition | Mechanism |
|---|---|---|
| `b_static(s,p)` | `T_base(p) − N_base(s)` | historical climate mismatch (static) |
| **`clim_change`** | trailing W-year mean of `x` | **accumulated climate change** |
| **`clim_var`** | `x(t) − clim_change(t)` | **interannual climate variability** |

The components are nearly orthogonal (`cor(clim_change, clim_var)` between −0.076 and +0.078
across all indicator × window combinations).

**This decomposition is the key methodological step.** Without it the positive effect of
accumulated change and the negative effect of interannual variability **cancel**, and an
undecomposed annual anomaly shows exactly no effect (HR = 0.999, *P* = 0.97).

### 3.3 Window length

| Window | Accumulated climate change HR | *P* | ΔAIC vs effort-only |
|---|---|---|---|
| 5 yr | 1.054 | 0.30 | −0.8 |
| 10 yr | 1.269 | 1.6 × 10⁻⁵ | −25.6 |
| **15 yr** | **1.397** | **8.7 × 10⁻⁹** | **−42.1** |
| 20 yr | 1.431 | 2.3 × 10⁻⁹ | −40.3 |

**A 5-year window detects nothing.** The signal appears from 10 years and peaks at 15. This is
itself a mechanistic result: **new records respond to sustained decadal warming, not to single
warm years.**

---

## 4. Model

### 4.1 Final specification

```r
event ~ clim_change_z * effort_z + clim_var_z + (1 | species) + (1 | province)
family = binomial("cloglog")
```

The complementary log-log link is the correct form for a discrete-time proportional-hazards
model (logit is not); `exp(β)` is the hazard ratio.

### 4.2 Model ladder

ΔAIC at threshold 50 (0 = best):

| Model | ΔAIC |
|---|---|
| N0 null | 226.7 |
| N1 effort only | 54.8 |
| N2 climate only | 180.4 |
| N3 additive | 18.6 |
| **N4 climate change × effort + variability (selected)** | **12.2** |
| N5 both interactions | 12.7 |
| N6 + static mismatch | 0.0 |

**N4 beats N5**, so interannual variability needs only a main effect; its interaction with effort
does not improve fit and is dropped for parsimony.

**N6 is best by AIC but was not selected.** `b_static` is a time-invariant pair-level quantity
measuring which provinces are climatically suitable for a species in the first place — and the
risk set is itself SDM-constructed, so it is a confounder rather than a mechanism. Dropping it
*strengthens* the climate-change effect (1.300 → 1.408) and leaves the interaction essentially
unchanged, at a cost of 13–20 AIC. It is retained only as a sensitivity check.

### 4.3 Random-effect structure

| Structure | AIC | Converged | Decision |
|---|---|---|---|
| `(1\|species)+(1\|province)` | 6450.6 | ✓ | **adopted** |
| `+ (1\|year)` | 6442.4 | ✓ | robustness (all three effects remain significant) |
| `+ (1+cz\|species)` | 6453.5 | ✓ | no support for trait-mediated sensitivity |
| `(1+effort\|species)` | 6451.7 | ✗ | rejected |
| **`+ (1\|species:province)` pair frailty** | **5258.7** | ✓ | **must be rejected** |

**The 1192-point AIC drop for pair frailty is an artefact.** Diagnostics: the `species` and
`province` random-effect SDs both **collapse to 0.000**, the `pair` SD reaches 11.5–16.3, and the
effort HR explodes to 11.7–39.3. Under rare events most species–province pairs never experience
an event, so the pair-level intercept tends to −∞ (complete separation at the pair level).
**AIC alone would select this degenerate model**; variance components and effect magnitudes must
be inspected alongside it.

---

## 5. Results

### 5.1 Coefficients

| Term | β | HR | 95 % CI | *P* |
|---|---|---|---|---|
| Intercept | −5.9064 | — | — | baseline annual hazard 0.272 % |
| **Survey effort** | 0.5809 | **1.788** | 1.639–1.951 | 7.7 × 10⁻³⁹ |
| **Accumulated climate change** | 0.3322 | **1.394** | 1.244–1.562 | 1.0 × 10⁻⁸ |
| **Annual climate variability** | −0.1622 | **0.850** | 0.781–0.926 | 1.8 × 10⁻⁴ |
| **Climate change × effort** | −0.1325 | **0.876** | 0.801–0.959 | 3.9 × 10⁻³ |

### 5.2 Relative importance

Drop-term contribution to explained deviance, consistent across thresholds:

| Component | thr 50 | thr 100 | thr 200 |
|---|---|---|---|
| Survey effort | 77.6 % | 77.2 % | 77.9 % |
| Accumulated climate change | 15.4 % | 15.5 % | 14.7 % |
| Annual climate variability | 6.9 % | 6.8 % | 6.9 % |
| Interaction | 4.4 % | 4.3 % | 4.3 % |

### 5.3 Robustness

- **Threshold**: climate change 1.397 / 1.411 / 1.406; interaction 0.873 / 0.875 / 0.874
- **Effort proxy**: climate change 1.371–1.408 (*P* ≤ 5 × 10⁻⁸); interaction 0.839–0.895 (*P* ≤ 0.033)
- **Climate indicator**: annual mean temperature best; warmest-month Tmax intermediate
  (ΔAIC −29.8); winter mean T and coldest-month Tmin show no signal under this decomposition

### 5.4 Diagnostics (DHARMa, 500 simulations)

| Test | Statistic | *P* | Verdict |
|---|---|---|---|
| KS uniformity | 0.0017 | 0.66 | ✓ |
| Dispersion | 0.911 | 0.41 | ✓ |
| Grouped residuals (province) | 0.086 | 0.96 | ✓ |
| Temporal autocorrelation (DW) | 1.797 | 0.62 | ✓ |
| Spatial autocorrelation (Moran's I) | −0.025 | 0.79 | ✓ |
| Grouped residuals (year) | 0.292 | 0.031 | ⚠ |
| Grouped residuals (species) | 0.098 | 0.0011 | ⚠ |

Residual species-level heterogeneity is consistent with the random-slope tests and is reported
as a limitation.

---

## 6. Future scenarios

CMIP6 four-model ensemble (ACCESS-CM2, MPI-ESM1-2-HR, MIROC6, UKESM1-0-LL), SSP2-4.5 and
SSP5-8.5 × 2030 / 2050 / 2080.

**Critical treatment: the CMIP6 delta must be applied to both the target province and the
species' range.** Because the climate term is a species-specific difference, spatially near-uniform
warming cancels between the two ends. Measured deltas are almost identical (SSP5-8.5, 2080:
province mean +4.38 °C vs range mean +4.47 °C); applying the delta to the province end only would
manufacture a climate effect out of nothing.

The mechanistic model and XGBoost agree closely on the spatial pattern. **Attribution differs
systematically, however**: TreeSHAP assigns survey effort 48.5 %, accumulated climate change
26.5 % and interannual variability 25.1 %, against 78 % for effort in the mechanistic deviance
decomposition. The boosted-tree model has no random effects, so climate features partly encode
species and province identity — the same phenomenon documented earlier as the contradiction
between tree-model importance and hazard-model decomposition.

**Extrapolation warning.** By 2080 effort is projected 1.7 SD (SSP2-4.5) to 3.4 SD (SSP5-8.5)
beyond the observed range. Late-century maps illustrate model behaviour; they are not forecasts.

---

## 7. Problems found and corrected during the analysis

| # | Problem | Consequence | Resolution |
|---|---|---|---|
| 1 | 48.6 % of province-years in the legacy climate panel were fill values (82 % in 2002) | manufactured a strong spurious climate × effort interaction (HR 1.27–1.43) | rebuilt from CRU / WorldClim source series |
| 2 | `temp_grad_prov` was an exact alias of `temp_anom` | the nine climate proxies span only seven independent axes | documented |
| 3 | six climate indicators had a single unique value per province, absorbed by `(1\|province)` | their "absence of interaction" was non-identifiability, not ecology | replaced with time-varying indicators |
| 4 | the published analysis used a **province-level** variable as the species-specific climate term | 307 species shared one value within a province-year | replaced with a genuine species-specific gradient |
| 5 | an `is.finite()` filter silently dropped structural-zero effort rows | 11 real events lost; lower tail of the effort distribution truncated | 5,675 rows restored; events 817 → 828 |
| 6 | climate panels were extracted only for 2002–2024 | trailing windows consumed the start of the analysis period (W = 10 left only 521 events) | extraction extended to the full 1980–2024 series |
| 7 | niche-distance metrics drew 99.7 % of their variance from between-pair static matching | an apparently decisive result (*P* = 1.3 × 10⁻⁸) was near-tautological | switched to within–between decomposition |
| 8 | pair-level frailty produced a large AIC gain | degenerate fit: variance components collapsed, effort HR reached 39 | structure rejected, criteria recorded |

---

## 8. Conclusion

**New records are produced by the observation process and the ecological process together, not
by one of them.**

Survey effort sets the basic condition for discovery and accounts for about 78 % of explained
deviance. On top of that, **decadal accumulated climate change independently raises hazard by
about 39 % per SD**, and it does so **most strongly where survey effort is low** (negative
interaction, HR = 0.876). Interannual climate variability acts through a separate channel, in the
opposite direction.

The ecological reading of the negative interaction is that in well-surveyed provinces a species
will be found sooner or later and climate is not the bottleneck; in poorly surveyed provinces a
climate-driven distributional change is needed before a new record is generated.

**New records therefore index both monitoring intensity and climate change, but the relative
weight of the two shifts systematically with survey intensity.**

---

## 9. Limitations

1. Survey effort and calendar year are collinear (*r* = 0.79); "effort dominates" and "time trend
   controlled" cannot both be had, and both specifications are reported.
2. Residual species-level heterogeneity is not fully absorbed by the random intercepts
   (grouped residuals *P* = 0.0011).
3. Precipitation is not in the final model (no signal under the three-way decomposition).
4. Late-century projections are substantial extrapolations.
5. Events are resolved to province; although record coordinates exist, grid-level refitting has
   been shown to be infeasible for this event set.

---

*All numbers are indexable by name in `tables/`; source data accompany every figure.*
