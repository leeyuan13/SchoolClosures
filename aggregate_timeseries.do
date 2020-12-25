// Timeseries.
use cpsb201911, clear
gen month = 201911
quietly: append using cpsb201912
replace month = 201912 if month == .
quietly: append using cpsb202001
replace month = 202001 if month == .
quietly: append using cpsb202002
replace month = 202002 if month == .
quietly: append using cpsb202003
replace month = 202003 if month == .
quietly: append using cpsb202004
replace month = 202004 if month == .
quietly: append using cpsb202005
replace month = 202005 if month == .
quietly: append using cpsb202006
replace month = 202006 if month == .
quietly: append using cpsb202007
replace month = 202007 if month == .

* Control for age.
*keep if prtage >= 25 & prtage <= 40
*keep if prtage >= 25 & prtage <= 50
keep if prtage >= 25 & prtage <= 54


gen employed = (pemlr <= 2 & pemlr >= 1)
gen labforce = (pemlr <= 4 & pemlr >= 1)
gen weights = pwcmpwgt * 0.0001 if pwcmpwgt > 0
gen children = (prchld >= 1) if prchld >= -1
gen female = (pesex == 2) if pesex > 0
gen state = gestfips
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

collapse (mean) employed unemp* [aw = weights], by(month)

gen offset = .
replace offset = 0 if month == 202003
replace offset = 1 if month == 202004
replace offset = 2 if month == 202005
replace offset = 3 if month == 202006
replace offset = 4 if month == 202007
replace offset = -1 if month == 202002
replace offset = -2 if month == 202001
replace offset = -3 if month == 201912
replace offset = -4 if month == 201911

twoway scatter unemp_wchild offset || scatter unemp_wochild offset
twoway scatter unemp_fwchild offset || scatter unemp_fwochild offset
* twoway scatter unemp_mwchild offset || scatter unemp_mwochild offset

twoway scatter unemp_wchild offset, mcolor(navy) || scatter unemp_wochild offset, mcolor(maroon) || lfit unemp_wchild offset if offset <= 0, lcolor(navy) || lfit unemp_wchild offset if offset > 0, lcolor(navy) range(0 4) || lfit unemp_wochild offset if offset <= 0, lcolor(maroon) || lfit unemp_wochild offset if offset > 0, lcolor(maroon) range(0 4) ||, xline(0) legend(order(1 "With under-18s" 2 "Without under-18s")) xtitle("Months after March 2020") ytitle("Unemployment rate") graphregion(color(white)) bgcolor(white) xlabel(, grid nogextend) ylabel(, grid nogextend) plotregion(lcolor(black))
