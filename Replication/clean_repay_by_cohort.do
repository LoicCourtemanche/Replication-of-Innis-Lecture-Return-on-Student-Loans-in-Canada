

**************************************************
// clean repayment by cohort(last consolidation year)
**************************************************
use "$cleaned/CSLP_repay", clear

//clean separately by last consolidation year
keep if last_yearcons==$y


//sort
//label for repayment status and sort
label define statuslabel 1 "S" 2 "G" 3 "R" 4 "F" 5 "I2" 6 "I3" 7 "CP" 8 "C" 9 "CS" ///
	10 "IP" 11 "OP" 12 "P" 13 "RT" 14 "B7" 15 "DE" 16 "DI" 17 "PP" 18 "X" 19 "M" 20 "IA" 21 "TF" 22 "B8"

encode status, gen(status_new) label(statuslabel)


gen new_studylevel = .
replace new_studylevel = 1 if studylevel==2
replace new_studylevel = 2 if studylevel!=2
label define new_studylevel 1 "Undergrad" 2 "Non-undergrad"
label values new_studylevel new_studylevel

sort methid loanyear datecons studylevel status_new, stable


//default in last loan consolidation
gen default = (status=="RT" & datecons==last_datecons)
by methid: egen ndefault=sum(default)
drop default
gen default=(ndefault>0 & ndefault<.)
drop ndefault
//last stauts
by methid: gen last_status=status[_N]

//drop records after default 
//flag those with R after RT in last loan consolidation
gen flag_rehab=(default==1 & last_status!="RT")
gen yeardefault=loanyear if flag_rehab==1 & status=="RT"
by methid: egen max_yeardefault=max(yeardefault)
drop if flag_rehab==1 & loanyear>max_yeardefault
drop yeardefault max_yeardefault default last_status


**************************************************
//last consolidated loan inconsistency
**************************************************

//grace period interest
//balstudyend and consamount is consistend within methid+datecons
sort methid datecons, stable
by methid datecons: egen maxgraceint = max(graceint)

gen newbalstudyend = balstudyend+maxgraceint
replace newbalstudyend = balstudyend if maxgraceint>=.

//drop if  last loan balstudyend missing 
sort methid loanyear datecons studylevel, stable
by methid: gen last_balstudyend = balstudyend[_N]
gen last_balstudyend_miss = (last_balstudyend>=.)
ta last_balstudyend_miss
drop if last_balstudyend_miss==1
drop last_balstudyend_miss last_balstudyend


//inconsistency between newbalstudyend and paidprin+outprin
gen sum_prin = paidprin+outprin
replace sum_prin = paidprin if outprin>=. & (status=="P"|status=="PP") & (paidprin>=balstudyend|paidprin>=consamount)
replace sum_prin = outprin if paidprin>=.

sort methid datecons, stable
by methid datecons: egen max_sum_prin = max(sum_prin)
drop sum_prin
ren max_sum_prin sum_prin



order methid datecons loanyear studylevel status balstudyend consamount newbalstudyend sum_prin outprin  paidprin outint paidint  rapstage schedpayment affordpay yearstudyend datedefault

sort methid loanyear datecons studylevel, stable
//drop if last loan sum_prin missing
by methid: gen last_sumprin = sum_prin[_N]
gen last_sumprin_miss = (last_sumprin>=.)
ta last_sumprin_miss
drop if last_sumprin_miss==1
drop last_sumprin_miss last_sumprin


//label loan discrepancy by last consolidated
gen diff = sum_prin - newbalstudyend if datecons == last_datecons & studylevel == last_studylevel
gen abs_diff_frac = abs(diff)/newbalstudyend
gen diff_frac = diff/newbalstudyend

by methid: egen max_diff = max(diff)
drop diff 
ren max_diff diff


by methid: egen max_abs_diff_frac = max(abs_diff_frac)
drop abs_diff_frac
ren max_abs_diff_frac abs_diff_frac

