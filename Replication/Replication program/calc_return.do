
************************************************
//calculate return
************************************************

//discounting rate
sca irate=0.028


use "$cleaned/repay_2003", clear
append using "$cleaned/repay_2004"
append using "$cleaned/repay_2005"
append using "$cleaned/repay_2006"
append using "$cleaned/repay_2007"
append using "$cleaned/repay_2008"

merge m:1 methid using "$cleaned/predict_2003_2008"

sort methid loanyear, stable
by methid: replace last_status=last_status[_N]

count if (last_status==2|last_status==3|last_status==4) & _merge==1
drop if (last_status==2|last_status==3|last_status==4) & _merge==1
drop _merge

order methid last_status loanyear repayment post_repayment*

//discount repayment after observed period to last period
gen repaymentT=0
forval i=1/8{
    by methid: replace repaymentT=repaymentT+post_repayment`i'/(1+irate)^`i' if post_repayment`i'<. & _n==_N
}


//first discount to last undergrad loan disbursement year
merge m:1 methid using "$cleaned/last_ugloan_disb"
drop if _merge==1 //no information on last ugloan disbursement
drop if _merge==2 //not this cohort
drop _merge

gen repay_year=loanyear-last_ugloan_disb+1
drop if repay_year<=0
duplicates report methid repay_year
duplicates drop methid repay_year, force





sort methid new_studylevel repay_year, stable
gen repayment_disc = repayment/(1+irate)^repay_year
by methid new_studylevel: gen repayment_cumu = sum(repayment_disc)


replace repayment_cumu=repayment_cumu+repaymentT/(1+irate)^repay_year if repaymentT>0 & repaymentT<. //with payments afterT

by methid new_studylevel: gen rate_return = repayment_cumu/(sum_prin-maxgraceint) - 1 if _n==_N 
by methid new_studylevel: replace rate_return = repayment_cumu/sum_prin - 1 if _n==_N & maxgraceint>=.
by methid new_studylevel: replace rate_return = .  if _n==_N & sum_prin-maxgraceint<0 & sum_prin<. & maxgraceint<.

sum rate_return,d



**************************************************
// rate of return at undergrad level
**************************************************
//rate of return
gen agg_rate_return = rate_return
by methid new_studylevel: gen undergrad_frac = newoutprin/(sum_prin-maxgraceint) if _n==_N & studylevel==2 & last_studylevel!=2
by methid new_studylevel: replace undergrad_frac = newoutprin/(sum_prin) if _n==_N & studylevel==2 & last_studylevel!=2 & maxgraceint>=. 

by methid new_studylevel: replace undergrad_frac = . if _n==_N & studylevel==2 & last_studylevel!=2 & sum_prin-maxgraceint<0

//total loan amount
by methid: gen total_loan = sum_prin-maxgraceint if _n==_N
by methid: replace total_loan = sum_prin if _n==_N & maxgraceint>=.
by methid: replace total_loan = . if _n==_N & sum_prin-maxgraceint<0


by methid: egen max_undergrad_frac = max(undergrad_frac)
drop undergrad_frac
ren max_undergrad_frac undergrad_frac

replace agg_rate_return = agg_rate_return+1

by methid new_studylevel: replace agg_rate_return = agg_rate_return*undergrad_frac if _n==_N & studylevel!=2 & last_studylevel!=2 & agg_rate_return<. & undergrad_frac<.

by methid: egen undergrad_return = sum(agg_rate_return)

by methid: replace undergrad_return = . if (_n!=_N|(_n==_N & rate_return>=.))
replace undergrad_return = undergrad_return-1

//drop those who go from undergrad to other, not repay full on undergrad loan and not start to repay on other loan
sort methid new_studylevel loanyear, stable
by methid: gen new_last_studylevel = studylevel[_N]
drop if studylevel==2 & last_studylevel!=2 & new_last_studylevel==2 & undergrad_frac!=0

//undergrad loan amount, for weighting
by methid: gen undergrad_loan = sum_prin[1]-maxgraceint[1]
by methid: replace undergrad_loan = sum_prin[1] if maxgraceint[1]>=.

replace undergrad_loan = . if undergrad_loan<0

drop if undergrad_loan>=.

sum undergrad_return, d


table last_status, c(n undergrad_return mean undergrad_return min undergrad_return max undergrad_return)


//keep one entry for each individual
keep if undergrad_return<.
label values last_studylevel studylevel
keep methid undergrad_return educcat total_loan undergrad_loan last_ugloan_disb last_studylevel last_yearcons last_status default_3yr rap_3yr bankruptcy_3yr bankruptcy_* rap_* default_* paid_* monthsrap_*


//merge with needs and disbursement data
merge 1:m methid using "$cleaned/CSLP_needs_disbursement"
drop if _merge==1 //no obs
drop if _merge==2 //not this cohort
drop _merge

sort methid loanyear,stable
//adjust the return to loan disbursement

replace undergrad_return=(undergrad_return+1)/(1+irate)^(last_ugloan_disb-loanyear)-1

sum undergrad_return,d


table loanyear, c(n undergrad_return mean undergrad_return sd undergrad_return min undergrad_return max undergrad_return)



//calculate total loan borrowed so far, before sample restrictions
by methid: egen sum_loandisb = sum(loandisb)
order methid loanyear loandisb sum_loandisb undergrad_loan total_loan

count if undergrad_loan==sum_loandisb
count if undergrad_loan>sum_loandisb
count if undergrad_loan<sum_loandisb

//sum_loan is the total loan borrowed at the end of the loanyear
gsort methid -loanyear
gen sum_loan = .
by methid: replace sum_loan = undergrad_loan if _n==1
by methid: replace sum_loan = sum_loan[_n-1]-loandisb[_n-1] if _n!=1

sort methid loanyear, stable
order methid loanyear undergrad_loan loandisb sum_loan


count 
count if sum_loan>0
count if sum_loan<=0

count if sum_loan>0 & sum_loan<loandisb
count if sum_loan>0 & sum_loan>=loandisb 

drop if sum_loan<=0

save "$cleaned/return_2003_2008", replace













