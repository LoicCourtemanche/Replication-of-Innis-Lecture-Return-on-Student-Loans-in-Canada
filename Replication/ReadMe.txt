************************************
				Modif:
************************************
All
------------------------------------
For all file name and path call in the do files they have been put between ""
------------------------------------
Main.do
------------------------------------
1. Change : {global project "."} by {global project "$replication"}
2. Addthis code at the line 6
-------------Code-------------
************************************
//Replication modification
************************************

set dp comma , perm

global replication "M:\Equipes\Projet 10054\Replication\courloi10054\Improvement"

version 16

log using "replication.log", name(replication) replace
timer on 1

local variant = cond(c(MP),"MP",cond(c(SE),"SE",c(flavor)) )   

di _newline(2) "Replication done by :"						///
_newline "Loïc Courtemanche - L.courtemanche@outlook.com"	///
_newline "`c(current_date)' at `c(current_time)'"			///
_newline(2) "======= SYSTEM DIAGNOSTICS =======" 			///
_newline "Stata version: `c(stata_version)'" 				///
_newline "Updated as of: `c(born_date)'" 					///
_newline "Variant:       `variant'" 						///
_newline "Processors:    `c(processors)'" 					///
_newline "OS:            `c(os)' `c(osdtl)'" 				///
_newline "Machine type:  `c(machine_type)'" 				///
_newline "=================================="

*Create folder for ours results
capture mkdir results
capture mkdir "C:/Users/courloi2/data/cleaned"


************************************
//Ends of replication modification
************************************

-------------End of Code-------------

3: Add this code a the main of the "main.do"
-------------	Code	-------------
timer off 1
timer list
capture log close _all
-------------End of Code-------------


------------------------------------
clean_CSLP_disbursement.do
------------------------------------	
1. Add : 
	/*	== code ==  */
	//make all variable name lowercase
	foreach v of varlist _all{
		capture rename `v' `=lower("`v'")'
	}
	/*	== code ==  */
	
------------------------------------
clean_CSLP_needs.do
------------------------------------	
1. Add : 
	/*	== code ==  */
	//make all variable name lowercase
	foreach v of varlist _all{
		capture rename `v' `=lower("`v'")'
	}
	/*	== code ==  */
	
------------------------------------
return_analysis.do
------------------------------------

1: Add in "statistics in Table 1 & 2"  (line 122)
	/*	== code ==  */
	gen All = 1
	table All, c(n undergrad_return  mean undergrad_return semean undergrad_return mean default_3yr mean rap_3yr)
	/*	== code ==  */

2: For table 5, change the line "// sum undergrad_return [weight=loandisb]" for "sum undergrad_return [weight=loandisb]"