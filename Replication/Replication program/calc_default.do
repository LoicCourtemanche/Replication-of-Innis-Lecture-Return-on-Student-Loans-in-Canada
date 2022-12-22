
************************************************
// set up parameter values
************************************************

use "frac_def", clear

//some frac_def_rehab missing, replace to 0
forval i=1/6{
	replace frac_def_rehab`i'=0 if frac_def_rehab`i'>=.
}

//matrix is years_in_repay*def_amt_cat, 5*6
forval i=1/8{
	mkmat frac_def_coll* if years_in_bin==`i', matrix(frac_def_coll`i') rowname(years_in_repay)
	mkmat frac_def_rehab* if years_in_bin==`i', matrix(frac_def_rehab`i') rowname(years_in_repay)

}


//matrix is 1*6
use "frac_rehab", clear

//aggregate average
egen total_amt_rehab=rowtotal(total_amt_rehab*)
egen total_amt_pay=rowtotal(total_amt_pay*)
gen frac_rehab_paid=total_amt_pay/total_amt_rehab

egen frac_rehab_paid_min=rowmin(frac_rehab_paid*)
egen frac_rehab_paid_max=rowmax(frac_rehab_paid*)


//8*1
mkmat frac_rehab_paid, matrix(frac_rehab_paid)
mkmat frac_rehab_paid_min, matrix(frac_rehab_paid_min)
mkmat frac_rehab_paid_max, matrix(frac_rehab_paid_max)


//1*6
forval i=1/8{
	mkmat frac_rehab_paid* if years_in_bin==`i', matrix(frac_rehab_paid`i') 
}


************************************************
// calculate payments after default
************************************************
use "$cleaned/default_$y", clear
gen date = datedefault-datecons
drop if date<=0

gen defaultamount=round(min_defaultamount)


recode date (0/364=1)(365/729=2)(730/1094=3)(1095/1825=4)(1826/max=5), gen(years_in_repay)
label define years_in_repay 1 "0-11 MONTHS" 2 "12-23 MONTHS" 3 "24-35 MONTHS" 4 "36-59 MONTHS" 5 "60 OR MORE MONTHS"
label values years_in_repay years_in_repay

recode defaultamount (0/3000=1)(3001/6000=2)(6001/10000=3)(10001/15000=4)(15001/20000=5)(20001/max=6), gen(def_amt_cat) 
label define def_amt_cat 1 "$0-3000" 2 "$3001-6000" 3 "$6001-10000" 4 "$10001-15000" 5 "$15001-20000" 6 "$20001 OR MORE"
label values def_amt_cat def_amt_cat

//fraction of rehabilitation payments paid by borrower
forval i=1/8{
	matrix input frac_paid_borr`i' = (1,1,1,1,1,1)
}

matrix input frac_paid_borr = ( 1 \ 1 \ 1 \ 1 \ 1 \ 1 \ 1 \ 1)
matrix input frac_paid_borr_min = ( 1 \ 1 \ 1 \ 1 \ 1 \ 1 \ 1 \ 1)
matrix input frac_paid_borr_max = ( 1 \ 1 \ 1 \ 1 \ 1 \ 1 \ 1 \ 1)

//different methods to calculate, choose one of the following
//does not differ by much. use case2 as the baseline
local case1_mean = 0 //use frac_rehab_paid
local case1_min=0 //use frac_rehab_paid_min
local case1_max=0 //use frac_rehab_paid_max
local case2 = 1 //assume D_R=D, use frac_rehab_paid*
local case3 = 0 //use representative defaulter, D_R=D*Phi_rehab

quietly{

gen temp=0
gen temp2=0
//calculate payments after default
forval t=1/8{
	gen payment`t' = 0
	forval i=1/5{
		forval j=1/6{
			replace payment`t' = payment`t' + defaultamount*frac_def_coll`t'[`i',`j'] if years_in_repay==`i' & def_amt_cat==`j'
		}
	}
	forval tau=1/`t'{
		local z = `t'-`tau'+1
		forval i=1/5{
			forval j=1/6{
				replace temp = defaultamount*frac_def_rehab`z'[`i',`j'] if years_in_repay==`i' & def_amt_cat==`j'
			}
		}
		replace temp2=round(temp)

		if (`case1_mean'==1) {
			replace payment`t' = payment`t' + temp*frac_rehab_paid[`tau',1]*frac_paid_borr[`tau',1]
		}
		else if (`case1_min'==1){
			replace payment`t' = payment`t' + temp*frac_rehab_paid_min[`tau',1]*frac_paid_borr_min[`tau',1]
		}
		else if (`case1_max'==1){
			replace payment`t' = payment`t' + temp*frac_rehab_paid_max[`tau',1]*frac_paid_borr_max[`tau',1]
		}
		else if (`case2'==1){
			replace payment`t' = payment`t' + temp*frac_rehab_paid`tau'[1,1]*frac_paid_borr`tau'[1,1] if defaultamount>=1 & defaultamount<=3000
			replace payment`t' = payment`t' + temp*frac_rehab_paid`tau'[1,2]*frac_paid_borr`tau'[1,2] if defaultamount>=3001 & defaultamount<=6000
			replace payment`t' = payment`t' + temp*frac_rehab_paid`tau'[1,3]*frac_paid_borr`tau'[1,3] if defaultamount>=6001 & defaultamount<=10000
			replace payment`t' = payment`t' + temp*frac_rehab_paid`tau'[1,4]*frac_paid_borr`tau'[1,4] if defaultamount>=10001 & defaultamount<=15000
			replace payment`t' = payment`t' + temp*frac_rehab_paid`tau'[1,5]*frac_paid_borr`tau'[1,5] if defaultamount>=15001 & defaultamount<=20000
			replace payment`t' = payment`t' + temp*frac_rehab_paid`tau'[1,6]*frac_paid_borr`tau'[1,6] if defaultamount>=20001
		}
		else if (`case3'==1){
			replace payment`t' = payment`t' + temp*frac_rehab_paid`tau'[1,1]*frac_paid_borr`tau'[1,1] if temp2>=1 & temp2<=3000
			replace payment`t' = payment`t' + temp*frac_rehab_paid`tau'[1,2]*frac_paid_borr`tau'[1,2] if temp2>=3001 & temp2<=6000
			replace payment`t' = payment`t' + temp*frac_rehab_paid`tau'[1,3]*frac_paid_borr`tau'[1,3] if temp2>=6001 & temp2<=10000
			replace payment`t' = payment`t' + temp*frac_rehab_paid`tau'[1,4]*frac_paid_borr`tau'[1,4] if temp2>=10001 & temp2<=15000
			replace payment`t' = payment`t' + temp*frac_rehab_paid`tau'[1,5]*frac_paid_borr`tau'[1,5] if temp2>=15001 & temp2<=20000
			replace payment`t' = payment`t' + temp*frac_rehab_paid`tau'[1,6]*frac_paid_borr`tau'[1,6] if temp2>=20001
		}

	}
}

forval i=1/8{
	gen post_default_payment`i'=payment`i'
}


}


keep methid post_default_payment*

save "$cleaned/default_pdv_$y", replace











