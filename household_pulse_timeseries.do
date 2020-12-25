// Household Pulse Survey, static test.
import delimited pulse2020_puf_19.csv, clear
* keep tbirth_year egender rhispanic rrace eeduc ms thhld_numper thhld_numkid thhld_numadlt wrkloss expctloss anywork rsnnowrk unemppay hlthstatus delay notget hlthins* enroll* teach* comp* intrnt* schlhrs tstdy_hrs tch_hrs income est_st

gen children = .
replace children = 1 if thhld_numkid > 0
replace children = 0 if thhld_numkid == 0

gen age = 2020 - tbirth_year
gen state = est_st
gen white = (rrace == 1)

gen years_educ = .
replace years_educ = 8 if eeduc == 1
replace years_educ = 10 if eeduc == 2
replace years_educ = 12 if eeduc == 3
replace years_educ = 14 if eeduc == 4 | eeduc == 5
replace years_educ = 16 if eeduc == 6
replace years_educ = 19 if eeduc == 7

gen jobloss = .
replace jobloss = 1 if wrkloss == 1
replace jobloss = 0 if wrkloss == 2

* UI is not a good proxy for unemployment.
gen unemployed = .
replace unemployed = 1 if anywork == 2
replace unemployed = 0 if anywork == 1

* First compare adults with children and without children.
* reg jobloss children i.state age white years_educ
* reg unemployed children i.state age white years_educ

* Only compare adults with children: school disrupted?
gen sch_cancelled = .
replace sch_cancelled = 1 if teach1 == 1
replace sch_cancelled = 0 if teach2 == 1 | teach3 == 1 | teach4 == 1 | teach5 == 1
gen sch_virtual = .
replace sch_virtual = 1 if teach2 == 1 | teach3 == 1 | teach4 == 1
replace sch_virtual = 0 if teach1 == 1 | teach5 == 1
gen sch_disrupted = .
replace sch_disrupted = 1 if teach1 == 1 | teach2 == 1 | teach3 == 1 | teach4 == 1
replace sch_disrupted = 0 if teach5 == 1

* Regression DD, as in CPS data.
* No time effect, since this is a snapshot.
* This isn't precise enough.
reg unemployed i.sch_disrupted##i.children i.state age white years_educ
reg jobloss i.sch_disrupted##i.children i.state age white years_educ

* Keep adults with children.
keep if children == 1

* Focus on job loss.
reg jobloss sch_cancelled sch_virtual i.state age white years_educ, baselevels

* What about the effect of live virtual contact with teachers? Self study?
* Recode live virtual contact with teachers.
gen days_virtualschl = .
replace days_virtualschl = 0 if schlhrs == 1
replace days_virtualschl = 1 if schlhrs == 2
replace days_virtualschl = 2.5 if schlhrs == 3
replace days_virtualschl = 4.5 if schlhrs == 4
* Seems unreliable if sch_virtual is not 1.
bys sch_virtual sch_cancelled: tabulate days_virtualschl

* Recode studying on their own.
gen hrs_selfstudy = tstdy_hrs if tstdy_hrs >= 0
* Unclear if this variable has anything to do with childcare/school closures.
bys sch_virtual sch_cancelled: summ hrs_selfstudy

* Focus on virtual school + live virtual contact with teachers.
reg jobloss days_virtualschl i.state age white years_educ if sch_virtual == 1
* reg jobloss days_virtualschl i.state age white years_educ if sch_cancelled == 1
* reg jobloss days_virtualschl i.state age white years_educ
* IV? Huge errors: virtual schooling is also not a good instrument since it is still reflective of the school's resources.
* ivregress 2sls jobloss (days_virtualschl = sch_virtual) i.state age white years_educ


