* Gini Inex *

// Create a sample dataset on income
clear

// Generate income variable
set seed 1234
set obs 1000

// Set desired mean and standard deviation
local mean_income = 5000
local sd_income = 2000

// Generate income variable with no negative values

gen income = rnormal(`mean_income', `sd_income')

replace income = 0 if income < 0 

// Display summary statistics of the generated income variable
summarize income

// Generate hhid 
gen hhid = _n 

// Sort the dataset by income
sort income

// Calculate the cumulative proportion of income and population
egen tot_income = total(income)
gen share_income = income / tot_income 
gen cum_share_income = share_income
replace cum_share_income = cum_share_income[_n-1] + share_income if _n > 1

forvalue x = 1/_N {
	if x > 1 {
		
		local y = `x' - 1
		local cum = cum_share_income[`y'] + share_income[`x']
		replace cum_share_income[`x'] = `cum'
	}
	
}


&&&
egen cum_pop = seq(), from(1) to(`_N') / _N

// Calculate the area under the Lorenz curve
egen area = total(cum_income) / _N

// Calculate the Gini index
gen gini_index = 1 - 2 * area

// Display the Gini index
summarize gini_index
di "Gini Index: " r(mean)


&&&&&&&&&&&&
// Create a sample dataset on doctor visits and socioeconomic status
clear

// Generate doctor visits variable
set seed 1234
set obs 1000
gen doctor_visits = rpoisson(10)

// Generate socioeconomic status variable
gen socioeconomic_status = rnormal(0, 1)

// Sort the dataset by socioeconomic status
sort socioeconomic_status

// Calculate the concentration index
egen rank = rank(socioeconomic_status)
egen doctor_visits_sum = total(doctor_visits)
gen cum_doctor_visits = doctor_visits_sum / sum(doctor_visits)
qui summarize doctor_visits
local mean_doctor_visits = r(mean)
qui conindex doctor_visits, rankvar(rank) truezero
local concentration_index = r(concentration_index)

// Calculate the Gini index
qui gini doctor_visits, weight(doctor_visits_sum)
local gini_index = r(gini)

// Display the results
di "Concentration Index: " `concentration_index'
di "Gini Index: " `gini_index'


**************


