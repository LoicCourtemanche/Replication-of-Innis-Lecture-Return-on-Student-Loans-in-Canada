


use "$cleaned/repay_wide_2003", clear
append using "$cleaned/repay_wide_2004"
append using "$cleaned/repay_wide_2005"
append using "$cleaned/repay_wide_2006"
append using "$cleaned/repay_wide_2007"
append using "$cleaned/repay_wide_2008"



ta cohort

//interest rate
sca rrate=${rrate}



//Tobit regression


forval t=9/13{
	gen repayment`t'_hat=.
	
}
//dummy variable for outstanding debt amount
forval t=8/12{
	gen dummy1_`t'=(amount`t'>3000)

	gen dummy2_`t'=(amount`t'>10000)
}

***********************************
//Table B1
***********************************


foreach s in 2 3{
	
			
	forval c=2003/2007{
		local tp=2015-`c'+1
		local tmax=`tp'-1
	
		forval t=8/`tmax'{
			
			
			if (`s'==2){
				disp "****************************************************************************************************"
				disp "tobit regression, use `c' cohort, regress payment at t'=`tp' on observables at t=`t', in repayment at t=`t' "
				disp "****************************************************************************************************"
				
				gen dummy3_`tp'_`t'=(((1+rrate)^(`tp'-`t')-1)/rrate*repayment`t'>(1+rrate)^(`tp'-`t')*amount`t')
			}
			if (`s'==3){
				disp "****************************************************************************************************"
				disp "tobit regression, use `c' cohort, regress payment at t'=`tp' on observables at t=`t', on RAP at t=`t' "
				disp "****************************************************************************************************"
				
				replace dummy3_`tp'_`t'=((`tp'-`t')*repayment`t'>amount`t')
			}
			
			

			
			disp "*******************************************************************"
			disp " joint distributio of dummy1 and dummy3, `c' cohort, t=`t', t'=`tp''"
			disp "*******************************************************************"
			ta dummy1_`t' dummy3_`tp'_`t' if status`t'==`s' & cohort==`c', cell

			
			
			gen temp=amount`t'*(1+rrate)^(`tp'-`t')
			
			
			
			if (`c'==2003 & `s'==3 & `t'>=10){
				tobit repayment`tp' amount`t' repayment`t' if status`t'==`s' & cohort==`c' , ll(0) ul(temp)
			}
			else if (`c'==2003 & `s'==3 & `t'<10){
			    tobit repayment`tp' amount`t' repayment`t' i.dummy3_`tp'_`t' c.amount`t'#c.dummy3_`tp'_`t' c.repayment`t'#c.dummy3_`tp'_`t' if status`t'==`s' & cohort==`c' , ll(0) ul(temp)
			}
			else{
				tobit repayment`tp' amount`t' repayment`t' c.amount`t'#c.dummy1_`t' c.repayment`t'#c.dummy1_`t'  ///
				i.dummy3_`tp'_`t' c.amount`t'#c.dummy3_`tp'_`t' c.repayment`t'#c.dummy3_`tp'_`t' if status`t'==`s' & cohort==`c', ll(0) ul(temp)
			}
			
			
			local cp=2016-`t'

			predict p1 if status`t'==`s' & cohort==`cp', pr(.,0)
			predict p2 if status`t'==`s' & cohort==`cp', pr(0,temp)
			predict p3 if status`t'==`s' & cohort==`cp', pr(temp,.)
			
			predict e1 if status`t'==`s' & cohort==`cp', e(.,0)
			predict e2 if status`t'==`s' & cohort==`cp', e(0,temp)
			predict e3 if status`t'==`s' & cohort==`cp', e(temp,.)
			
			gen temp1=p1*0
			gen temp2=p2*e2
			gen temp3=p3*temp
			egen repayment_hat=rowtotal(temp1 temp2 temp3) if status`t'==`s' & cohort==`cp'			
			

			drop p1 p2 p3 e1 e2 e3 temp1 temp2 temp3 temp
			
		
			
			
			


			if (`s'==2){
				disp "************************************************************************"
				disp "predicted payments at t'=`tp' for `cp' cohort, in repayment at t=`t' "
				disp "************************************************************************"
			}
			if (`s'==3){
				disp "************************************************************************"
				disp "predicted payments at t'=`tp' for `cp' cohort, on RAP at t=`t' "
				disp "************************************************************************"
			}
			


			sum repayment_hat,d
// 			disp r(mean), r(p50), r(p10), r(p25), r(p75)
			replace repayment`tp'_hat = repayment_hat if status`t'==`s' & cohort==`cp' 
			
			

			drop repayment_hat
			

		}
	}
}



drop dummy*

forval t=9/13{
		replace repayment`t'_hat=0 if repayment`t'_hat<0
}