// Household Pulse Survey, extract Phase 2 and 3 timeseries.
* Use `week' variable to keep track of time.

/*
import delimited pulse2020_puf_19.csv, clear
* Calendar week
gen calweek = 46
tempfile hpsdata
save `hpsdata'
import delimited pulse2020_puf_18.csv, clear
quietly: append using `hpsdata'
replace calweek = 44 if calweek == .
save `hpsdata', replace
import delimited pulse2020_puf_17.csv, clear
quietly: append using `hpsdata'
replace calweek = 42 if calweek == .
save `hpsdata', replace
import delimited pulse2020_puf_16.csv, clear
quietly: append using `hpsdata'
replace calweek = 40 if calweek == .
save `hpsdata', replace
import delimited pulse2020_puf_15.csv, clear
quietly: append using `hpsdata'
replace calweek = 38 if calweek == .
save `hpsdata', replace
import delimited pulse2020_puf_14.csv, clear
quietly: append using `hpsdata'
replace calweek = 36 if calweek == .
save `hpsdata', replace
import delimited pulse2020_puf_13.csv, clear
quietly: append using `hpsdata'
replace calweek = 34 if calweek == .
save hpsdata.dta, replace
*/
use hpsdata.dta, clear

gen female = .
replace female = 1 if egender == 2
replace female = 0 if egender == 1

gen children = .
replace children = 1 if thhld_numkid > 0
replace children = 0 if thhld_numkid == 0

gen age = 2020 - tbirth_year
gen state = est_st
gen white = (rrace == 1)

gen years_educ = .
replace years_educ = 8 if eeduc == 1
replace years_educ = 10 if eeduc == 2
replace years_educ = 12 if eeduc == 3
replace years_educ = 14 if eeduc == 4 | eeduc == 5
replace years_educ = 16 if eeduc == 6
replace years_educ = 19 if eeduc == 7

/*
gen jobloss = .
replace jobloss = 1 if wrkloss == 1
replace jobloss = 0 if wrkloss == 2
*/
* wrkloss is not a good proxy for job loss since it asks about job losses since March 13.

* This question asks about expected job losses in the household in the next 7 days.
gen jobloss = .
replace jobloss = 1 if expctloss == 1
replace jobloss = 0 if expctloss == 2

/*
gen unemployed = .
replace unemployed = 1 if ui_recv == 1
replace unemployed = 0 if ui_recv == 2
*/
* UI is not a good proxy for unemployment.
* The UI question asks for UI receipt since March 13.

* This question asks about work for pay in the past 7 days.
gen unemployed = .
replace unemployed = 1 if anywork == 2
replace unemployed = 0 if anywork == 1

* Only compare adults with children: school disrupted?
gen sch_cancelled = .
replace sch_cancelled = 1 if teach1 == 1
replace sch_cancelled = 0 if teach2 == 1 | teach3 == 1 | teach4 == 1 | teach5 == 1
gen sch_virtual = .
replace sch_virtual = 1 if teach2 == 1 | teach3 == 1 | teach4 == 1
replace sch_virtual = 0 if teach1 == 1 | teach5 == 1
gen sch_disrupted = .
replace sch_disrupted = 1 if teach1 == 1 | teach2 == 1 | teach3 == 1 | teach4 == 1
replace sch_disrupted = 0 if teach5 == 1

gen days_virtualschl = .
replace days_virtualschl = 0 if schlhrs == 1
replace days_virtualschl = 1 if schlhrs == 2
replace days_virtualschl = 2.5 if schlhrs == 3
replace days_virtualschl = 4.5 if schlhrs == 4

tempfile hpsdata
save `hpsdata', replace

// Import OxCGRT data, weekly aggregates.
import delimited OxCGRT_latest.csv, clear
keep if countrycode == "USA" & jurisdiction == "STATE_TOTAL"
gen calweek = .
gen enumday = .
bys regioncode: replace enumday = _n
replace calweek = int(enumday/7+1)
* Recode fortnights using HPS weeks.
gen week = int(calweek/2)-4

