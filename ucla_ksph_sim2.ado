********************************************************************************

* Here at Biostat Global Consulting, we have VCQI output from several survey 
* datasets where the surveys were designed
* to be representative at the district level. 
*
* This program is used to simulate draws from a population where a binary
* outcome is defined by its distribution across clusters...or by a cluster
* sample.
*
* The program can be called in a batch mode where it accesses an accompanying
* dataset, as demonstrated in the accompanying .do file(s) that use the
* phrase 'Batch Run'.
*
* It may also be called for a single run, sampling from a small dataset in 
* memory that lists cluster IDs and cluster coverage estimates.  That is
* deomonstrated in the accompanying file(s) that use the phrase 'Simple Run'.
*
*
* The mandatory options for the sim2 program are:
*
* dataset(name of a .dta file in the current working folder that has variables: 
* stratumid, clusterid, and whatever is specified in the output() option)
* outcome(name of variable in the dataset that takes on values 1 or 0 or .)
* stratum(which stratum in the dataset should the simulation analyze)
* abbrev_dataset(short string with no spaces that will appear in the output plot filename)
* abbrev_outcome(short string with no spaces that will appear in the output plot filename)
* title_suffix(short string that will appear at the top of the organ pipe plot alongside the stratum number)
*
* An optional option is:
*
* savelqas(Y) which will keep a copy of each of the 20 LQAS faux datasets
*
* Each time ucla_ksph_sim2 is called, it generates a single .png output file 
* named plotv2_`abbrev_dataset'_`abbrev_outcome'_`stratum'.png
*
* The figure is described in some detail in docment that is available in the 
* same respository as this file:
* https://github.com/BiostatGlobalConsulting/bgc-ucla-ksph-sampling-simulation
*
* Send questions to Dale.Rhoda@biostatglobal.com
*
* Program updated on 2023-07-25 to include LQAS as sampling plan #3.
* Program updated on 2024-01-12 to export both the opplot and the forest plot 
* with aspect ratio 4:3.
*
********************************************************************************


