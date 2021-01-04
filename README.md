# The Effect of School Disruptions on Labor Supply
### 14.32 (Econometric Data Science) Capstone Project

This repository contains the Stata .do files I used to analyze the effect of school disruptions on parental labor supply.

The relevant datasets are:
* Oxford University's [Coronavirus Government Response Tracker (CGRT)](https://www.bsg.ox.ac.uk/research/research-projects/coronavirus-government-response-tracker);
* the US Bureau of Labor Statistics' [Current Population Survey (CPS)](https://www.bls.gov/cps), from January to October 2020; and
* the US Census Bureau's [Household Pulse Survey (HPS)](https://www.census.gov/programs-surveys/household-pulse-survey.html), from August 19 to November 23, 2020 ("weeks" 13 to 19).

The report for this project can be found [here](https://www.dropbox.com/s/f8q8yj7fau5zp07/report.pdf?dl=0) (MIT Dropbox only).

#### Code Overview

* `aggregate_timeseries.do` plots aggregated unemployment statistics over time. It was used to produce Figure 1 of the report.
* `hh_timeseries_unemp.do` analyzes unemployment statistics extracted from the CPS.
* `hh_timeseries_labforce.do` analyzes labor force statistics extracted from the CPS. Together with `hh_timeseries_unemp.do`, this was used to estimate the change in employment after the March school closures. (This is not necessarily the effect _due to_ school closures.) The CPS data does not produce meaningful estimates of the effect of school closures in the fall, as statewide closure policy (available in the CGRT) is not sufficiently fine-grained to identify individual school disruptions.
* `household_pulse_timeseries.do` analyzes employment statistics extracted from the HPS. It also uses statewide school closure policy from the CGRT as an instrument for individual school disruptions.

#### Additional Information
Version: December 21, 2020

Updated: December 25, 2020
