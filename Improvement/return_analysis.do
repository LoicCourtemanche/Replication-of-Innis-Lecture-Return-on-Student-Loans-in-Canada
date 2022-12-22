capture log using "results/return_analysis ${Cohort} rrate ${nrrate}" , replace t name(ReturnA)

use "$cleaned/return_2003_2008", clear

*********************************************
//sample restrictions
*********************************************
gen cohort=loanyear

//loan disbursement
keep if cohort==${Cohort}


//age 18-30 at loan disbursement
gen age=cohort-birthyear

drop if age<18|age>30

//drop private instituion, some rare provinces/other countries
drop if insttype=="P"|insttype=="C" //private or college
drop if issueprov=="YT"|issueprov=="NT"|issueprov=="NU"|issueprov=="XX"

gen instprov = substr(edinst,1,1)
gen instprov_num = .
replace instprov_num=1 if instprov=="A"
replace instprov_num=2 if instprov=="B"
replace instprov_num=3 if instprov=="C"
replace instprov_num=4 if instprov=="D"
replace instprov_num=5 if instprov=="E"
replace instprov_num=6 if instprov=="F"
replace instprov_num=7 if instprov=="G"
replace instprov_num=8 if instprov=="H"
replace instprov_num=9 if instprov=="I"
replace instprov_num=10 if instprov=="J"
replace instprov_num=11 if instprov=="K"
replace instprov_num=12 if instprov=="L"
replace instprov_num=23 if instprov=="W"
replace instprov_num=24 if instprov!=""&instprov_num==.
label define instprov 1 "BC" 2 "AB" 3 "SK" 4 "MB" 5 "ON" 6 "QC" 7 "NB" 8 "NS" 9 "PE" 10 "NL" ///
	11 "NT" 12 "YT"  23 "NU" 24 "Other Countries"
label values instprov_num instprov
label variable instprov_num "Undergrad Study Province"
drop if instprov_num==11|instprov_num==12|instprov_num==23|instprov_num==24


//institution 
quietly do rank_cslp

//change variable from string to numeric
foreach var in gender issueprov insttype fieldstudy{
	encode `var', gen(`var'_num)
}

//year in study
ta yearstudy
keep if (yearstudy==3 & last_yearcons<=(${Cohort}+3))|(yearstudy==4 & last_yearcons<=(${Cohort}+2))


//drop trade because very few
drop if fieldstudy_num==11

//drop ontario tech, 2005 cohort year 4
drop if cohort==2005 & yearstudy==4 & inst_cslp==32

//re-group some majors due to small sample size
//CSLP: theology to arts
replace fieldstudy_num = 3 if fieldstudy_num==10


//drop law, dentisry, medicine
drop if fieldstudy=="Law"|fieldstudy=="Dentistry"|fieldstudy=="Medicine"

gen last_studylevel_new = last_studylevel
replace last_studylevel_new = 3 if last_studylevel_new==4
label define last_studylevel_new 1 "Non-degree" 2 "Undergrad" 3 "Master/Phd"
label values last_studylevel_new last_studylevel_new

recode inst_cslp (1/49=1)(50=2)(51=3), gen(inst_cslp_cat)
label define inst_cslp_cat 1 "Ranked University" 2 "College" 3 "Unranked University"
label values inst_cslp_cat inst_cslp_cat

recode sum_loan (min/10000=1)(10000/20000=2)(20000/30000=3)(30000/max=4), gen(sum_loan_cat)
label define sum_loan_cat 1 "less than 10000" 2 "[10000,20000)" 3 "[20000,30000)" 4 "30000+"
label values sum_loan_cat sum_loan_cat

*******************************
//summary statistics
*******************************
count

//no missing variables 
count if undergrad_return<. & sum_loan<. & gender_num<. & category<. & age<. & yearstudy<. & issueprov_num<. & instprov_num<. & fieldstudy_num<. & inst_cslp<.
keep if undergrad_return<. & sum_loan<. & gender_num<. & category<. & age<. & yearstudy<. & issueprov_num<. & instprov_num<. & fieldstudy_num<. & inst_cslp<.


sum undergrad_return, d

sum undergrad_return
sum undergrad_return [weight=loandisb] 



sum age
sum loandisb
sum sum_loan



***********************************
//statistics in Figure 1
***********************************
ta issueprov
ta fieldstudy_num
ta inst_rank_group10
ta sum_loan_cat 


***********************************
//raw difference in Figure 2
//statistics in Table 1 & 2  
//column (3) in Table A1
***********************************
gen All = 1
table All, c(n undergrad_return  mean undergrad_return semean undergrad_return mean default_3yr mean rap_3yr)
drop All

