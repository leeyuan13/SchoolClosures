// CPS timeseries, aggregated by state and month.
use cpsb202001, clear
gen month = 1
quietly: append using cpsb202002
replace month = 2 if month == .
quietly: append using cpsb202003
replace month = 3 if month == .
quietly: append using cpsb202004
replace month = 4 if month == .
quietly: append using cpsb202005
replace month = 5 if month == .
quietly: append using cpsb202006
replace month = 6 if month == .
quietly: append using cpsb202007
replace month = 7 if month == .
quietly: append using cpsb202008
replace month = 8 if month == .
quietly: append using cpsb202009
replace month = 9 if month == .
quietly: append using cpsb202010
replace month = 10 if month == .

* Control for age.
keep if prtage >= 25 & prtage <= 40

gen employed = (pemlr <= 2 & pemlr >= 1)
gen labforce = (pemlr <= 4 & pemlr >= 1)
gen weights = pwcmpwgt * 0.0001 if pwcmpwgt > 0
gen children = (prchld >= 1) if prchld >= -1
gen female = (pesex == 2) if pesex > 0
gen state = gestfips
label values state gestfips
gen white = (ptdtrace == 1)
gen years_educ = .
replace years_educ = 1 if peeduca == 31
replace years_educ = 4 if peeduca == 32
replace years_educ = 6 if peeduca == 33
replace years_educ = 8 if peeduca == 34
replace years_educ = 9 if peeduca == 35
replace years_educ = 10 if peeduca == 36
replace years_educ = 11 if peeduca == 37
replace years_educ = 12 if peeduca == 38 | peeduca == 39
replace years_educ = 13 if peeduca == 40
replace years_educ = 14 if peeduca == 41 | peeduca == 42
replace years_educ = 16 if peeduca == 43
replace years_educ = 18 if peeduca == 44
replace years_educ = 19 if peeduca == 45 
replace years_educ = 21 if peeduca == 46

* To compute employment rates, only keep if in labor force.
keep if labforce == 1

* Compute averages w/ and w/o children.
gen unemp_wchild = 1 - employed if children == 1
gen unemp_wochild = 1 - employed if children == 0
gen unemp_fwchild = 1 - employed if children == 1 & female == 1
gen unemp_fwochild = 1 - employed if children == 0 & female == 1
gen unemp_mwchild = 1 - employed if children == 1 & female == 0
gen unemp_mwochild = 1 - employed if children == 0 & female == 0

collapse (mean) employed unemp* [aw = weights], by(state month)

tempfile cpsdata
save `cpsdata'

// Import OxCGRT data, monthly aggregates.
import delimited OxCGRT_latest.csv, clear
keep if countrycode == "USA" & jurisdiction == "STATE_TOTAL"
gen month = int(date/100) - 202000
keep if month >= 1 & month <= 10

* Recode state.
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

collapse (max) c1_schoolclosing c2_workplaceclosing, by(state month)

merge 1:1 state month using `cpsdata'
label values state gestfips

gen mrange1 = (month >= 1 & month <= 5)
gen mrange2 = (month >= 7 & month <= 10)

reg employed i.c1_schoolclosing i.state i.month i.c2_workplaceclosing if mrange2 == 1
reg employed i.c1_schoolclosing##i.c2_workplaceclosing i.state i.month if mrange2 == 1

reg employed i.c1_schoolclosing##i.c2_workplaceclosing i.state i.month if mrange1 == 1, baselevels

drop _merge
reshape long unemp_, i(state month) j(modifier) string

gen female = .
replace female = 1 if modifier == "fwchild" | modifier == "fwochild"
replace female = 0 if modifier == "mwchild" | modifier == "mwochild"

gen child = .
replace child = 1 if modifier == "fwchild" | modifier == "mwchild" | modifier == "wchild"
replace child = 0 if modifier == "fwochild" | modifier == "mwochild" | modifier == "wochild"

reg unemp_ i.c1_schoolclosing##i.child i.state i.month if mrange1 == 1 & female == ., baselevels
reg unemp_ i.c1_schoolclosing##i.child##i.female i.state i.month if mrange1 == 1 & female != ., baselevels

reg unemp_ i.c1_schoolclosing##i.child i.state i.month if mrange2 == 1 & female == ., baselevels
