
//read in data from excel file


/* --------------------
  
        Excel TABLE 1
	  
	-------------------  */

* Import data from Table 1
import excel "Repayment Post Default and Post Rehabilitation data.xlsx", sheet("Table 1") cellrange(C9:U14) firstrow

* Reshape and create def_amt_cat
reshape long num_borr_default num_loan_default total_amt_default, i(years_in_repay) j(def_amt_cat)

* Create labels
label define yrs 1 "0 - 11 MONTHS" 2 "12 - 23 MONTHS" 3 "24 - 35 MONTHS" 4 "36 - 59 MONTHS" 5 "60 OR MORE MONTHS"
label define amt 1 "$1 - $3,000" 2 "$3,001 - $6,000" 3 "$6,001 - $10,000" 4 "$10,001 - $15,000" 5 "$15,001 - $20,000" 6 "$20,001 OR MORE"
label values years_in_repay yrs
label values def_amt_cat amt

save "$cleaned/excel_table1.dta", replace
clear
/* --------------------
  
        Excel TABLE 2
	  
	-------------------  */

* Import data from Table 2
import excel "Repayment Post Default and Post Rehabilitation data.xlsx", sheet("Table 2") cellrange(D9:AC49) firstrow

* Reshape and create def_amt_cat
reshape long num_borr_coll num_loan_coll num_pay_coll total_amt_coll, i(years_in_repay years_in_bin) j(def_amt_cat)

* Reshape and create _coll#
ds years_in_repay years_in_bin def_amt_cat, not
reshape wide `r(varlist)', i(years_in_repay def_amt_cat) j(years_in_bin)

* Create labels
label define yrs 1 "0 - 11 MONTHS" 2 "12 - 23 MONTHS" 3 "24 - 35 MONTHS" 4 "36 - 59 MONTHS" 5 "60 OR MORE MONTHS"
label define amt 1 "$1 - $3,000" 2 "$3,001 - $6,000" 3 "$6,001 - $10,000" 4 "$10,001 - $15,000" 5 "$15,001 - $20,000" 6 "$20,001 OR MORE"
label values years_in_repay yrs
label values def_amt_cat amt

save "$cleaned/excel_table2.dta", replace
clear


/* --------------------
  
        Excel TABLE 3
	  
	-------------------  */
* Import data from Table 3
import excel "Repayment Post Default and Post Rehabilitation data.xlsx", sheet("Table 3") cellrange(D9:W49) firstrow

* Dots are read as strings, convert to number
ds
foreach var of varlist `r(varlist)'{
	destring `var', replace
}

* Reshape and create def_amt_cat
reshape long num_borr_rehab num_loan_rehab total_amt_rehab, i(years_in_repay years_in_rehab) j(def_amt_cat)

* Reshape and create _rehab#
ds years_in_repay years_in_rehab def_amt_cat, not
reshape wide `r(varlist)', i(years_in_repay def_amt_cat) j(years_in_rehab)

* Create labels
label define yrs 1 "0 - 11 MONTHS" 2 "12 - 23 MONTHS" 3 "24 - 35 MONTHS" 4 "36 - 59 MONTHS" 5 "60 OR MORE MONTHS"
label define amt 1 "$1 - $3,000" 2 "$3,001 - $6,000" 3 "$6,001 - $10,000" 4 "$10,001 - $15,000" 5 "$15,001 - $20,000" 6 "$20,001 OR MORE"
label values years_in_repay yrs
label values def_amt_cat amt

save "$cleaned/excel_table3.dta", replace
clear

/* --------------------
  
        Excel TABLE 4
	  
	-------------------  */


* Import data from Table 4
import excel "Repayment Post Default and Post Rehabilitation data.xlsx", sheet("Table 4") cellrange(B9:S10) firstrow

* Create an identifier for the line
gen id = 1

* Reshape and create rehab_amt_cat
reshape long num_borr_rehab num_loan_rehab total_amt_rehab, i(id) j(rehab_amt_cat)
drop id

label define rehabbins 1 "$1 - $3,000" 2 "$3,001 - $6,000" 3 "$6,001 - $10,000" 4 "$10,001 - $15,000" 5 "$15,001 - $20,000" 6 "$20,001 OR MORE"
label values rehab_amt_cat rehabbins 

save "$cleaned/excel_table4.dta", replace
clear

/* --------------------
  
        Excel TABLE 5
	  
	-------------------  */

* Import data from Table 5
import excel "Repayment Post Default and Post Rehabilitation data.xlsx", sheet("Table 5") cellrange(C9:AA17) firstrow

* Create an identifier for the line
gen id = 1

