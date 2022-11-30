use "$cleaned/CSLP_repay_cohort_$y", clear


gen eligible = 0
replace eligible = 1 if last_studylevel==2 & diff==0
replace eligible = 1 if last_studylevel==2 & flag_case1==1
replace eligible = 1 if last_studylevel==2 & flag_case2==1
replace eligible = 1 if last_studylevel==2 & flag_case1==0&flag_case2==0&flag_case3==0 & diff!=0

replace eligible = 1 if last_studylevel!=2 & diff==0
replace eligible = 1 if last_studylevel!=2 & flag_case1==1
replace eligible = 1 if last_studylevel!=2 & flag_case2==1
replace eligible = 1 if last_studylevel!=2 &flag_case1==0&flag_case2==0&flag_case3==0 & diff!=0

keep if eligible == 1

//for case 1 and case 2, replace sum_prin to be balstudyend when problematic "P" appears
replace sum_prin=balstudyend if sum_status_p_miss==1 & flag_case1==1 & sum_prin>=. & datecons!=last_datecons
replace sum_prin=balstudyend if sum_status_p_nonmiss==1 & flag_case2==1 & sum_prin>=. & datecons!=last_datecons
replace sum_prin=newbalstudyend if sum_prin>=. & datecons!=last_datecons


//keep last undergrad loan and last non-undergrad loan if last study is not undergrad
sort methid new_studylevel loanyear datecons status_new, stable
by methid new_studylevel: gen last_study_datecons = datecons[_N]
format last_study_datecons %tdD_m_Y

keep if ((last_studylevel==2 & datecons == last_datecons)|(last_studylevel!=2 & datecons==last_study_datecons)) & (studylevel==2|studylevel==last_studylevel)
drop if status=="S" & ((studylevel==2&last_studylevel==2)|(studylevel!=2&last_studylevel!=2))



//after sample selection, make sure first studylevel is undergrad
sort methid new_studylevel loanyear status_new, stable
by methid: gen ind_first = (_n==1)
by methid: gen first_studylevel = studylevel if _n==1


by methid new_studylevel: gen loan_first = (_n==1)

by methid: egen max_first_studylevel = max(first_studylevel)
drop if max_first_studylevel!=2
drop max_first_studylevel
ta first_studylevel



drop status_p_miss sum_status_p_miss status_p_nonmiss sum_status_p_nonmiss status_p sum_status_p status_r sum_status_r  



**************************************************
// annual repayment
**************************************************
sort methid loanyear, stable
by methid loanyear: egen max_monthsrap = max(monthsrap)

//keep one entry for each loan year 
sort methid new_studylevel loanyear status_new, stable


replace paidprin=0 if paidprin>=.
replace paidint=0 if paidint>=.
replace outprin=0 if outprin>=. & (status=="P"|status=="PP") & (paidprin>=balstudyend|paidprin>=consamount)
replace outint=0 if outint>=.


by methid new_studylevel loanyear: egen max_paidprin = max(paidprin)
by methid new_studylevel loanyear: egen max_paidint = max(paidint)
by methid new_studylevel loanyear: egen min_outprin = min(outprin)
by methid new_studylevel loanyear: egen min_outint = min(outint)
by methid new_studylevel loanyear: egen min_defaultamount = min(defaultamount)


gen status_rt = (status == "RT")
gen status_p = (status=="P"|status=="PP")
gen status_b8 = (status=="B7"|status=="B8")
gen status_other = (status=="DE"|status=="DI")
by methid new_studylevel loanyear: egen nstatus_rt = sum(status_rt)
by methid new_studylevel loanyear: egen nstatus_p = sum(status_p)
by methid new_studylevel loanyear: egen nstatus_b8 = sum(status_b8)
by methid new_studylevel loanyear: egen nstatus_other = sum(status_other)
replace status_rt = (nstatus_rt>=1 & nstatus_rt<.)
replace status_p = (nstatus_p>=1 & nstatus_p<.)
replace status_b8 = (nstatus_b8>=1 & nstatus_b8<.)
replace status_other = (nstatus_other>=1 & nstatus_other<.)
drop nstatus_rt nstatus_p nstatus_b8 nstatus_other

//keep one record for each year
duplicates drop methid datecons new_studylevel loanyear, force


