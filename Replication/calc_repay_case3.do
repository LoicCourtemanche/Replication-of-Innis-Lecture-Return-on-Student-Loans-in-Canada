
use "$cleaned/CSLP_repay_cohort_$y", clear


keep if flag_case3==1



//drop records before problematic "P", because those payments are not included in later paidprin
gen datecons_p = datecons if flag_case3==1 & status_p ==1
order datecons_p

by methid: egen max_datecons_p = max(datecons_p)
order max_datecons_p

drop if datecons<=max_datecons_p & max_datecons_p<.
drop datecons_p max_datecons_p


drop status_p_miss sum_status_p_miss status_p_nonmiss sum_status_p_nonmiss status_p sum_status_p status_r sum_status_r 


//collapse payments by year
//keep one entry for each loan year 
preserve
sort methid loanyear, stable

replace paidprin=0 if paidprin>=.
replace paidint=0 if paidint>=.
replace outprin=0 if outprin>=.

by methid loanyear: egen max_paidprin = max(paidprin)
by methid loanyear: egen max_paidint = max(paidint)
by methid loanyear: egen min_outprin = min(outprin)
by methid loanyear: egen max_monthsrap = max(monthsrap)

keep methid loanyear max_paidprin max_paidint max_monthsrap issueprov min_outprin rapstage sum_prin
duplicates drop methid loanyear, force

//////////////////////////////////////////////////////////////////////////


//1. use paidprin, paidprin is preferred because outprin decreases in RAP2
replace max_paidprin=0 if max_paidprin==.

//flag BC problematic cases
by methid: gen flag_bc=(issueprov=="BC"&loanyear==2011&max_paidprin<max_paidprin[_n-1])
by methid: egen max_flag_bc=max(flag_bc)
drop flag_bc
ren max_flag_bc flag_bc


//other provinces
if ($adjust_nondecrease == 1) {
	by methid: gen newpaidprin=max_paidprin if _n==1
	by methid: replace newpaidprin = max(max_paidprin,newpaidprin[_n-1]) if _n!=1

}
else{
	by methid: gen newpaidprin=max_paidprin 
}





//adjust BC
replace newpaidprin = max_paidprin if flag_bc==1 & loanyear>=2011


//flag other cases
by methid: gen flag_paidprin = (max_paidprin<max_paidprin[_n-1]) & (loanyear!=2011|issueprov!="BC") & _n!=1
by methid: gen flag_amount = max_paidprin[_n-1]-max_paidprin if flag_paidprin==1
by methid: gen flag_ratio = flag_amount/sum_prin if flag_paidprin==1



by methid: egen max_flag_paidprin = max(flag_paidprin)
by methid: egen max_flag_amount = max(flag_amount)
by methid: egen max_flag_ratio = max(flag_ratio)

drop flag_paidprin flag_amount flag_ratio
ren max_flag_paidprin flag_paidprin
ren max_flag_amount flag_amount
ren max_flag_ratio flag_ratio 


//annual repayment
//principal
by methid: gen paidprin_annual=newpaidprin if _n==1
by methid: replace paidprin_annual = newpaidprin-newpaidprin[_n-1] if _n!=1

//adjust BC
by methid: replace paidprin_annual = min_outprin[_n-1]-min_outprin if flag_bc==1 & loanyear==2011  & min_outprin[_n-1]>=min_outprin
by methid: replace paidprin_annual = 0 if flag_bc==1 & loanyear==2011 & (rapstage=="RAP2"|rapstage=="RAP-PD")


by methid: gen flag_drop = (flag_bc==1 & loanyear==2011 & min_outprin[_n-1]<min_outprin)
by methid: egen max_flag_drop = max(flag_drop)
drop if max_flag_drop==1
drop max_flag_drop flag_drop

//paid interest
//not decreasing
replace max_paidint=0 if max_paidint==.


if ($adjust_nondecrease == 1) {
	by methid: gen newpaidint=max_paidint if _n==1
	by methid: replace newpaidint = max(max_paidint,newpaidint[_n-1]) if _n!=1
}
else {
	by methid: gen newpaidint=max_paidint 
}

//adjust BC
replace newpaidint = max_paidint if flag_bc==1 & loanyear>=2011

//annual pay to interest
by methid: gen paidint_annual=newpaidint if _n==1 
by methid: replace paidint_annual = newpaidint-newpaidint[_n-1] if _n!=1

//adjust BC
by methid: replace paidint_annual = paidint_annual[_n-1]*min_outprin[_n-1]/min_outprin[_n-2]  if flag_bc==1 & loanyear==2011 & rapstage==""
by methid: replace paidint_annual = max(paidint_annual,0) if flag_bc==1 & loanyear==2011 & rapstage!=""

gen repayment = paidprin_annual + paidint_annual


//total months in rap
by methid: egen total_monthsrap = sum(max_monthsrap)


*************************************************************
//drop payments before 2005
*************************************************************
drop if loanyear<2005
keep methid loanyear total_monthsrap paidprin_annual paidint_annual repayment flag_paidprin flag_amount flag_ratio
save "$cleaned/repayment_case3_$y", replace
restore


//keep last undergrad loan and last non-undergrad loan if last study is not undergrad
sort methid new_studylevel loanyear datecons status_new, stable
by methid new_studylevel: gen last_study_datecons = datecons[_N]
format last_study_datecons %tdD_m_Y
keep if ((last_studylevel==2 & datecons == last_datecons)|(last_studylevel!=2 & datecons==last_study_datecons)) & (studylevel==2|studylevel==last_studylevel)



//after sample selection, make sure first studylevel is undergrad
by methid: gen first_studylevel = studylevel if _n==1

by methid: egen max_first_studylevel = max(first_studylevel)
drop if max_first_studylevel!=2
drop max_first_studylevel
ta first_studylevel


//last undergrad year and first non-undergrad year
by methid new_studylevel: gen last_ugyear = loanyear[_N] if new_studylevel==1

by methid new_studylevel: gen first_nonugyear = loanyear[1] if new_studylevel!=1

by methid: egen last_year = max(last_ugyear)
by methid: egen first_year = max(first_nonugyear)

count if last_year==first_year
count if last_year>first_year
count if last_year<first_year
drop if last_year>=first_year





//collapse by year
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


merge 1:1 methid loanyear using "$cleaned/repayment_case3_$y"
drop _merge

sort methid loanyear, stable
drop last_year first_year
by methid: egen last_year = max(last_ugyear)
by methid: egen first_year = max(first_nonugyear)

replace new_studylevel=1 if loanyear<=last_year & last_studylevel!=2
replace new_studylevel=2 if loanyear>last_year & last_studylevel!=2

//if undergrad only 
replace new_studylevel=1 if last_studylevel==2

drop last_year first_year last_ugyear first_nonugyear


sort methid new_studylevel loanyear, stable
by methid new_studylevel: gen newpaidprin = sum(paidprin_annual)


gen loan_amount = newpaidprin+min_outprin
order loan_amount

by methid new_studylevel: egen new_sum_prin = max(loan_amount)
drop sum_prin
ren new_sum_prin sum_prin

gen newoutprin = sum_prin-newpaidprin

replace newoutprin=0 if newoutprin<0
replace flag_case3=1 if flag_case3>=.

save "$cleaned/repay_case3_$y", replace