by methid: egen max_diff_frac = max(diff_frac)
drop diff_frac
ren max_diff_frac diff_frac



recode abs_diff_frac  (0=1)(0/0.05=2) (0.05/0.1=3) (0.1/0.2=4) (0.2/0.5=5) (0.5/max=6), gen(abs_diff_frac_cat)
label define abs_diff_frac_cat 1 "==0" 2 "(0,5%]" 3 "(5%,10%]" 4 "(10%,20%]" 5 "(20%,50%]" 6 ">50%"
label values abs_diff_frac_cat abs_diff_frac_cat
label variable abs_diff_frac_cat "abs discrepancy/consolidation amount"


recode diff_frac (0=6)(min/-0.5=1)(-0.5/-0.2=2)(-0.2/-0.1=3)(-0.1/-0.05=4)(-0.05/0=5)(0/0.05=7)(0.05/0.1=8)(0.1/0.2=9)(0.2/0.5=10)(0.5/max=11), gen(diff_frac_cat)
label define diff_frac_cat 1 "<=-50%" 2 "(-50%,-20%]" 3 "(-20%,-10%]" 4 "(-10%,-5%]" 5 "(-5%,0%)"  6 "==0" 7 "(0,5%]" 8 "(5%,10%]" 9 "(10%,20%]" 10 "(20%,50%]" 11 ">50%"
label values diff_frac_cat diff_frac_cat
label variable diff_frac_cat "discrepancy/consolidation amount"

ta diff_frac_cat
ta abs_diff_frac_cat




//different inconsistent cases

//have "paid in full" before last loan consolidation, paidprin missing or not missing but smaller than newbalstudyend, and diff>0
//problematic "P"
gen status_p_miss = ((status=="P"|status=="PP") & (paidprin>=.)& datecons!=last_datecons)
by methid: egen sum_status_p_miss = sum(status_p_miss)
replace sum_status_p_miss = 1 if sum_status_p_miss>0 & sum_status_p_miss<.

gen status_p_nonmiss = ((status=="P"|status=="PP") & paidprin<balstudyend&balstudyend<.& datecons!=last_datecons)
by methid: egen sum_status_p_nonmiss = sum(status_p_nonmiss)
replace sum_status_p_nonmiss = 1 if sum_status_p_nonmiss>0 & sum_status_p_nonmiss<.


//problematic P and normal P
gen status_p = ((status=="P"|status=="PP") &  datecons!=last_datecons)
by methid: egen sum_status_p = sum(status_p)
replace sum_status_p = 1 if sum_status_p>0 & sum_status_p<.

//made payments before last consolidation
gen status_r = ((status!="P"&status!="PP") & paidprin<. & datecons!=last_datecons)
by methid: egen sum_status_r = sum(status_r)
replace sum_status_r = 1 if sum_status_r>0 & sum_status_r<.


//mutually exclusive

//case 1: problematic "P" with paidprin missing 
gen flag_case1 = 0 
replace flag_case1 = 1 if sum_status_p_miss==1 & diff>0 & diff<.


//case 2: problematic "P" with paidprin non-missing 
gen flag_case2 = 0
replace flag_case2 = 1 if sum_status_p_nonmiss==1 & diff>0 & diff<.


//case 3: no problematic "P", only "R"
gen flag_case3 = 0
replace flag_case3 = 1 if sum_status_p_miss==0 & sum_status_p_nonmiss==0 & sum_status_r==1 & diff>0 & diff<.

replace flag_case1 = 0 if flag_case2==1

//within case 3, there are different cases: 1,balstudyend==outprin 2,not equal, still problematic
sort methid datecons studylevel loanyear, stable
by methid datecons studylevel: gen first_record=(_n==1)
by methid datecons studylevel: egen double max_outprin=max(outprin)