* Relabel states.
gen state = .
replace state = 01 if regioncode == "US_AL"
replace state = 30 if regioncode == "US_MT"
replace state = 02 if regioncode == "US_AK"
replace state = 31 if regioncode == "US_NE"
replace state = 04 if regioncode == "US_AZ"
replace state = 32 if regioncode == "US_NV"
replace state = 05 if regioncode == "US_AR"
replace state = 33 if regioncode == "US_NH"
replace state = 06 if regioncode == "US_CA"
replace state = 34 if regioncode == "US_NJ"
replace state = 08 if regioncode == "US_CO"
replace state = 35 if regioncode == "US_NM"
replace state = 09 if regioncode == "US_CT"
replace state = 36 if regioncode == "US_NY"
replace state = 10 if regioncode == "US_DE"
replace state = 37 if regioncode == "US_NC"
replace state = 11 if regioncode == "US_DC"
replace state = 38 if regioncode == "US_ND"
replace state = 12 if regioncode == "US_FL"
replace state = 39 if regioncode == "US_OH"
replace state = 13 if regioncode == "US_GA"
replace state = 40 if regioncode == "US_OK"
replace state = 15 if regioncode == "US_HI"
replace state = 41 if regioncode == "US_OR"
replace state = 16 if regioncode == "US_ID"
replace state = 42 if regioncode == "US_PA"
replace state = 17 if regioncode == "US_IL"
replace state = 44 if regioncode == "US_RI"
replace state = 18 if regioncode == "US_IN"
replace state = 45 if regioncode == "US_SC"
replace state = 19 if regioncode == "US_IA"
replace state = 46 if regioncode == "US_SD"
replace state = 20 if regioncode == "US_KS"
replace state = 47 if regioncode == "US_TN"
replace state = 21 if regioncode == "US_KY"
replace state = 48 if regioncode == "US_TX"
replace state = 22 if regioncode == "US_LA"
replace state = 49 if regioncode == "US_UT"
replace state = 23 if regioncode == "US_ME"
replace state = 50 if regioncode == "US_VT"
replace state = 24 if regioncode == "US_MD"
replace state = 51 if regioncode == "US_VA"
replace state = 25 if regioncode == "US_MA"
replace state = 53 if regioncode == "US_WA"
replace state = 26 if regioncode == "US_MI"
replace state = 54 if regioncode == "US_WV"
replace state = 27 if regioncode == "US_MN"
replace state = 55 if regioncode == "US_WI"
replace state = 28 if regioncode == "US_MS"
replace state = 56 if regioncode == "US_WY"
replace state = 29 if regioncode == "US_MO"
drop if regioncode == "US_VI"

collapse (max) c1_schoolclosing c2_workplaceclosing c3_cancelpublicevents e1_incomesupport e2_debtcontractrelief, by(state week)
keep if week >= 13 & week <= 19