table gender_num, c(n undergrad_return  mean undergrad_return semean undergrad_return mean default_3yr mean rap_3yr)

table category, c(n undergrad_return mean undergrad_return semean undergrad_return mean default_3yr mean rap_3yr)

table issueprov, c(n undergrad_return mean undergrad_return semean undergrad_return mean default_3yr mean rap_3yr)
table issueprov, c(n loandisb mean loandisb sum loandisb) format(%16.2f)
table issueprov [aweight=loandisb], c(mean undergrad_return)



table yearstudy, c(n undergrad_return mean undergrad_return semean undergrad_return mean default_3yr mean rap_3yr)
table yearstudy [aweight=loandisb], c(mean undergrad_return)
table yearstudy, c(mean loandisb sd loandisb mean sum_loan sd sum_loan)



table fieldstudy_num, c(n undergrad_return mean undergrad_return semean undergrad_return mean default_3yr mean rap_3yr)
table fieldstudy_num, c(n loandisb mean loandisb sum loandisb) format(%16.2f)
table fieldstudy_num [aweight=loandisb], c(mean undergrad_return)




table inst_rank_group10, c(n undergrad_return mean undergrad_return semean undergrad_return mean default_3yr mean rap_3yr)




//average return if default in first 3 years
sum undergrad_return if default_3yr==1

//average return if enter rap in first 3 years
sum undergrad_return if rap_3yr==1

//average return if not default and not enter rap in first 3 years
sum undergrad_return if default_3yr==0 & rap_3yr==0 & bankruptcy_3yr==0




***********************************
//Figure 4
***********************************
//distribution of realized returns by early repayment status
graph twoway (kdensity undergrad_return if default_3yr==1, lpattern(dash) lcolor(black)) ///
(kdensity undergrad_return if rap_3yr==1, lpattern(longdash_dot) lcolor(black)) ///
(kdensity undergrad_return if default_3yr==0 & rap_3yr==0 & bankruptcy_3yr==0, lpattern(solid) lcolor(black)) ///
, xtitle("Realized Return") ytitle("Density") graphregion(color(white)) ///
legend (label(1 "Default in first 3 years") label(2 "Enter RAP in first 3 years") label(3 "Not default/RAP/bankruptcy in first 3 years") textwidth(45))
graph save "results/Fig 4 ${Cohort} rrate ${nrrate}" , replace


*************************************
//calculate IRR
*************************************

//calculate IRR after exclude high return borrowers
// preserve
// merge 1:1 methid using "$cleaned/methid_return_0.dta"
// drop if _merge!=3
// sum undergrad_return [weight=loandisb] 
// restore


// preserve
// merge 1:1 methid using "$cleaned/methid_return_0.01.dta"
// drop if _merge!=3
// sum undergrad_return [weight=loandisb] 
// restore

// preserve
// merge 1:1 methid using "$cleaned/methid_return_0.03.dta"
// drop if _merge!=3
// sum undergrad_return [weight=loandisb] 
// restore

// preserve
// merge 1:1 methid using "$cleaned/methid_return_0.05.dta"
// drop if _merge!=3
// sum undergrad_return [weight=loandisb] 
// restore

// preserve
// merge 1:1 methid using "$cleaned/methid_return_0.1.dta"
// drop if _merge!=3
// sum undergrad_return [weight=loandisb] 
// restore



****************
//status
****************
// sum undergrad_return [weight=loandisb] 
// sum undergrad_return [weight=loandisb] if default_3yr==1
// sum undergrad_return [weight=loandisb] if rap_3yr==1
// sum undergrad_return [weight=loandisb] if default_3yr==0 & rap_3yr==0 & bankruptcy_3yr==0



****************
//gender
****************

// table gender [aweight=loandisb], c(mean undergrad_return)


****************
//category
****************

// table category [aweight=loandisb], c(mean undergrad_return)



****************
//province
****************

// table issueprov [aweight=loandisb], c(mean undergrad_return)




****************
//year
****************

// table yearstudy [aweight=loandisb], c(mean undergrad_return)



****************
//major
****************

// table fieldstudy_num [aweight=loandisb], c(mean undergrad_return)


****************
//rank
****************

// table inst_rank_group10 [aweight=loandisb], c(mean undergrad_return)

*******************************
//Table 3
*******************************
//fraction fully repaid as of each year since consolidation
forval i=2/11{
    local im = `i'-1
	replace paid_`i' = paid_`im' if paid_`im'==1 & paid_`i'==0
}

sum paid_*

preserve
collapse (mean) paid_*, by(inst_rank_group10)
list
restore

//fraction entering default by year of repayment
sum default_*