gen first_last_loan = (first_record==1 & datecons==last_datecons & studylevel==last_studylevel)
gen case3_noissue=(flag_case3==1 & first_last_loan==1 & (balstudyend==outprin|balstudyend==max_outprin))
gen case3_diff1 = (outprin-balstudyend)/balstudyend if flag_case3==1 & first_last_loan==1 
gen case3_diff2 = (max_outprin-balstudyend)/balstudyend if flag_case3==1 & first_last_loan==1 

gen case3_diff=.
replace case3_diff = case3_diff1 if abs(case3_diff1)<=abs(case3_diff2)
replace case3_diff = case3_diff2 if abs(case3_diff1)>abs(case3_diff2)


recode case3_diff (0=6)(min/-0.5=1)(-0.5/-0.2=2)(-0.2/-0.1=3)(-0.1/-0.05=4)(-0.05/0=5)(0/0.05=7)(0.05/0.1=8)(0.1/0.2=9)(0.2/0.5=10)(0.5/max=11), gen(case3_diff_cat)


by methid: egen max_case3_noissue=max(case3_noissue)
by methid: egen max_case3_diff=max(case3_diff)
by methid: egen max_case3_diff_cat=max(case3_diff_cat)



drop case3_noissue* case3_diff* case3_diff_cat first_record first_last_loan 
ren max_case3_noissue case3_noissue
ren max_case3_diff case3_diff
ren max_case3_diff_cat case3_diff_cat

label values case3_diff_cat diff_frac_cat
label variable case3_diff_cat "case3 discrepancy/balstudyend amount"

*******************************************
//Different samples
*******************************************
gen sample1 = 0
replace sample1 = 1 if diff==0|flag_case1==1|flag_case2==1|(flag_case3==1 & case3_diff==0)

gen sample2 = 0
replace sample2 = 1 if sample1==1 |(case3_diff>-0.05&case3_diff<0.05 & flag_case3==1)|abs_diff_frac<0.05

gen sample3 = 0
replace sample3 = 1 if sample1==1 |(case3_diff>-0.1&case3_diff<0.1 & flag_case3==1)|abs_diff_frac<0.1


//keep discrepancy<5%
if ($keep_consistent==1) {
	keep if sample2==1
}


save "$cleaned/CSLP_repay_cohort_$y", replace


**************************************************
//annual payments for other cases except case 3
**************************************************
do "calc_repay_other"

**************************************************
//annual payments for case 3
**************************************************
do "calc_repay_case3"



*************************************
//combine
*************************************
use "$cleaned/repay_other_$y", clear
append using "$cleaned/repay_case3_$y"

**************************************************
//sample selection on paidprin
**************************************************
sort methid new_studylevel loanyear, stable
by methid: egen max_flag_paidprin=max(flag_paidprin)
by methid: egen max_flag_amount = max(flag_amount)
by methid: egen max_flag_ratio = max(flag_ratio)

drop flag_paidprin flag_amount flag_ratio
ren max_flag_paidprin flag_paidprin
ren max_flag_amount flag_amount
ren max_flag_ratio flag_ratio

ta flag_paidprin 
sum flag_amount,d
sum flag_ratio,d

count if flag_ratio>=0.05 & flag_ratio<.
count if flag_ratio>=0.1 & flag_ratio<.

//drop if decline in paidprin >=5% of consolidation amount
if ($drop_paidprin==1) {
	drop if flag_ratio>=0.05 & flag_ratio<.
}

**************************************************
//last period status
**************************************************
sort methid new_studylevel loanyear, stable

//last period status
gen last_status = .

by methid: replace last_status = 1 if _n==_N & status_p==1
by methid: replace last_status = 1 if _n==_N & newoutprin==0


by methid: replace repayment=repayment+newoutprin if _n==_N & status_p==1 & newoutprin>0 & paidprin==0
by methid: replace newoutprin=0 if _n==_N & status_p==1 & newoutprin>0 