merge 1:m state week using `hpsdata'
drop _merge

gen school_disrupted = (c1_schoolclosing >= 2)
gen school_changed = (c1_schoolclosing >= 1)
* school_closing >= 2: schools closed
* school_closing == 1: change in operation e.g. virtual

* Naive.
* Should we control for state? - robustness check (if we aren't doing IV)
reg jobloss sch_cancelled sch_virtual age white years_educ, baselevels
reg jobloss sch_cancelled sch_virtual age white years_educ i.state, baselevels
reg jobloss sch_cancelled sch_virtual age white years_educ i.week, baselevels
reg jobloss sch_cancelled sch_virtual age white years_educ i.state i.week, baselevels

reg jobloss days_virtualschl age white years_educ if sch_virtual == 1
reg jobloss days_virtualschl i.state age white years_educ if sch_virtual == 1
reg jobloss days_virtualschl i.week age white years_educ if sch_virtual == 1
reg jobloss days_virtualschl i.state i.week age white years_educ if sch_virtual == 1

* Reduced form.
reg jobloss i.c1_schoolclosing age white years_educ, baselevels
reg jobloss i.c1_schoolclosing i.c2_workplaceclosing age white years_educ, baselevels
reg jobloss i.c1_schoolclosing i.c2_workplaceclosing age white years_educ i.week, baselevels

* Should IV have controls?
ivregress 2sls jobloss (sch_virtual = i.c1_schoolclosing) i.c2_workplaceclosing, baselevels
* ivregress 2sls jobloss (sch_cancelled = i.c1_schoolclosing) i.c2_workplaceclosing, baselevels
ivregress 2sls jobloss (days_virtualschl = i.c1_schoolclosing) i.c2_workplaceclosing, baselevels

ivregress 2sls jobloss (sch_virtual = i.c1_schoolclosing) i.c2_workplaceclosing i.week, baselevels
* ivregress 2sls jobloss (sch_cancelled = i.c1_schoolclosing) i.c2_workplaceclosing i.week, baselevels
ivregress 2sls jobloss (days_virtualschl = i.c1_schoolclosing) i.c2_workplaceclosing i.week, baselevels

// Regressions of interest.
* Summary statistics.
summ female children white age years_educ unemployed jobloss if age >= 25 & age <= 54
bys female: summ unemployed jobloss if age >= 25 & age <= 54

* Try regression DD, now with timeseries.
* Use statewide cancellation info. Doesn't make sense to individualize since school disruption is conditional on whether the household has children.
* Still can't identify significant effect, probably because changes are less sudden and drastic than before.
* Note: distinguish between sch_disrupted (individual schools) and school_disrupted (statewide).
reg unemployed school_disrupted i.state i.week if age >= 25 & age <= 54
reg jobloss school_disrupted i.state i.week if age >= 25 & age <= 54

reg unemployed school_disrupted##i.children i.state i.week if age >= 25 & age <= 54
reg jobloss school_disrupted##i.children i.state i.week if age >= 25 & age <= 54

reg unemployed school_disrupted##i.children i.state i.week age white years_educ if age >= 25 & age <= 54
reg jobloss school_disrupted##i.children i.state i.week age white years_educ if age >= 25 & age <= 54

* Focus on impact of school disruption type and/or teacher hours.
* Don't include self-study since that isn't necessarily a reflection of school disruptions.
* Impact of self-reported school disruption.
reg unemployed sch_disrupted age white years_educ if age >= 25 & age <= 54 & children == 1
reg jobloss sch_disrupted age white years_educ if age >= 25 & age <= 54 & children == 1
* What if we only control for weeks? We get larger coefficients, probably because unemployment also depends on other state policy.
reg unemployed sch_disrupted i.week age white years_educ if age >= 25 & age <= 54 & children == 1
reg jobloss sch_disrupted i.week age white years_educ if age >= 25 & age <= 54 & children == 1
/*
* Further control for other policy? Small effect, but not complete.
reg unemployed sch_disrupted i.c2_workplaceclosing i.week age white years_educ if age >= 25 & age <= 54 & children == 1
reg jobloss sch_disrupted i.c2_workplaceclosing i.week age white years_educ if age >= 25 & age <= 54 & children == 1
reg unemployed sch_disrupted i.week i.c2_workplaceclosing i.c3_cancelpublicevents i.e1_incomesupport i.e2_debtcontractrelief age white years_educ if age >= 25 & age <= 54 & children == 1
reg jobloss sch_disrupted i.week i.c2_workplaceclosing i.c3_cancelpublicevents i.e1_incomesupport i.e2_debtcontractrelief age white years_educ if age >= 25 & age <= 54 & children == 1
reg unemployed sch_disrupted i.c2_workplaceclosing age white years_educ if age >= 25 & age <= 54 & children == 1
reg jobloss sch_disrupted i.c2_workplaceclosing i.week age white years_educ if age >= 25 & age <= 54 & children == 1
reg unemployed sch_disrupted i.c2_workplaceclosing i.c3_cancelpublicevents i.e1_incomesupport i.e2_debtcontractrelief age white years_educ if age >= 25 & age <= 54 & children == 1
reg jobloss sch_disrupted i.week i.c2_workplaceclosing i.c3_cancelpublicevents i.e1_incomesupport i.e2_debtcontractrelief age white years_educ if age >= 25 & age <= 54 & children == 1
*/
* Is controlling for week even important? No! This is probably because of the irregular times at which school disruptions are imposed or relaxed.
* However, week controls won't hurt, and will address concerns about national shifts in pandemic impact / policy.
* The other policy controls capture some, but certainly not all state effects (which might include political pressure, prevailing sentiment, state resilience to economic shocks).
reg unemployed sch_disrupted i.week i.c2_workplaceclosing age white years_educ if age >= 25 & age <= 54 & children == 1
reg jobloss sch_disrupted i.week i.c2_workplaceclosing age white years_educ if age >= 25 & age <= 54 & children == 1
* In fact, state controls seem to get rid of as much OVB as we can with our data.
reg unemployed sch_disrupted i.state i.week age white years_educ if age >= 25 & age <= 54 & children == 1
reg jobloss sch_disrupted i.state i.week age white years_educ if age >= 25 & age <= 54 & children == 1
* If we have state controls, we don't really need the other policy controls since they are mostly reflective of state effects.
reg unemployed sch_disrupted i.state i.week i.c2_workplaceclosing age white years_educ if age >= 25 & age <= 54 & children == 1
reg jobloss sch_disrupted i.state i.week i.c2_workplaceclosing age white years_educ if age >= 25 & age <= 54 & children == 1
/* Don't include bad controls.
reg unemployed sch_disrupted i.state i.week i.c2_workplaceclosing i.c3_cancelpublicevents i.e1_incomesupport i.e2_debtcontractrelief age white years_educ if age >= 25 & age <= 54 & children == 1
reg jobloss sch_disrupted i.state i.week i.c2_workplaceclosing i.c3_cancelpublicevents i.e1_incomesupport i.e2_debtcontractrelief age white years_educ if age >= 25 & age <= 54 & children == 1
*/
* However, state controls still leave other sources of OVB, mainly associated with (unobserved) individual behavior.


* IV using statewide policy. IV should not control on irrelevant covariates.
* IV addresses omitted variables like the adults' motivation to work (which could affect self-reported school disruptions), adults' motivation to apply for UI.
* Also accounts for measurement errors?
ivregress 2sls unemployed (sch_disrupted = i.c1_schoolclosing) if age >= 25 & age <= 54 & children == 1
ivregress 2sls jobloss (sch_disrupted = i.c1_schoolclosing) if age >= 25 & age <= 54 & children == 1
* Workplace controls? Workplace policy would be determined at the same time as school policy, and would be a determinant (not an effect) of unemployment.
* We could also think of workplace policy as a direct factor in deciding statewide (and individual) school closure policy, so controlling on workplace policy makes sense.
ivregress 2sls unemployed (sch_disrupted = i.c1_schoolclosing) i.c2_workplaceclosing if age >= 25 & age <= 54 & children == 1
ivregress 2sls jobloss (sch_disrupted = i.c1_schoolclosing) i.c2_workplaceclosing if age >= 25 & age <= 54 & children == 1
* Too many controls: avoid bad controls?
* Bad controls? other determinants of labor demand (e.g. income support), which might contaminate the statewide policy instrument?
* Unclear if bad controls are a factor here since these aren't determined after the regressor of interest.
* Arguably job losses may affect the need for income support and debt contract relief, making them post-effect variables.
* This is unlike workplace policy: even though other statewide policies are all correlated with statewide school closure policy via the state of the household, the correlations happen in different ways.
* See MHE chap 3.2.3.
/*
ivregress 2sls unemployed (sch_disrupted = i.c1_schoolclosing) i.c2_workplaceclosing i.c3_cancelpublicevents i.e1_incomesupport i.e2_debtcontractrelief age white years_educ if age >= 25 & age <= 54 & children == 1
ivregress 2sls jobloss (sch_disrupted = i.c1_schoolclosing) i.c2_workplaceclosing i.c3_cancelpublicevents i.e1_incomesupport i.e2_debtcontractrelief age white years_educ if age >= 25 & age <= 54 & children == 1
*/
* Control for weeks instead?
ivregress 2sls unemployed (sch_disrupted = i.c1_schoolclosing) i.c2_workplaceclosing i.week if age >= 25 & age <= 54 & children == 1
ivregress 2sls jobloss (sch_disrupted = i.c1_schoolclosing) i.c2_workplaceclosing i.week if age >= 25 & age <= 54 & children == 1
* Don't want to control for state since the instrument is at the state level -- state controls contaminate the relationship between employment and statewide school closure policy?
* Also causes standard errors to be too high, mainly because the school closing instrument is highly linked to state.
/*
ivregress 2sls unemployed (sch_disrupted = i.c1_schoolclosing) i.c2_workplaceclosing i.week i.state if age >= 25 & age <= 54 & children == 1
ivregress 2sls jobloss (sch_disrupted = i.c1_schoolclosing) i.c2_workplaceclosing i.week i.state if age >= 25 & age <= 54 & children == 1
*/
* Don't need to control for individual characteristics? Since statewide school closures are uncorrelated with individual traits.

* Impact of virtual schooling.
ivregress 2sls unemployed (days_virtualschl = i.c1_schoolclosing) if age >= 25 & age <= 54 & children == 1
ivregress 2sls jobloss (days_virtualschl = i.c1_schoolclosing) if age >= 25 & age <= 54 & children == 1
* Workplace controls.
ivregress 2sls unemployed (days_virtualschl = i.c1_schoolclosing) i.c2_workplaceclosing if age >= 25 & age <= 54 & children == 1
ivregress 2sls jobloss (days_virtualschl = i.c1_schoolclosing) i.c2_workplaceclosing if age >= 25 & age <= 54 & children == 1
* Should we control for weeks? This would reflect national-level changes in the situation and focus on state differences.
* Large increase in SE though. (Probably not a contamination issue, since weeks are pre-determined.)
ivregress 2sls unemployed (days_virtualschl = i.c1_schoolclosing) i.c2_workplaceclosing i.week if age >= 25 & age <= 54 & children == 1
ivregress 2sls jobloss (days_virtualschl = i.c1_schoolclosing) i.c2_workplaceclosing i.week if age >= 25 & age <= 54 & children == 1

* Effects for men and women separately (common controls).
* Note: the interviewees here are heads of households; the job loss question is about whether the _household_ has experienced a loss in income. Should we still see a sex effect? (Maybe, since women might still have a bigger effect, which would lead to a bigger household effect for households with female heads.)
* Unemployment is still individual though.

* Remove week controls for consistency with the above section.

* First, school disruptions.
* Be careful about interactions.
ivregress 2sls unemployed (i.sch_disrupted#i.female = i.c1_schoolclosing#i.female) female i.c2_workplaceclosing if age >= 25 & age <= 54 & children == 1
* Coeffs for men 1.sch_disrupted#0.female; for women 1.sch_disrupted#1.female.
/*
* For convenience, for categorical variables, we might omit the female control.
ivregress 2sls unemployed (i.sch_disrupted#i.female = i.c1_schoolclosing#i.female) i.c2_workplaceclosing if age >= 25 & age <= 54 & children == 1
* The above two regressions give similar results.
*/
* Compare against:
/* 
ivregress 2sls unemployed (sch_disrupted = i.c1_schoolclosing) i.c2_workplaceclosing  if age >= 25 & age <= 54 & children == 1 & female == 0
ivregress 2sls unemployed (sch_disrupted = i.c1_schoolclosing) i.c2_workplaceclosing if age >= 25 & age <= 54 & children == 1 & female == 1
ivregress 2sls jobloss (sch_disrupted = i.c1_schoolclosing) i.c2_workplaceclosing  if age >= 25 & age <= 54 & children == 1
*/
ivregress 2sls jobloss (i.sch_disrupted#i.female = i.c1_schoolclosing#i.female) female i.c2_workplaceclosing if age >= 25 & age <= 54 & children == 1

* Next, days of virtual schooling. Here, virtual schooling is a continuous variable, so don't forget the female control.
ivregress 2sls unemployed (c.days_virtualschl#i.female = i.c1_schoolclosing#i.female) female i.c2_workplaceclosing if age >= 25 & age <= 54 & children == 1
* Compare against:
/*
ivregress 2sls unemployed (days_virtualschl = i.c1_schoolclosing) i.c2_workplaceclosing if age >= 25 & age <= 54 & children == 1 & female == 0
ivregress 2sls unemployed (days_virtualschl = i.c1_schoolclosing) i.c2_workplaceclosing if age >= 25 & age <= 54 & children == 1 & female == 1
*/
ivregress 2sls jobloss (c.days_virtualschl#i.female = i.c1_schoolclosing#i.female)female i.c2_workplaceclosing if age >= 25 & age <= 54 & children == 1

