
**************************************************
// clean CSLP repayment file 
**************************************************
use "$raw/CSLP_PCPE_repayment_f1_v1.dta", clear

//make all variable name lowercase
foreach v of varlist _all{
	capture rename `v' `=lower("`v'")'
}

drop if methid==""

//drop part time records
drop if ptflag==1


//keep those who ever consolidated as undergrad (full-time)
label define studylevel 1 "Non-degree" 2 "Undergrad" 3 "Masters" 4 "PhD" 5 "Missing"
encode studylevel, gen(studylevel_num) label(studylevel)
drop studylevel
ren studylevel_num studylevel

//drop if ever have studylevel missing
gen missing = (studylevel==5)
bysort methid: egen missing_sum = sum(missing)
ta missing_sum
drop if missing_sum>0
drop missing missing_sum

//only keep those who ever consolidate as undergrad (full-time)
gen undergrad = (studylevel==2)
bysort methid: egen undergrad_sum = sum(undergrad)
replace undergrad=undergrad_sum>0
drop undergrad_sum

keep if undergrad==1

//ever consolidate as non-undergrad (full-time)
gen nonundergrad = (studylevel!=2)
bysort methid: egen nonundergrad_sum = sum(nonundergrad)
replace nonundergrad = nonundergrad_sum>0
drop nonundergrad_sum

//last study level (full-time)
sort methid loanyear datecons studylevel
gen last_studylevel = .
by methid: replace last_studylevel = studylevel[_N]



gen educcat=.
replace educcat=1 if nonundergrad==0 
replace educcat=2 if nonundergrad==1 & last_studylevel==2
replace educcat=3 if nonundergrad==1 & last_studylevel!=2

label define educcat 1 "undergrad only" 2 "other to undergrad" 3 "undergrad to other"
label values educcat educcat




//get the year finish undergrad study, one entry per id
preserve
keep if studylevel==2
by methid: egen last_undergrad_year=max(yearstudyend)
keep methid last_undergrad_year
by methid: keep if _n==1
save $cleaned/last_undergrad_year, replace
restore


//last consolidated loan and last consolidation year
sort methid loanyear datecons
by methid: gen long last_datecons = datecons[_N]
format last_datecons %tdD_m_Y

gen last_yearcons = year(last_datecons)-(month(last_datecons)<8)


save $cleaned/CSLP_repay, replace


