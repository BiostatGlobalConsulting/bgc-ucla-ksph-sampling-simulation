********************************************************************************
*
* Explanatory notes appear at the bottom of the file.
*
* Typically the user changes only the numbers inside the block of code
* that starts with: input clusterid coverage
* and ends with: end
* 
* To change some portions of the figure filename, you may modify some
* of the options on the line that begins with: ucla_ksph_sim2
*
* Contact Dale Rhoda with questions:  Dale.Rhoda@biostatglobal.com
*
********************************************************************************

cd "Q:/BMGF - 2023 Survey Simulator"

clear all

* Define the coverage profile within the stratum
input clusterid coverage
1	60
2   50
3	40
4	55
9	0
11	0
end

* Use the coverage profile to generate a dataset for the simulation
capture postclose prepsim
postfile prepsim stratumid clusterid respid y using simdata, replace
forvalues i = 1/`=_N' {
	forvalues j = 1/100 {
		post prepsim (1) (`=clusterid[`i']') (`j') (`=`j'<= coverage[`i']')
	}
}
postclose prepsim

* Run the simulation once
ucla_ksph_sim2, dataset(simdata) outcome(y) stratum(1) abbrev_dataset(SIM) abbrev_outcome(FAUX) title_suffix(- Faux Outcome)


********************************************************************************
*
* This program demonstrates running the sim2 program on data from a faux
* stratum whose coverage properties are established in the block of code
* below that begins with the syntax: input clusterid coverage
*
* The user may specify as many or as few clusters as needed to characterize
* coverage in the stratum.  If every cluster has the same coverage, you only 
* need to specify a single cluster. 

/*
input clusterid coverage
1	60
end
*/

* Each cluster represents an equal portion of the population, so if there 
* are two levels of coverage, a high level found in 1/3 of the stratum
* and a lower level found in 2/3 of the stratum, you need 3 lines of input:

/*
input clusterid coverage
1	60
2   40
3	40
end
*/

* The coverage could also always be specified using 100 lines of input.
*
* It is not necessary for the clusterid numbers to be consecutive, but 
* they should be non-repeating integers.  It is also not necessary to 
* specify the coverage in any kind of order.  They will be sorted into 
* descending order to make the organ pipe plot.  The following input would
* yield the same output as that above:

/*
input clusterid coverage
1	40
2   60
3	40
end

input clusterid coverage
97	60
2   40
32	40
end

input clusterid coverage
1	60
2	40
3   40
4	40
5 	60
6	40
end
*/

*
* The inputs are used to generate an input dataset named: prepsim.
*
* Then the code runs the simulation on that dataset and generates a figure
* which is saved as a .png file.*
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
********************************************************************************