//1. use paidprin, paidprin is preferred because outprin decreases in RAP2
replace max_paidprin=0 if max_paidprin==.

//flag BC problematic cases
by methid: gen flag_bc=(issueprov=="BC"&loanyear==2011&max_paidprin<max_paidprin[_n-1])
by methid: egen max_flag_bc=max(flag_bc)
drop flag_bc
ren max_flag_bc flag_bc


//other provinces
//adjust non-decreasing
if ($adjust_nondecrease == 1) {
	by methid new_studylevel: gen newpaidprin=min(sum_prin,max_paidprin) if _n==1
	by methid new_studylevel: replace newpaidprin = min(sum_prin,max(max_paidprin,newpaidprin[_n-1])) if _n!=1
	gen newoutprin = sum_prin-newpaidprin

}
else{
	by methid new_studylevel: gen newpaidprin=min(sum_prin,max_paidprin)
	gen newoutprin = sum_prin-newpaidprin

}

//adjust BC
replace newpaidprin = min(sum_prin, max_paidprin) if flag_bc==1 & loanyear>=2011
replace min_outprin = 0 if flag_bc==1 & loanyear>=2011 & status_p==1 & min_outprin>=.
replace newoutprin = min_outprin if flag_bc==1 & loanyear>=2011


//flag other cases
by methid new_studylevel: gen flag_paidprin = (max_paidprin<max_paidprin[_n-1]&(loanyear!=2011|issueprov!="BC")&_n!=1)
by methid new_studylevel: gen flag_amount = max_paidprin[_n-1] - max_paidprin if flag_paidprin==1
by methid new_studylevel: gen flag_ratio = flag_amount/sum_prin if flag_paidprin==1


by methid: egen max_flag_paidprin = max(flag_paidprin)
by methid: egen max_flag_amount = max(flag_amount)
by methid: egen max_flag_ratio = max(flag_ratio)

drop flag_paidprin flag_amount flag_ratio
ren max_flag_paidprin flag_paidprin
ren max_flag_amount flag_amount
ren max_flag_ratio flag_ratio 

//annual repayment
//principal
by methid new_studylevel: gen paidprin_annual=newpaidprin if _n==1
by methid new_studylevel: replace paidprin_annual = newpaidprin-newpaidprin[_n-1] if _n!=1

//adjust BC
by methid new_studylevel: replace paidprin_annual = min_outprin[_n-1]-min_outprin if flag_bc==1 & loanyear==2011 & min_outprin[_n-1]>=min_outprin
by methid new_studylevel: replace paidprin_annual = 0 if flag_bc==1 & loanyear==2011 & (rapstage=="RAP2"|rapstage=="RAP-PD")


by methid new_studylevel: gen flag_drop = (flag_bc==1 & loanyear==2011 & min_outprin[_n-1]<min_outprin)
by methid: egen max_flag_drop = max(flag_drop)
drop if max_flag_drop==1
drop max_flag_drop flag_drop



//paid interest

replace max_paidint=0 if max_paidint==.

if ($adjust_nondecrease == 1) {
	by methid new_studylevel: gen newpaidint=max_paidint if _n==1
	by methid new_studylevel: replace newpaidint = max(max_paidint,newpaidint[_n-1]) if _n!=1
}
else {
	by methid new_studylevel: gen newpaidint=max_paidint 
}



//adjust BC
replace newpaidint = max_paidint if flag_bc==1 & loanyear>=2011

//annual pay to interest
by methid new_studylevel: gen paidint_annual=newpaidint if _n==1 
by methid new_studylevel: replace paidint_annual = newpaidint-newpaidint[_n-1] if _n!=1

//adjust BC
by methid new_studylevel: replace paidint_annual = paidint_annual[_n-1]*min_outprin[_n-1]/min_outprin[_n-2] if flag_bc==1 & loanyear==2011 & rapstage==""
by methid new_studylevel: replace paidint_annual = max(paidint_annual,0) if flag_bc==1 & loanyear==2011 & rapstage!=""


gen repayment = paidprin_annual + paidint_annual

//total months in rap
by methid: egen total_monthsrap = sum(max_monthsrap)


save "$cleaned/repay_other_$y", replace







