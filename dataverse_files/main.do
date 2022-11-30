clear all
set more off
set maxvar 32767
capture log close

************************************
//Replication modification
************************************

global replication "M:\Equipes\Projet 10054\Replication\courloi10054\Improvement"

cd ${replication}

version 16

log using "replication.log", name(replication) replace
timer on 1

local variant = cond(c(MP),"MP",cond(c(SE),"SE",c(flavor)) )   

di _newline(2) "Replication done by :"					///
_newline "Loïc Courtemanche - L.courtemanche@outlook.com"		///
_newline "`c(current_date)' at `c(current_time)'"			///
_newline(2) "======= SYSTEM DIAGNOSTICS =======" 			///
_newline "Stata version: `c(stata_version)'" 				///
_newline "Updated as of: `c(born_date)'" 				///
_newline "Variant:       `variant'" 					///
_newline "Processors:    `c(processors)'" 				///
_newline "OS:            `c(os)' `c(osdtl)'" 				///
_newline "Machine type:  `c(machine_type)'" 				///
_newline "=================================="

************************************
//Ends of replication modification
************************************

************************************
//set directory path
************************************
capture mkdir raw
capture mkdir cleaned


//put raw restricted data in raw subfolder
global project "${replication}"
global raw "$project/raw"
global cleaned "$project/cleaned"


************************************
//options
************************************
//adjust paidprin/paidint non-decreasing, 1 yes(baseline), 0 otherwise
global adjust_nondecrease 1

//keep loan inconsistency<5%, 1 yes(baseline), 0 otherwise
global keep_consistent 1 

//drop if decline in paidprin >=5% of consolidation amount, 1 yes(baseline), 0 otherwise
global drop_paidprin 1

//statistics for different samples (Table A1)
//1: generate statistics for sample in Table A1 column (1)
//2: generate statistics for sample in Table A1 column (2)
//0: our baseline sample
global check_sample 0

if ($check_sample==1|$check_sample==2) {
	global keep_consistent 0
	global drop_paidprin 0
}



************************************
//programs
************************************
//clean external data, collection and rehabilitation post default
do "create_default_data"


//clean restricted data
//clean raw repayment file
do "clean_CSLP_repayment"

//clean raw disbursement file
do "clean_CSLP_disbursement"

//clean raw needs assessment file
do "clean_CSLP_needs"

//clean repayment by cohort(last consolidation year) separately
if ($check_sample==0) {
	local ymax=2008
}
else{
	local ymax=2015
}

forval t=2003/`ymax'{
	global y `t'
	"do clean_repay_by_cohort"
}

//baseline sample analysis
if ($check_sample==0) {
	*Create globals to test for news results
	*predict_payments.do -> test for other values
	foreach rrate of numlist 0.045 0.05 0.055 0.06 0.065  {					//-> 0.055 is the original value	
		global rrate `rrate'												
		global nrrate = `rrate'*1000											
			
		//impute payments beyond data periods
		do "predict_payments"

		//calculate return
		do "calc_return"
			
		foreach Cohort of numlist  2003 2004 2005 2006 2007 2008 {			//-> 2005 is the original value
			global Cohort `Cohort'											
			//return statistics, regressions								
			"do return_analysis"											
		}																	
	}																		
}


//statistics for different sample (online appendix Table A1)
if ($check_sample==1|$check_sample==2) {
	"do robust_sample"
}

timer off 1
timer list
log close _all