* This program has been updated to implement LQAS as sampling plan #3.
* (Formerly #3 was a cluster sample with 20 clusters.)
*
* This LQAS simulation selects five random clusters to represent the five strata.
* A future revision could perhaps select a cluster from each quintile of district
* level coverage.

program define ucla_ksph_sim2
	syntax, dataset(string) outcome(string) stratum(integer) abbrev_dataset(string) abbrev_outcome(string) title_suffix(string) [SAVElqas(string)]
	use `dataset', clear

	keep stratumid clusterid `outcome'

	if "`outcome'" != "y" rename `outcome' y

	keep if stratumid == `stratum'

	svyset clusterid, singleunit(scaled)

	* Make a ADS_TO_ANALYZE with 100 respondents per cluster

	capture postclose handle 
	postfile handle stratumid clusterid respid y using datafile, replace

	qui levelsof clusterid, local(clist)
	local ccount 1
	foreach c in `clist' {
		qui sum y if clusterid == `c'
		local temp = 100*r(mean)
		forvalues i = 1/100 {
			post handle (1) (`ccount') (`i') (`=`i'<= `temp'') 
		}
		local ++ccount
	}

	capture postclose handle
	use datafile, clear
	compress
	svyset clusterid, singleunit(scaled)
	save datafile_opplot, replace
	expand 4								// replicate each observation 4X
	qui sum clusterid
	while r(max) < 80 {						// replicate each PSU until there are at least 80
		egen clusterid2 = group(clusterid)
		sum clusterid2
		local cmax = r(max)
		expand 2, gen(dupe)
		replace clusterid2 = clusterid2 + `cmax' if dupe
		drop dupe clusterid
		rename clusterid2 clusterid
		qui sum clusterid
	}
	save datafile, replace					// This is the file we will draw repeated samples from

	svypd y, adjust
	local phat = 100*r(svyp)

	********************************************************************************

	local npsus1   5
	local npsus2  10
	local npsus3   5
	local npsus4  41
	local npsus5 103

	local svyset1 bclusterid, singleunit(scaled)
	local svyset2 bclusterid, singleunit(scaled)
	local svyset3 _n, strata(bclusterid) singleunit(scaled)  // LQAS 
	local svyset4 bclusterid, singleunit(scaled)
	local svyset5 _n


	capture postclose handle
	postfile handle stratumid np npsus m runid phat lo50 hi50 lo95 hi95 deff neff icc using postfile, replace

	set seed 8675309

	forvalues np = 1/5 {					// np = npsus index ... see list above for the list of npsus values
		local npsus `npsus`np''
		di "Running stratum `stratum' with `npsus' PSUs..."
		quietly {
			local m = 160 / `npsus'			// 160 is arbitrary here ... it is close to the sample size proposed by UCLA/KSPH
			if `np' == 3 local m 19
			if `np' == 4 local m 10
			if `np' == 5 local m  1
			forvalues runid = 1/20 {		// draw 20 samples at each value of npsus
				use datafile, clear

				if inlist(`np',1,2,4) {				// the first 5 schemes are cluster samples
					bsample `npsus', cluster(clusterid) idcluster(bclusterid) 
					gen double rand = runiform()
					sort bclusterid rand, stable
					bysort bclusterid: keep if _n <= `m'
				}
				
				if `np' == 5 sample `npsus', count	// the 6th scheme is a simple random sample
				
				if `np' == 3 {						// LQAS sample
					bsample `npsus', cluster(clusterid) idcluster(bclusterid)  
					forvalues ci = 1/`npsus' {
						sum y if bclusterid == `ci'
						local psumean`ci' = r(mean)
					}
					clear // build up the LQAS dataset now
					capture postclose lqas
					postfile lqas psu ssu psumean ssumean respid y using lpostfile, replace
					
					forvalues ci = 1/`npsus' {
						forvalues ssu = 1/6 {
							local ssumean = max(min(rnormal(`psumean`ci'',0.05),1),0) // ssu mean is a random normal draw with mean psumean and sd = 5%, clipped at 0% and 100%
							forvalues respid = 1/19 {
								post lqas (`ci') (`ssu') (`psumean`ci'') (`ssumean') (`respid') (`=runiform()<`ssumean'')
							}
						}
					}
					postclose lqas
					use lpostfile, clear
					gen bclusterid = psu
					compress
					if trim(upper("`savelqas'")) == "Y" save lqas_dataset_`runid', replace
				}

				svyset `svyset`np''
				svypd y, adjust cilevellist(50 95) method(logit)
				
				matrix out = r(ci_list)

				local plist (`stratum') (`np') (`npsus') (`m') (`runid') (`=100*r(svyp)') (`=100*out[1,2]') (`=100*out[1,3]') (`=100*out[2,2]') (`=100*out[2,3]') (`=r(deff)') (`=r(neff)')	
				
				if `np' < 5 {				// calculate ICC for cluster samples
					calcicc y bclusterid
					post handle `plist' (`= r(anova_icc)')
				} 
				else post handle `plist' (0)
			}
		}
	}

	capture postclose handle
	use postfile, clear
	compress
	save, replace
	*save postfile_`abbrev_dataset'_`stratum'_`abbrev_outcome', replace			// Keep a copy in case we want to do something else later

	* The postfile holds what we want to examine.  How to look at it efficiently
	* may vary depending on the number of sampling schemes and the number
	* of draws per scheme.  If you increase draws per scheme from 20 to 100, you
	* might want to make one plot per scheme.  In this case we hope to put
	* all 6x20 CIs onto a single half sheet and pair it with the organ pipe plot.

	* Make a half-sheet figure showing CIs graphically and summarizing the 
	* median and range of several interesting parameters.

	use postfile, clear
																		save postfile_orig, replace

	sort np npsus lo95
	bysort np: gen runid2 = _n
	gen y = np + 0.85 * (runid2 - 10)/20

	gen inside50 = (lo50 <= `phat') & (hi50 >= `phat')
	gen inside95 = (lo95 <= `phat') & (hi95 >= `phat')

	label var np "N PSUs"
	label define npsus 1 "5" 2 "10" 3 "LQAS" 4 "41" 5 "103" , modify
	label values np npsus

	gen cihw = (hi95-lo95)/2
	
	save, replace
	
	local tstring
	forvalues i = 1/5 {
		sum m if np == `i'
		if `i'  < 4 local string`i' N=160; m=`=r(mean)'; Cvg:
		if `i' == 4 local string`i' N=410; m=`=r(mean)'; Cvg:
		if `i' == 5 local string`i' N=103; m=`=r(mean)'; Cvg:
		sum phat if np == `i',d
		local string`i' `string`i'' `=string(r(p50),"%5.1f")' (`=string(r(min),"%5.1f")'-`=string(r(max),"%5.1f")'); DEFF:
		sum deff if np == `i',d
		local string`i' `string`i'' `=string(r(p50),"%5.2f")' (`=string(r(min),"%5.2f")'-`=string(r(max),"%5.2f")'); NEFF:
		sum neff if np == `i',d
		if `i' == 5 local string`i' `string`i'' 103, (103-103); HW: 
		else local string`i' `string`i'' `=string(r(p50),"%5.0fc")' (`=string(r(min),"%5.0fc")'-`=string(r(max),"%5.0fc")'); HW: 
		sum cihw if np == `i',d
		local string`i' `string`i'' `=string(r(p50),"%5.1f")'% (`=string(r(min),"%5.1f")'-`=string(r(max),"%5.1f")')
		
		local tstring `tstring' text(`i'.5 50 "`string`i''", place(0) size(*.44))
	}
	
	
	
	twoway ///
		(scatter np phat, ms(none) ylabel(1 2 3 4 5,valuelabel nogrid angle(0) labsize(vsmall))) ///
		(rcap lo95 hi95 y  if inside95   , horizontal msize(vsmall) lw(vthin) lc(gs12)) ///
		(rcap lo95 hi95 y  if ! inside95 , horizontal msize(vsmall) lw(vthin) lc(red)) ///
		(rcap lo50 hi50 y  if inside50 , horizontal msize(vsmall) lw(vthin) lc(green)) ///
		(rcap lo50 hi50 y  if inside95 & ! inside50 , horizontal msize(vsmall) lw(vthin) lc(gs12)) ///
		(rcap lo50 hi50 y  if ! inside95 , horizontal msize(vsmall) lw(vthin) lc(red)) ///
		(scatter y phat if deff <= 1.5, ms(|) mc(black) msize(vsmall)) ///
		(scatter y phat if deff >  1.5, ms(|) mc(red) msize(vsmall)) ///
		, ///
		  xlabel(0(20)100, labsize(vsmall)) xline(`phat') legend(off) ///
		  graphregion(color(white)) plotregion(color(white)) ///
		  ysize(20) xsize(15) ytitle("N PSUs", size(vsmall)) xtitle("Estimated Coverage (%)", size(vsmall)) `tstring' ///
		  name(forest, replace)

	graph export forest_`abbrev_dataset'_`abbrev_outcome'_`stratum'.png, width(2000) replace
	
	* Make the organ pipe plot

	use datafile_opplot, clear
	svyset clusterid, singleunit(scaled)
	calcicc y clusterid
	local icc = r(anova_icc)

	opplot y, clustvar(clusterid) savedata(rowdata) name(opplot, replace)
	use rowdata, clear
	sum barheight
	local sd Standard deviation of cluster coverage level = `=string(`=r(sd)',"%5.1f")'%

	local title Stratum `stratum' `title_suffix'
	local subtitle Cvg = `=string(`phat',"%5.1f")'%  ICC = `=string(`icc',"%6.3f")'

	use datafile_opplot, clear
	opplot y, clustvar(clusterid) title(`title', size(medsmall)) subtitle(`subtitle', size(small)) footnote(`sd', size(vsmall)) ysize(20) xsize(15) name(opplot, replace)

	graph export opplot_`abbrev_dataset'_`abbrev_outcome'_`stratum'.png, width(2000) replace
			
	* Combine plots and export to png
	graph combine opplot forest, row(1) name(combo, replace) graphregion(color(white))
	graph export plotv2_`abbrev_dataset'_`abbrev_outcome'_`stratum'.png, width(2000) replace

	*capture erase lpostfile.dta
	*capture erase datafile.dta
	*capture erase postfile.dta

end
