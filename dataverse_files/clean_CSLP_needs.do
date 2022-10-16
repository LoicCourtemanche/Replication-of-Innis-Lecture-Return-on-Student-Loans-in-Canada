
************************************
//clean needs file
************************************

use "$raw/CSLP_PCPE_needs_f1_v1.dta", clear

//get category & parental income 
drop if methid==""

//methid+loanyear unique
duplicates report methid loanyear

keep methid loanyear category dependentsunder12 dependents12plus familysize spouseincome parentincome

//merge with disbursement data
merge 1:1 methid loanyear using $cleaned/CSLP_disbursement

drop if _merge==1 //apply but did not get loan disbursement
drop _merge

//category
destring category, replace
label define category 1 "Married/Common law" 2 "Single parent" 3 "Single independent" 4 "Dependent"
label values category category

//parent income category
recode parentincome (min/0=1) (0/20000=2) (20000/40000=3) (40000/60000=4) (60000/80000=5) (80000/max=6), gen(parentincome_cat)
ta parentincome_cat

label define parentincome_cat 1 "<0" 2 "[0,20000)" 3 "[20000,40000)" 4 "[40000,60000)" 5 "[60000,80000)" 6 ">=80000"
label values parentincome_cat parentincome_cat
ta parentincome_cat

save $cleaned/CSLP_needs_disbursement, replace