gen first_rap = 0
forval i=1/11{
	replace first_rap = `i' if rap_`i'==1 & first_rap==0
}
ta first_rap




************************************************************************************************
//correlation of average return rates, default rates, RAP rates across institutions
************************************************************************************************
preserve
collapse (count)n=undergrad_return (mean) undergrad_return=undergrad_return (mean) default_3yr=default_3yr (mean) rap_3yr=rap_3yr , by(inst_cslp_new)
corr undergrad_return default_3yr rap_3yr
restore




*******************************
//regressions
*******************************
replace sum_loan = sum_loan/10000


mkspline loan1 1 loan2 2 loan3 3 loan4 = sum_loan, marginal


ren loan2 loan_greater_10000
ren loan3 loan_greater_20000
ren loan4 loan_greater_30000


************************************************************
//regression 1, institution dummy only
************************************************************
regress undergrad_return ib51.inst_cslp_new, baselevels
predict predict_return
sum predict_return, d
drop predict_return



************************************************************
//regression 2, insitution dummy and background 
// Table E1 column(1)
************************************************************
regress undergrad_return sum_loan loan_greater_10000  loan_greater_20000  loan_greater_30000 i.gender_num ib4.category ib21.age i.yearstudy ib7.issueprov_num  ib51.inst_cslp_new, baselevels
predict predict_return
sum predict_return, d
drop predict_return

//institution effect, variance of predicted return
preserve
foreach var in sum_loan loan_greater_10000  loan_greater_20000  loan_greater_30000  gender_num category age yearstudy issueprov_num {
	replace `var' = 0
}
predict insit_effect


table inst_cslp_new, c(n insit_effect mean insit_effect min insit_effect max insit_effect)
sum insit_effect,d 
restore


************************************************************
//regression 3, field of study dummy only
// Table E1, column(2)
************************************************************
regress undergrad_return ib3.fieldstudy_num, baselevels
predict predict_return
sum predict_return, d
drop predict_return

************************************************************
//regression 4, field of study and background
// Table E1, column(3)
************************************************************
regress undergrad_return sum_loan loan_greater_10000  loan_greater_20000  loan_greater_30000 i.gender_num ib4.category ib21.age i.yearstudy ib7.issueprov_num  ib3.fieldstudy_num, baselevels
predict predict_return
sum predict_return, d
drop predict_return

//major effect, variance of predicted return
preserve
foreach var in sum_loan loan_greater_10000  loan_greater_20000  loan_greater_30000  gender_num category age yearstudy issueprov_num {
	replace `var' = 0
}
predict major_effect

table fieldstudy_num, c(n major_effect mean major_effect min major_effect max major_effect)
sum major_effect,d 
restore


************************************************************
//regression 5, field of study and background, no loan amount
// Table E1 column(4)
************************************************************
regress undergrad_return i.gender_num ib4.category ib21.age i.yearstudy ib7.issueprov_num  ib3.fieldstudy_num, baselevels
predict predict_return
sum predict_return, d
drop predict_return

//major effect, variance of predicted return
preserve
foreach var in gender_num category age yearstudy issueprov_num {
	replace `var' = 0
}
predict major_effect

table fieldstudy_num, c(n major_effect mean major_effect min major_effect max major_effect)
sum major_effect,d 
restore

************************************************************
//regression 6, field, institution, background
// Table E1 column(5)
************************************************************
regress undergrad_return sum_loan loan_greater_10000  loan_greater_20000  loan_greater_30000 i.gender_num ib4.category ib21.age i.yearstudy ib7.issueprov_num  ib3.fieldstudy_num ib51.inst_cslp_new, baselevels
mat A=e(b)
sca gamma0 = A[1,1]
sca gamma1 = A[1,2]
sca gamma2 = A[1,3]
sca gamma3 = A[1,4]

predict predict_return
sum predict_return, d
drop predict_return

***********************************
//loan limit in Table 4
***********************************
preserve
foreach var in sum_loan loan_greater_10000  loan_greater_20000  loan_greater_30000{
	replace `var' = 0
}
predict predict_return

collapse (mean) predict_return, by(fieldstudy_num)


gen loan_lower1 = -predict_return/gamma0
gen loan_lower2 = -(predict_return-gamma1)/(gamma0+gamma1)
gen loan_lower3 = -(predict_return-gamma1-2*gamma2)/(gamma0+gamma1+gamma2)
gen loan_greater3 = -(predict_return-gamma1-2*gamma2-3*gamma3)/(gamma0+gamma1+gamma2+gamma3)

