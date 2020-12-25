// CPS around March (when most US states closed their school districts)
use cpsb202002, clear
gen post = 0
append using cpsb202004
replace post = 1 if post == .

* Rescale earnings and weights.
gen employed = (pemlr <= 2 & pemlr >= 1)
gen labforce = (pemlr <= 4 & pemlr >= 1)
gen weights = pwcmpwgt * 0.0001 if pwcmpwgt > 0
gen hours = pehruslt if pehruslt >= 0
replace hours = 0 if pehruslt == -1 & labforce == 1
gen earnings = prernwa * 0.01 if prernwa >= 0

* Restrict to labor force only.
reg employed post [aw = weights]
reg earnings post [aw = weights]
reg hours post [aw = weights]

* Include controls.
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
gen state = gestfips

reg employed post i.state white years_educ [aw = weights]
reg hours post i.state white years_educ [aw = weights]

* Full-time/part-time.
gen ft = (prwkstat == 2 | prwkstat == 8 | prwkstat == 9) if pemlr >= 1 & pemlr <= 7
gen pt = (prwkstat == 3 | prwkstat == 4 | prwkstat == 6 | prwkstat == 7) if pemlr >= 1 & pemlr <= 7

reg ft post i.state white years_educ [aw = weights]
reg pt post i.state white years_educ [aw = weights]

* Compare based on child status.
gen children = (prchld >= 1)
bys children: reg employed post i.state white years_educ [aw = weights]
bys children: reg hours post i.state white years_educ [aw = weights]
bys children: reg ft post i.state white years_educ [aw = weights]
bys children: reg pt post i.state white years_educ [aw = weights]

* What about fathers vs mothers?
reg employed post##i.pesex##i.children i.state white years_educ [aw = weights]
reg hours post##i.pesex##i.children i.state white years_educ [aw = weights]
reg ft post##i.pesex##i.children i.state white years_educ [aw = weights]
reg pt post##i.pesex##i.children i.state white years_educ [aw = weights]

* Maybe April is not soon enough for labor supply effects to show up?


