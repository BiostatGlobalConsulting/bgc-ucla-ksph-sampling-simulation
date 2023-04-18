
********************************************************************************

* Here at Biostat Global Consulting, we have VCQI output from several survey 
* datasets where the surveys were designed
* to be representative at the district level. 
*
* This program demonstrates running the sim1 program on that output.
*
*
* The defining features of these datasets are these:
*
* stratumid is an integer variable
* cluterid is an integer variable
* The variable specified in the outcome() option is an integer that takes
* only 3 possible values:
*   1 if the child had the outcome
*   0 if the child was eligible but did not have the outcome
*   . if the child was not eligible
*
*
* The mandatory options for the sim1 program are:
*
* dataset(name of a .dta file in the current working folder that has variables: 
* stratumid, clusterid, and whatever is specified in the output() option)
* outcome(name of variable in the dataset that takes on values 1 or 0 or .)
* stratum(which stratum in the dataset should the simulation analyze)
* abbrev_dataset(short string with no spaces that will appear in the output plot filename)
* abbrev_outcome(short string with no spaces that will appear in the output plot filename)
* title_suffix(short string that will appear at the top of the organ pipe plot alongside the stratum number)
*
*
* Each time ucla_ksph_sim1 is called, it generates a single .png output file 
* named plot_`abbrev_dataset'_`abbrev_outcome'_`stratum'.png
*
* The figure is described in some detail in docment that is available in the 
* same respository as this file:
* https://github.com/BiostatGlobalConsulting/bgc-ucla-ksph-sampling-simulation
*
* Send questions to Dale.Rhoda@biostatglobal.com
*
********************************************************************************

cd "Q:/BMGF - 2023 Survey Simulator"

* Note that these files from Pakistan and Burkina Faso are not available to
* be shared at this time, so this program is also accompanied by a program 
* that allows the user to specify how the outcome is distributed and then
* conducts a single run of the simulation in that stratum for that outcome.

* Pakistan TPVICS 2022 (Round 2) - 152 districts with several dozen PSUs per district (varying numbers)

use TPVICS_R2_ADS, clear
levelsof stratumid, local(slist)
foreach s in `slist' {
	ucla_ksph_sim1, dataset(TPVICS_R2_ADS) outcome(fully_vaccinated_crude)      stratum(`s') abbrev_dataset(tpvr2) abbrev_outcome(fvc)    title_suffix(- Fully Vxd)
	ucla_ksph_sim1, dataset(TPVICS_R2_ADS) outcome(not_vaccinated_crude)        stratum(`s') abbrev_dataset(tpvr2) abbrev_outcome(nvc)    title_suffix(- Zero Dose)
}


* Burkina Faso 2016 - 63 districts - 20 PSUs per district

use BFASO_2016_RI_ADS, clear
levelsof stratumid, local(slist)
foreach s in `slist' {
	ucla_ksph_sim1, dataset(BFASO_2016_RI_ADS) outcome(fully_vaccinated_crude)      stratum(`s') abbrev_dataset(bfaso16) abbrev_outcome(fvc)    title_suffix(- Fully Vxd)
	ucla_ksph_sim1, dataset(BFASO_2016_RI_ADS) outcome(not_vaccinated_crude)        stratum(`s') abbrev_dataset(bfaso16) abbrev_outcome(nvc)    title_suffix(- Zero Dose)
}

foreach o in y01 y50a y50b y50c y75a y75b y75c y99 y100 {
	ucla_ksph_sim1, dataset(survey_with_plausible_yet_perverse_proportions) outcome(`o') stratum(1) abbrev_dataset(faux) abbrev_outcome(`o') title_suffix(- Faux Outcome `o')
}