* Reshape and create rehab_amt_cat
reshape long num_borr_pay num_loan_pay num_pay total_amt_pay, i(id time_provider) j(rehab_amt_cat)
drop id

ds time_provider rehab_amt_cat, not
reshape wide `r(varlist)', i(rehab_amt_cat) j(time_provider)

label define rehabbins 1 "$1 - $3,000" 2 "$3,001 - $6,000" 3 "$6,001 - $10,000" 4 "$10,001 - $15,000" 5 "$15,001 - $20,000" 6 "$20,001 OR MORE"
label values rehab_amt_cat rehabbins 

save "$cleaned/excel_table5.dta", replace
clear

/* --------------------
  
        save frac_def.dta
	  
	-------------------  */


use "$cleaned/excel_table1.dta"

* Merge with Tables 2 and 3
merge 1:1 years_in_repay def_amt_cat using "$cleaned/excel_table2.dta"
drop _merge

merge 1:1 years_in_repay def_amt_cat using "$cleaned/excel_table3.dta"
drop _merge

* Additional variables
gen avg_def_amt_borr = total_amt_default/num_borr_default
gen avg_def_amt_loan = total_amt_default/num_loan_default

forvalues k = 1(1)8 {
	gen avg_def_coll_amt_borr`k'  = total_amt_coll`k'/num_borr_coll`k'
	gen avg_def_coll_amt_loan`k'  = total_amt_coll`k'/num_loan_coll`k'
	gen frac_def_coll`k'          = total_amt_coll`k'/total_amt_default
	gen avg_def_rehab_amt_borr`k' = total_amt_rehab`k'/num_borr_rehab`k'
	gen avg_def_rehab_amt_loan`k' = total_amt_rehab`k'/num_loan_rehab`k'
	gen frac_def_rehab`k'         = total_amt_rehab`k'/total_amt_default
	gen def_coll_rate_borr`k'     = num_borr_coll`k'/num_borr_default
	gen def_coll_rate_loan`k'     = num_loan_coll`k'/num_loan_default
	gen def_rehab_rate_borr`k'    = num_borr_rehab`k'/num_borr_default
	gen def_rehab_rate_loan`k'    = num_loan_rehab`k'/num_loan_default
}

* Reshape and create the variable "years_in_bin"
reshape long num_borr_coll num_loan_coll num_pay_coll total_amt_coll num_borr_rehab num_loan_rehab total_amt_rehab avg_def_coll_amt_borr avg_def_coll_amt_loan frac_def_coll avg_def_rehab_amt_borr avg_def_rehab_amt_loan frac_def_rehab def_coll_rate_borr def_coll_rate_loan def_rehab_rate_borr def_rehab_rate_loan, i(years_in_repay def_amt_cat) j(years_in_bin)

ds years_in_repay def_amt_cat years_in_bin, not
reshape wide `r(varlist)', i(years_in_repay years_in_bin) j(def_amt_cat)

order years_in_repay years_in_bin *1 *2 *3 *4 *5 *6 

keep years_in_repay years_in_bin frac_def_coll* frac_def_rehab*

save "frac_def.dta", replace
clear

/* --------------------
  
        save frac_rehab.dta
	  
	-------------------  */


use "$cleaned/excel_table4.dta"

* Merge with Table 5
merge 1:1 rehab_amt_cat using "$cleaned/excel_table5.dta"
drop _merge

* Additional variables
gen avg_rehab_amt_borr = total_amt_rehab/num_borr_rehab
gen avg_rehab_amt_loan = total_amt_rehab/num_loan_rehab

forvalues k = 1(1)8 {	
	gen avg_rehab_pay_amt_borr`k' = total_amt_pay`k'/num_borr_pay`k' 
	gen avg_rehab_pay_amt_loan`k' = total_amt_pay`k'/num_loan_pay`k' 
	gen frac_rehab_paid`k'        = total_amt_pay`k'/total_amt_rehab 
	gen rehab_pay_rate_borr`k'    = num_borr_pay`k'/num_borr_rehab
	gen rehab_pay_rate_loan`k'    = num_loan_pay`k'/num_loan_rehab
}

reshape long num_borr_pay num_loan_pay num_pay total_amt_pay avg_rehab_pay_amt_borr avg_rehab_pay_amt_loan frac_rehab_paid rehab_pay_rate_borr rehab_pay_rate_loan, i(rehab_amt_cat) j(years_in_bin)

ds rehab_amt_cat years_in_bin, not
reshape wide `r(varlist)', i(years_in_bin) j(rehab_amt_cat)

order years_in_bin *1 *2 *3 *4 *5 *6 

keep years_in_bin total_amt_rehab* total_amt_pay* frac_rehab_paid*

save "frac_rehab.dta", replace
clear



