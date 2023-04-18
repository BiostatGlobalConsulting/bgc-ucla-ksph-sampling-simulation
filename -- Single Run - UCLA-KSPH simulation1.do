cd "Q:/BMGF - 2023 Survey Simulator"

clear all

input clusterid coverage
1	60
2   50
3	40
4	55
9	0
11	0
end

capture postclose prepsim
postfile prepsim stratumid clusterid respid y using simdata, replace
forvalues i = 1/`=_N' {
	forvalues j = 1/100 {
		post prepsim (1) (`=clusterid[`i']') (`j') (`=`j'<= coverage[`i']')
	}
}
postclose prepsim

ucla_ksph_sim1, dataset(simdata) outcome(y) stratum(1) abbrev_dataset(SIM) abbrev_outcome(FAUX) title_suffix(- Faux Outcome)
