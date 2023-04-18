# bgc-ucla-ksph-sampling-simulation
Simulation code and output to explore some of the sampling plans proposed by UCLA and KSPH

********************************************************************************
This repository holds Stata code to run simulations of some vaccination
coverage sampling plans to evaluate possible outcomes from some work
described in a UCLA-Kinshasa School of Public Health protocol.

The work is described in a document in this folder and a great deal of
simulation output is held in a PowerPoint slide deck here, as well.

We share the code to run the simulation here.

To run this simulation, four .ado files must be found in your Stata 
adopath.  You can accomplish this by simply copying them to the 
folder where you will do the work, or you may save them in a folder
that is already in your adopath (e.g., c:/ado/personal) or you may 
save them in a folder and then add that folder to your adopath. 
You can learn more by typing: 'help adopath' at the Stata command prompt.

********************************************************************************
ucla_ksph_sim1.ado  -- runs the simulation described in the memo here

opplot.ado          -- generates an organ pipe plot; this is a slightly
                       modified version of the opplot.ado that is part
                       of the WHO VCQI set of programs; the modifications
                       control some of the label sizes in the plots
                       
svypd.ado           -- the Biostat Global Consulting wrapper to Stata's
                       svy: proportion command.  (Also part of VCQI.)
                       
calcicc.ado         -- the Biostat Global Consulting improvement on Stata's
                       command to calculate intracluster correlation 
                       coefficient (ICC) (Also part of VCQI.)
                       
Note: Three of these files have Stata help files, so when the .ado files
      and .sthlp files are in your adopath, you can type:
         help opplot or
         help svypd or
         help calcicc

Abbreviation: 
VCQI: Vaccination Coverage Quality Indicators
      See http://www.biostatglobal.com/VCQI_resources.html
      
To run the simulation on faux data, run the program named:
 -- Single Run - UCLA-KSPH simulation1.do
 
To run the simulation on a person-level coverage survey dataset, run:
-- Batch Run - UCLA-KSPH simulation1.do

Contact Dale Rhoda with questions: Dale.Rhoda@biostatglobal.com

******************************************************************************
