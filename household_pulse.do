// Household Pulse Survey
import delimited pulse2020_puf_01.csv, clear
keep tbirth_year egender rhispanic rrace eeduc ms thhld_numper thhld_numkid thhld_numadlt wrkloss expctloss anywork rsnnowrk unemppay hlthstatus delay notget hlthins* enroll* teach* comp* intrnt* tschlhrs ttch_hrs income est_st

keep if enroll1 == 1
keep if ttch_hrs >= 0
keep if anywork >= 0
keep if tschlhrs >= 0
keep if income >= 0

gen sch_disrupted = .
replace sch_disrupted = 0 if teach5 == 1
replace sch_disrupted = 1 if teach1 == 1 | teach2 == 1 | teach3 == 1 | teach4 == 1

foreach x in 1 2 3 4 5 {
	gen disrupt`x' = (teach`x' == 1) if teach1 == 1 | teach2 == 1 | teach3 == 1 | teach4 == 1 | teach5 == 1
}

gen jobloss = .
replace jobloss = 1 if wrkloss == 1
replace jobloss = 0 if wrkloss == 2

tabulate rsnnowrk if rsnnowrk > 0
bys sch_disrupted: tabulate rsnnowrk if rsnnowrk > 0

reg ttch_hrs sch_disrupted
reg tschlhrs sch_disrupted

reg jobloss sch_disrupted i.eeduc i.income if income >= 0
reg jobloss ttch_hrs i.eeduc i.income if income >= 0
reg jobloss ttch_hrs i.eeduc i.income i.rrace rhispanic

ivregress 2sls jobloss (ttch_hrs = sch_disrupted) i.eeduc i.income

//

import delimited pulse2020_puf_19.csv, clear
keep tbirth_year egender rhispanic rrace eeduc ms thhld_numper thhld_numkid thhld_numadlt wrkloss expctloss anywork rsnnowrk unemppay hlthstatus delay notget hlthins* enroll* teach* comp* intrnt* schlhrs tstdy_hrs tch_hrs income est_st

keep if enroll1 == 1
keep if tch_hrs >= 0
keep if anywork >= 0
keep if schlhrs >= 0
keep if income >= 0

gen sch_disrupted = .
replace sch_disrupted = 0 if teach5 == 1
replace sch_disrupted = 1 if teach1 == 1 | teach2 == 1 | teach3 == 1 | teach4 == 1

foreach x in 1 2 3 4 5 {
	gen disrupt`x' = (teach`x' == 1) if teach1 == 1 | teach2 == 1 | teach3 == 1 | teach4 == 1 | teach5 == 1
}

gen jobloss = .
replace jobloss = 1 if wrkloss == 1
replace jobloss = 0 if wrkloss == 2

* Recode live virtual contact with teachers.
gen days_schl = .
replace days_schl = 0 if schlhrs == 1
replace days_schl = 1 if schlhrs == 2
replace days_schl = 2.5 if schlhrs == 3
replace days_schl = 4.5 if schlhrs == 4

reg jobloss sch_disrupted i.eeduc i.income i.rrace rhispanic i.est_st

* Live virtual contact.
reg days_schl sch_disrupted

reg jobloss days_schl i.eeduc i.income i.rrace rhispanic i.est_st
ivregress 2sls jobloss (days_schl = sch_disrupted) i.eeduc i.income  i.rrace rhispanic i.est_st

* Self study.
reg tstdy_hrs sch_disrupted
reg jobloss tstdy_hrs i.eeduc i.income i.rrace rhispanic i.est_st
ivregress 2sls jobloss (tstdy_hrs = sch_disrupted) i.eeduc i.income  i.rrace rhispanic i.est_st

