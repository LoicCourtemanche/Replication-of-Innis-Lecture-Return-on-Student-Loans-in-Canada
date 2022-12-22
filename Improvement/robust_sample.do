
use "$cleaned/repay_2005", clear
append using "$cleaned/repay_2006"
append using "$cleaned/repay_2007"
append using "$cleaned/repay_2008"
append using "$cleaned/repay_2009"
append using "$cleaned/repay_2010"
append using "$cleaned/repay_2011"
append using "$cleaned/repay_2012"
append using "$cleaned/repay_2013"
append using "$cleaned/repay_2014"
append using "$cleaned/repay_2015"


//undergrad loan amount
sort methid loanyear
gen undergrad_loan = sum_prin-maxgraceint if studylevel==2
replace undergrad_loan = sum_prin if studylevel==2&maxgraceint>=.
by methid: egen max_undergrad_loan=max(undergrad_loan)
drop undergrad_loan 
ren max_undergrad_loan undergrad_loan


keep methid loanyear last_studylevel last_yearcons default_3yr rap_3yr bankruptcy_3yr bankruptcy_* rap_* default_* paid_* sum_prin undergrad_loan diff diff_frac
drop default_pdv 

by methid: keep if _n==_N
drop loanyear

replace undergrad_loan = . if undergrad_loan<0

merge 1:m methid using "$cleaned/CSLP_needs_disbursement"
drop if _merge==1 //no obs
drop if _merge==2 //not this cohort
drop _merge


gen cohort=loanyear
keep if cohort==2005

keep if yearstudy==3|yearstudy==4

if ($check_sample==2){
	keep if (yearstudy==3 & last_yearcons<=2008)|(yearstudy==4 & last_yearcons<=2007)
}



//age 18-30 at loan disbursement
gen age=cohort-birthyear

table fieldstudy, c(n age mean age min age max age)

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


//drop trade because very few
drop if fieldstudy_num==11

//drop ontario tech, 2005 cohort year 4
drop if cohort==2005 & yearstudy==4 & inst_cslp==32

//re-group some majors due to small sample size
//CSLP: theology to arts
replace fieldstudy_num = 3 if fieldstudy_num==10

//a new major dummy that group dentistry into health science
gen fieldstudy_num2 = fieldstudy_num
replace fieldstudy_num2=7 if fieldstudy_num2==5
label values fieldstudy_num2 fieldstudy_num

//drop law, dentisry, medicine
drop if fieldstudy=="Law"|fieldstudy=="Dentistry"|fieldstudy=="Medicine"

keep if gender_num<. & category<. & age<. & yearstudy<. & issueprov_num<. & instprov_num<. & fieldstudy_num<. & inst_cslp<.


count 


****************************************************
//summary statistics in Table A1
****************************************************
ta gender_num
sum age
ta category
ta issueprov_num
ta yearstudy
ta fieldstudy_num
ta inst_rank_group10
ta last_yearcons
sum default_3yr
sum rap_3yr

forval i=2/11{
    local im = `i'-1
	replace paid_`i' = paid_`im' if paid_`im'==1 & paid_`i'==0
}

sum paid_3


count if last_yearcons<=2013
ta default_3yr if last_yearcons<=2013
ta rap_3yr if last_yearcons<=2013
ta paid_3 if last_yearcons<=2013



sum loandisb