gen loan_limit=.
replace loan_limit=0 if predict_return<0
replace loan_limit=loan_lower1*10000 if loan_lower1>=0 & loan_lower1<=1
replace loan_limit=loan_lower2*10000 if loan_lower2>=1 & loan_lower2<=2
replace loan_limit=loan_lower3*10000 if loan_lower3>=2 & loan_lower3<=3
replace loan_limit=loan_greater3*10000 if loan_greater3>=3
list loan_limit
restore

//major effect, variance of predicted return
preserve
foreach var in sum_loan loan_greater_10000  loan_greater_20000  loan_greater_30000  gender_num category age yearstudy issueprov_num inst_cslp_new{
	replace `var' = 0
}
predict major_effect


table fieldstudy_num, c(n major_effect mean major_effect min major_effect max major_effect)
sum major_effect,d 
restore


//institution effect, variance of predicted return
preserve
foreach var in sum_loan loan_greater_10000  loan_greater_20000  loan_greater_30000  gender_num category age yearstudy issueprov_num fieldstudy_num{
	replace `var' = 0
}
predict insit_effect


table inst_cslp_new, c(n insit_effect mean insit_effect min insit_effect max insit_effect)
sum insit_effect,d 
restore


************************************************************************************************************************
//regression 7, regression 6 + interaction of institution and filed dummies with (loan amount - average loan amount)
//add interaction of demean loan amount with province dummies
//Table E1 column(6)
************************************************************************************************************************
//demean within year of study
gen demean_loan = .
sum sum_loan if yearstudy==3
replace demean_loan=sum_loan-r(mean) if yearstudy==3
sum demean_loan if yearstudy==3


sum sum_loan if yearstudy==4
replace demean_loan=sum_loan-r(mean) if yearstudy==4
sum demean_loan if yearstudy==4

sum demean_loan



regress undergrad_return sum_loan loan_greater_10000  loan_greater_20000  loan_greater_30000 i.gender_num ib4.category ib21.age i.yearstudy ib7.issueprov_num##c.demean_loan  ib3.fieldstudy_num##c.demean_loan  ib51.inst_cslp_new##c.demean_loan , baselevels


predict predict_return
sum predict_return, d


//major effect, variance of predicted return
preserve
foreach var in sum_loan loan_greater_10000  loan_greater_20000  loan_greater_30000  gender_num category age yearstudy issueprov_num inst_cslp_new demean_loan{
	replace `var' = 0
}
predict major_effect


table fieldstudy_num, c(n major_effect mean major_effect min major_effect max major_effect)
sum major_effect,d 
restore

//institution effect, variance of predicted return
preserve
foreach var in sum_loan loan_greater_10000  loan_greater_20000  loan_greater_30000  gender_num category age yearstudy issueprov_num fieldstudy_num demean_loan{
	replace `var' = 0
}
predict insit_effect


table inst_cslp_new, c(n insit_effect mean insit_effect min insit_effect max insit_effect)
sum insit_effect,d 
restore





***********************************
//Figure 3
***********************************
//realized return and predicted return, kernel
graph twoway (kdensity undergrad_return, lpattern(solid) lcolor(black)) ///
(kdensity predict_return, lpattern(dash) lcolor(black)), xtitle("Return") ytitle("Density") graphregion(color(white)) ///
legend (label(1 "Realized return") label(2 "Predicted return"))
graph save "results/Fig 3 ${Cohort} rrate ${nrrate}" , replace


***********************************
//Table 5
***********************************
//weighted return if exclude high return borrowers
sum undergrad_return [weight=loandisb] 
sum undergrad_return [weight=loandisb] if predict_return<=0
sum undergrad_return [weight=loandisb] if predict_return<=0.01
sum undergrad_return [weight=loandisb] if predict_return<=0.03
sum undergrad_return [weight=loandisb] if predict_return<=0.05
sum undergrad_return [weight=loandisb] if predict_return<=0.1

//save after excluding high return borrowers

preserve
drop if predict_return>0
keep methid
duplicates drop 
save "$cleaned/methid_return_0.dta", replace
restore

preserve
drop if predict_return>0.01
keep methid
duplicates drop 
save "$cleaned/methid_return_0.01.dta", replace
restore

preserve
drop if predict_return>0.03
keep methid
duplicates drop 
save "$cleaned/methid_return_0.03.dta", replace
restore

preserve
drop if predict_return>0.05
keep methid
duplicates drop 
save "$cleaned/methid_return_0.05.dta", replace
restore

preserve
drop if predict_return>0.1
keep methid
duplicates drop 
save "$cleaned/methid_return_0.1.dta", replace
restore



//fraction of negative return by gender and year in study
gen neg_realized = (undergrad_return<0)
gen neg_predict = (predict_return<0)



sum undergrad_return, d
sum neg_realized

sum predict_return, d
sum neg_predict


capture log close capture log close ReturnA