by methid: replace last_status = 2 if _n==_N & status_rt==0 & rapstage=="" & status_p==0 & status_other==0 & status_b8==0 & newoutprin>0 
by methid: replace last_status = 3 if _n==_N & status_rt==0 & rapstage!="" & status_p==0 & status_other==0 & status_b8==0 & newoutprin>0 
by methid: replace last_status = 4 if _n==_N & status_rt==1 
by methid: replace last_status = 5 if _n==_N & status_b8==1

label define last_status 1 "Paid full" 2 "In repayment" 3 "On RAP" 4 "Default" 5 "Bankruptcy"
label values last_status last_status


**************************************************
//assumptions on payments after T,repayment T
**************************************************

sort methid new_studylevel loanyear, stable


//if default, use parameters from the CSLP to impute payments

//save those default separately
preserve
keep if last_status==4
keep methid datecons datedefault min_defaultamount loanyear
drop if min_defaultamount>=.
save "$cleaned/default_$y", replace

do calc_default
restore

merge m:1 methid using "$cleaned/default_pdv_$y"
drop _merge
	
	
	

count 	
sort methid new_studylevel loanyear, stable
//there are borrowers still in RAP or in repayment but the last observable year is not 2015, drop
by methid: gen last_year = loanyear if _n==_N
gen flag_miss = (last_status==2|last_status==3)&last_year!=2015
by methid: replace flag_miss=flag_miss[_N]
drop if flag_miss==1
drop flag_miss


//default in first 3 years
gen default_3yr = (loanyear-last_yearcons>=0 & loanyear-last_yearcons<=2 & status_rt==1)
by methid: egen max_default_3yr=max(default_3yr)
drop default_3yr
ren max_default_3yr default_3yr

//enter RAP in first 3 years
gen rap_3yr = (loanyear-last_yearcons>=0 & loanyear-last_yearcons<=2 & rapstage!="")
by methid: egen max_rap_3yr=max(rap_3yr)
drop rap_3yr
ren max_rap_3yr rap_3yr

//bankruptcy in first 3 years
gen bankruptcy_3yr = (loanyear-last_yearcons>=0 & loanyear-last_yearcons<=2 & (status_b8==1|status_other==1))
by methid: egen max_bankruptcy_3yr=max(bankruptcy_3yr)
drop bankruptcy_3yr
ren max_bankruptcy_3yr bankruptcy_3yr

//fraction default/RAP/bankruptcy in each year since consolidation
//not cumulative
forval i=1/11{
    gen bankruptcy_`i' = (loanyear-last_yearcons+1==`i' & status_b8==1)
	by methid: egen max_bankruptcy_`i'=max(bankruptcy_`i')
	drop bankruptcy_`i'
	ren max_bankruptcy_`i' bankruptcy_`i'
	
	gen default_`i' = (loanyear-last_yearcons+1==`i' & status_rt==1)
	by methid: egen max_default_`i'=max(default_`i')
	drop default_`i'
	ren max_default_`i' default_`i'
	
	gen rap_`i' = (loanyear-last_yearcons+1==`i' & rapstage!="")
	by methid: egen max_rap_`i'=max(rap_`i')
	drop rap_`i'
	ren max_rap_`i' rap_`i'
	
	gen paid_`i' = (loanyear-last_yearcons+1==`i' & status_p==1)
	by methid: egen max_paid_`i'=max(paid_`i')
	drop paid_`i'
	ren max_paid_`i' paid_`i'
	
	gen monthsrap_`i' = monthsrap if loanyear-last_yearcons+1==`i' 
	by methid: egen max_monthsrap_`i'=max(monthsrap_`i')
	drop monthsrap_`i'
	ren max_monthsrap_`i' monthsrap_`i'
	replace monthsrap_`i'=0 if monthsrap_`i'>=.
	
	
}

save "$cleaned/repay_$y", replace



************************************************************
//get data ready for regression to predict post observed payments
************************************************************

