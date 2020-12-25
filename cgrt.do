// Use Oxford CGRT data.
import delimited OxCGRT_latest.csv, clear
keep if countrycode == "USA" & jurisdiction == "STATE_TOTAL"
gen month = int(date/100)
gen week = .
gen enumday = .
bys regioncode: replace enumday = _n
replace week = int(enumday/7+1)

collapse (max) c1_schoolclosing c2_workplaceclosing, by(regioncode week)

* Reshape for viewing.
* collapse (max) c1_schoolclosing, by(regioncode date)
* reshape wide c1_schoolclosing, i(regioncode) j(date)

reshape wide c1_schoolclosing c2_workplaceclosing, i(regioncode) j(week)

// Alternative: see more
/*
collapse (max) c1_schoolclosing c2_workplaceclosing c3_cancelpublicevents e1_incomesupport e2_debtcontractrelief, by(regioncode week)
reshape wide c* e*, i(regioncode) j(week)
*/

* Reshape for viewing.
reshape wide c1_schoolclosing c2_workplaceclosing, i(regioncode) j(week)

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
