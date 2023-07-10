/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	2nd round data collection: Data analysis 			
Author				:	Nicholus Tint Zaw
Date				: 	03/01/2023
Modified by			:


*******************************************************************************/

********************************************************************************
** Directory Settings **
********************************************************************************

do "$do/00_dir_setting.do"


	****************************************************************************
	* Child IYCF Data *
	****************************************************************************
	//log using "$result/CI_test", replace  
	
	use "$dta/pnourish_child_iycf_final.dta", clear 
	
	* svy weight apply 
	svyset [pweight = weight_final], strata(stratum_num) vce(linearized) psu(geo_vill)
	
	** CI: using calculation process - chapeter 8 
	** apply survey weight in both ranking assingment and CI estimation 
	// ref: https://www.worldbank.org/content/dam/Worldbank/document/HDN/Health/HealthEquityCh8.pdf
	
	* ranking assingment using Health Equity Index score - apply weight 
	glcurve NationalScore [aw=weight_final], pvar(rank) nograph
	
	sum weight_final // identify the longest decimal point 
	di `r(max)' - floor(`r(max)')
	
	gen weight_final_int = weight_final * 10^6 // need integer weight var for fw weight 
	gen new_weight = int(weight_final_int)

	qui sum rank [fw=new_weight]
	sca var_rank=r(Var)
	qui sum dietary_tot [fw=new_weight]
	scalar mean=r(mean)

	gen lhs=2*var_rank*(dietary_tot/mean)
	regr lhs rank [pw=weight_final], vce(cluster stratum_num) // control culster 
	sca c=_b[rank]
	sca list c

	* SE with weight 
	regr dietary_tot rank [pw=weight_final], vce(cluster stratum_num)
	nlcom ((2*var_rank)/(_b[_cons]+0.5*_b[rank]))*_b[rank]

	
	
	// Concentration index - using conindex
	conindex dietary_tot, rankvar(NationalScore) truezero svy 
	conindex dietary_tot, rankvar(rank) truezero svy 

	conindex dietary_tot, rankvar(NationalScore) truezero svy graph
	graph export "$plots/00_Lorenz_child_dietary_diversity.png", replace
 
	
	** for ranking which variable should we use - CI sensitivity 
	** We have health equity index score (NationalScore) and last month income (income_lastmonth)
	** last month income will be more senistive for immediate changes/shock (acute proverty) and 
	** equity index score can be long term - chornic poverty  
	
	
	conindex dietary_tot, rankvar(NationalScore) truezero svy  // add cluster option for SE cluster
	conindex dietary_tot, rankvar(income_lastmonth) truezero svy 

	conindex mad, rank(NationalQuintile) svy wagstaff bounded limits(0 1)
	conindex mad, rank(income_lastmonth) svy wagstaff bounded limits(0 1)

&&
	
	conindex mad, rankvar(NationalScore) truezero svy // more sensitive to health equity index 
	conindex mad, rankvar(income_lastmonth) truezero svy 

	conindex mad, rankvar(NationalScore) truezero svy graph
	graph export "$plots/00_Lorenz_child_minimum_acceptable_diet.png", replace


	//log close 

	
// END HERE 