if ($check_sample==0) {

//regress payments after t on observables at t 
use "$cleaned/repay_$y", clear

drop if studylevel!=last_studylevel


keep methid loanyear status_rt status_p status_b8 status_other rapstage newoutprin repayment min_outprin min_outint min_defaultamount sum_prin maxgraceint total_monthsrap ///
	birthyear gender last_studylevel issueprov insttype edinst marital familysize studylevel educcat  post_default_payment*


gen repay_year = loanyear-$y+1
drop if repay_year<=0


sort methid loanyear
by methid: egen max_repay_year=max(repay_year)


gen status = .
replace status = 1 if status_p==1
replace status = 1 if newoutprin==0
replace newoutprin=0 if status_p==1 & newoutprin>0 

replace status = 2 if status_rt==0 & rapstage=="" & status_p==0 & status_other==0 & status_b8==0 & newoutprin>0 
replace status = 3 if status_rt==0 & rapstage!="" & status_p==0 & status_other==0 & status_b8==0 & newoutprin>0 
replace status = 4 if status_rt==1 
replace status = 5 if status_b8==1

label define status 1 "Paid full" 2 "In repayment" 3 "On RAP" 4 "Default" 5 "Bankruptcy"
label values status status

//outstanding debt
gen amount = .
replace amount = min_outprin+min_outint if status >= 1 & status<=3 & min_outint<. & min_outprin<.
replace amount = min_outprin if status >= 1 & status<=3 & min_outint>=. & min_outprin<.
replace amount = newoutprin if status >= 1 & status<=3 & min_outprin>=. 
replace amount = 0 if status==1

//default
//use min_defaultamout, and use min_outprin+min_outint if min_defaultamount is missing
replace amount = min_defaultamount if status == 4
replace amount = min_outprin+min_outint if status == 4 & min_defaultamount>=.

replace amount = min_outprin+min_outint if status == 5 & min_outint<. & min_outprin<.
replace amount = min_outprin if status == 5 & min_outint>=. & min_outprin<.
replace amount = newoutprin if status == 5  & min_outprin>=. 


//total loan amount, without grace period interest
by methid: gen total_loan = sum_prin[_N]-maxgraceint[_N]
by methid: replace total_loan = sum_prin[_N] if maxgraceint[_N]>=.
by methid: replace total_loan = . if sum_prin[_N]-maxgraceint[_N]<0

//consolidation amount, with grace period interest
by methid: gen consamount = sum_prin[_N]

	
keep methid repay_year status repayment amount total_loan total_monthsrap post_default_payment* max_repay_year consamount 


//variables not constant within methid
sort methid repay_year
by methid: replace total_monthsrap = total_monthsrap[_N]


//reshape wide
drop if repay_year>=.
reshape wide status repayment amount, i(methid) j(repay_year)


//amount and status after observable periods
local ymax=2015-$y


forvalues y=1/`ymax'{
    local yp=`y'+1
	replace amount`yp'=amount`y' if (status`y'==1|status`y'==4|status`y'==5) & status`yp'>=.
	replace status`yp'=status`y' if (status`y'==1|status`y'==4|status`y'==5) & status`yp'>=.
	
}

quietly{

//fill in repayment after observable periods for repayment regressions
local ymax=2015-$y+1
gen last_status=status`ymax'
label values last_status status



forval i=1/8{
	local yp = `ymax'+`i'
	gen repayment`yp' = .
}

//fill in after default year
local n=_N
forval i=1/`n'{
	if (last_status[`i']==4){
		local y=max_repay_year[`i']
		forval j=1/8{
			local k=`y'+`j'
			replace repayment`k' = post_default_payment`j' in `i'
		}	
	}
}

drop post_*



//paid in full or bankruptcy, fill in 0
local n=_N
forval i=1/`n'{
	if (last_status[`i']==1|last_status[`i']==5){
		local y=max_repay_year[`i']+1
		forval j=`y'/15{
			replace repayment`j' = 0 in `i'
		}	
	}
}


}

gen cohort=$y
save "$cleaned/repay_wide_$y", replace


}









