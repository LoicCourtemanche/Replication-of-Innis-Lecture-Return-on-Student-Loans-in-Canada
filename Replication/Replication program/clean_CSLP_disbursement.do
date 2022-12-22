
************************************
//clean disbursement file
************************************

use "$raw/CSLP_PCPE_disbursement_f1_v1.dta", clear

//make all variable name lowercase
foreach v of varlist _all{
    capture rename `v' `=lower("`v'")'
}

drop if methid==""

//drop part time loan disbursement
drop if ptflag==1

//keep undergrad loan only
keep if studylevel=="Undergrad"
order methid loanyear studylevel loandisb 
sort methid loanyear

//drop those methid+loanyear not unique individuals, mainly because of issue province
duplicates report methid loanyear
duplicates tag methid loanyear, gen(dup)
by methid: egen max_dup=max(dup)
drop if max_dup>0
drop max_dup dup

merge m:1 methid using "$cleaned/last_undergrad_year"
drop if _merge==1 //not consolidate yet
drop if _merge==2 //early cohort, no disbursement record
drop _merge 

count if loanyear<last_undergrad_year
count if loanyear==last_undergrad_year
count if loanyear>last_undergrad_year
drop if loanyear>last_undergrad_year


keep methid loanyear loandisb gender issueprov fieldstudy insttype edinst edinstname yearstudy birthyear register_group_id

save "$cleaned/CSLP_disbursement", replace


//last undergraduate loan disbursement
sort methid loanyear
by methid: keep if _n==_N
ren loanyear last_ugloan_disb
save "$cleaned/last_ugloan_disb", replace