//replace repayment to be imputed
forval c=2004/2008{
	local tlast=2016-`c'
	local tmin=2017-`c'
	forval t=`tmin'/13{
		replace repayment`t'=repayment`t'_hat if cohort==`c' & (status`tlast'==2|status`tlast'==3)
	}
}

//now all cohorts have actual and imputed repayments up to 13 years, after 13 years, use our assumptions
//update outstanding balance and status beyond observed period
gen debt_based=.
forval c=2004/2008{
	local tmin=2016-`c'
	forval t=`tmin'/12{
		local tp=`t'+1
		replace amount`tp'=max(amount`t'*(1+rrate)-repayment`tp',0) if status`tmin'==2 & cohort==`c'
		
		replace debt_based=amount`t'*rrate*(1+rrate)^(11-`tp'+total_monthsrap/12)/((1+rrate)^(11-`tp'+total_monthsrap/12)-1) if status`tmin'==3 & cohort==`c' & total_monthsrap<=60 & `tp'<=10
		
		
		replace debt_based=amount`t'*rrate*(1+rrate)^(16-`tp')/((1+rrate)^(16-`tp')-1) if status`tmin'==3 & cohort==`c' & (total_monthsrap>60 | `tp'>10)
		
		replace amount`tp'=max(amount`t'*(1+rrate)-repayment`tp',0) if status`tmin'==3 & cohort==`c' & repayment`tp'>=debt_based
		
		replace amount`tp'=max(amount`t'-min(repayment`tp',debt_based-rrate*amount`t'),0) if status`tmin'==3 & cohort==`c' & repayment`tp'<debt_based & total_monthsrap<=60 & `tp'<=10
		
		replace amount`tp'=max(amount`t'*(1+rrate)-debt_based,0) if status`tmin'==3 & cohort==`c' & (total_monthsrap>60 | `tp'>10) & repayment`tp'<debt_based
		
		replace total_monthsrap=total_monthsrap+12 if status`tmin'==3 & cohort==`c' & repayment`tp'<debt_based
		
		replace status`tp'=status`tmin' if (status`tmin'==2|status`tmin'==3) & cohort==`c'
	}
}

//in repayment at t:make same repayment as the last payment (imputed) until the loan is paid off in 15 years starting from consolidation or if it takes more than 15 years, pay equal in 15 years
//on RAP at t:make same payment as the last payment (imputed) until RAP run out (15 years since consolidation)
//2 more years of payments
gen amount14 = .
gen amount15 = .

//in repayment at t
gen expected_payment = repayment13/(1+rrate)+repayment13/(1+rrate)^2 if status13==2
replace amount14 = max(amount13*(1+rrate)-repayment13, 0) if expected_payment>=amount13 & amount13<. & expected_payment<. & status13==2
replace repayment14 = min(repayment13, amount13*(1+rrate)) if expected_payment>=amount13 & amount13<. & expected_payment<. & status13==2

replace amount15 = max(amount14*(1+rrate)-repayment13, 0) if expected_payment>=amount13 & amount13<. & expected_payment<. & status13==2
replace repayment15 = min(repayment13, amount14*(1+rrate)) if expected_payment>=amount13 & amount13<. & expected_payment<. & status13==2


replace repayment14 = amount13*rrate*(1+rrate)^2/((1+rrate)^2-1) if expected_payment<amount13 & amount13<. & status13==2
replace repayment15 = amount13*rrate*(1+rrate)^2/((1+rrate)^2-1) if expected_payment<amount13 & amount13<. & status13==2


//on RAP at t, stage 2, government covers interest and principal
replace expected_payment = repayment13/(1+rrate)+repayment13/(1+rrate)^2 if status13==3
replace amount14 = max(amount13*(1+rrate)-repayment13, 0) if expected_payment>=amount13 & amount13<. & expected_payment<. & status13==3
replace repayment14 = min(repayment13, amount13*(1+rrate)) if expected_payment>=amount13 & amount13<. & expected_payment<. & status13==3

replace amount15 = max(amount14*(1+rrate)-repayment13, 0) if expected_payment>=amount13 & amount13<. & expected_payment<. & status13==3
replace repayment15 = min(repayment13, amount14*(1+rrate)) if expected_payment>=amount13 & amount13<. & expected_payment<. & status13==3

replace repayment14 = repayment13 if expected_payment<amount13 & amount13<. & status13==3
replace repayment15 = repayment13 if expected_payment<amount13 & amount13<. & status13==3
	


drop if last_status>=.



keep methid cohort repayment* last_status max_repay_year
drop *hat
drop if last_status==1|last_status==5

reshape long repayment, i(methid) j(year)
drop if repayment==0 | repayment>=.
keep if year>max_repay_year
replace year=year-max_repay_year

ren repayment post_repayment
keep methid year post_repayment cohort

reshape wide post_repayment, i(methid) j(year)



save "$cleaned/predict_2003_2008", replace














