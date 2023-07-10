
* Purpose: Sample code and note for lorenz curve

clear all 

* creat dataset 

input hhid setA setB setC setD 

1	2000	1500	1000 	1000 	
2	3000	2500	1000 	1000 	
3	4000	3500	1000 	2000 	
4	5000	4500	1000 	2000 	
5	6000	5500	1000 	50000 	

end 

* sum-stat 
sum set* 

* reshape dataset to use glcurve 
reshape long set, i(hhid) j(group) string

encode group, gen(pop)

* use glcurve to generate the lorenz curve
glcurve set, glvar(pyord) pvar(prank) sortvar(hhid) replace by(pop) split lorenz 


** Alternative Way - using STATA built-in command **

sort pop hhid 

forval i = 1/3 {
 sum set if pop==`i'
 scalar nobs`i' = r(N)
}

ge rank=.
egen tmp = rank(hhid) if pop == 1
replace rank=tmp/nobs1 if pop == 1
drop tmp

egen tmp = rank(hhid) if pop == 2
replace rank=tmp/nobs2 if pop == 2
drop tmp

egen tmp = rank(hhid) if pop == 3
replace rank=tmp/nobs3 if pop == 3


forval i = 1/3 {
 sum set if pop ==`i'
 scalar s_set_`i' = r(sum)
}

gen yord_1 = sum(set)/s_set_1 if pop == 1
gen yord_2 = sum(set)/s_set_2 if pop == 2
gen yord_3 = sum(set)/s_set_3 if pop == 3

ge rank2 = rank
lab var yord_1 "Population A"
lab var yord_2 "Population B"
lab var yord_3 "Population C"


lab var rank "Cumul share of HH"
lab var rank2 "line of equality"

twoway 	(line yord_1 rank , sort clwidth(medthin) clpat(solid) clcolor("blue")) ///
		(line yord_2 rank, sort clwidth(medthin) clpat(longdash) clcolor("red")) ///
		(line yord_3 rank, sort clwidth(medthin) clpat(longdash) clcolor("153 204 0")) ///
		(line rank2 rank , sort clwidth(medthin) clcolor(gray)), ///
		ytitle(cumulative share of income, size(medsmall)) ///
		yscale(titlegap(5)) xtitle(, size(medsmall)) ///
		legend(rows(5)) xscale(titlegap(5)) ///
		legend(region(lwidth(none))) plotregion(margin(zero)) ///
		ysize(5.75) xsize(5) plotregion(lcolor(none))

