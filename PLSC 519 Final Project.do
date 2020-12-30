****************** setup ******************
clear
set more off
import delimited "/Users/taegyoon/Documents/2018 Fall/PLSC 519 /final project/kgss2016.csv", encoding(ISO-8859-1)



****************** variables ******************

tab1 provwelf taxincre taxwelf caremed careaged carechld desirgov cnsrvtv4  cnsrvtv6 helpful fair cantrust congovt conlgovt conlegis conbluho taxautho1 taxautho2 polcorru offcorru offbribe, missing
tab1 educ sex age income satfin rank attend curgov prtyid16 vote16 partylr, missing



****************** pre-processing ******************

*** DV ***
tab provwelf, missing
replace provwelf=. if provwelf==-8
tab taxwelf, missing
replace taxwelf=. if  taxwelf==-8

*** IV ***
tab offcorru, missing
replace offcorru=. if offcorru==-8
tab congovt, missing
replace congovt=. if congovt==-8 
tab conlgovt, missing
replace conlgovt=. if conlgovt==-8

*** CV ***
tab sex, missing
tab age, missing
tab educ, missing
tab income, missing
replace income=. if income==-8
tab curgov, missing
replace curgov=. if curgov==-8
tab partylr, missing
replace partylr=. if partylr==-8



****************** descriptive statistics ******************

tab taxwelf, missing
tab cnsrvtv4, missing
tab congovt, missing
tab conlgovt, missing
tab conlegis, missing
tab polcorru, missing
tab offcorru, missing

asdoc sum taxwelf  provwelf congovt conlgovt offcorru educ sex age income partylr curgov

hist taxwelf
hist provwelf



****************** naive OLS model ******************

asdoc reg provwelf congovt educ sex age income partylr curgov, replace nest save(naive1)
asdoc reg provwelf conlgovt educ sex age income partylr curgov, nest
asdoc reg provwelf offcorru educ sex age income partylr curgov, nest 
asdoc reg taxwelf congovt educ sex age income partylr curgov, replace nest save(naive2)
asdoc reg taxwelf conlgovt educ sex age income partylr curgov, nest
asdoc reg taxwelf offcorru educ sex age income partylr curgov, nest 


****************** weight ******************

tab finalwt,missing
hist finalwt
asdoc sum finalwt, save(weight)
corr finalwt sex age urban region

svyset [pw = finalwt]
svy: mean taxwelf
svy: mean provwelf
svy: mean congovt
svy: mean conlgovt
svy: mean offcorru
svy: mean educ
svy: mean sex
svy: mean age
svy: mean income
svy: mean partylr
svy: mean curgov

asdoc svy: reg provwelf congovt educ sex age income partylr curgov, replace nest save(weightreg1)
asdoc svy: reg provwelf conlgovt educ sex age income partylr curgov, nest
asdoc svy: reg provwelf offcorru educ sex age income partylr curgov, nest
asdoc svy: reg taxwelf congovt educ sex age income partylr curgov, replace nest save(weightreg2)
asdoc svy: reg taxwelf conlgovt educ sex age income partylr curgov, nest
asdoc svy: reg taxwelf offcorru educ sex age income partylr curgov, nest
  
  
  
****************** cluster/stratification ******************

tab blockno
sum blockno
tab region blockno
svyset blockno [pweight = finalwt]

loneway taxwelf blockno [aweight = finalwt]
loneway provwelf blockno [aweight = finalwt]
loneway congovt blockno [aweight = finalwt]
loneway conlgovt blockno [aweight = finalwt]
loneway offcorru blockno [aweight = finalwt]
loneway educ blockno [aweight = finalwt]
loneway sex blockno [aweight = finalwt]
loneway age blockno [aweight = finalwt]
loneway income blockno [aweight = finalwt]
loneway partylr blockno [aweight = finalwt]
loneway curgov blockno [aweight = finalwt]

svy: mean taxwelf
svy: mean provwelf
svy: mean congovt
svy: mean conlgovt
svy: mean offcorru
svy: mean educ
svy: mean sex
svy: mean age
svy: mean income
svy: mean partylr
svy: mean curgov

asdoc svy: reg provwelf congovt educ sex age income partylr curgov, replace nest save(cluster1)
asdoc svy: reg provwelf conlgovt educ sex age income partylr curgov, nest
asdoc svy: reg provwelf offcorru educ sex age income partylr curgov, nest
asdoc svy: reg taxwelf congovt educ sex age income partylr curgov, replace nest save(cluster2)
asdoc svy: reg taxwelf conlgovt educ sex age income partylr curgov, nest
asdoc svy: reg taxwelf offcorru educ sex age income partylr curgov, nest

****************** missing data ******************

misstable sum taxwelf provwelf congovt conlgovt offcorru educ sex age income partylr curgov
misstable patterns taxwelf congovt conlgovt offcorru educ sex age income partylr curgov, frequency bypatterns

corr provwelf taxincre taxwelf caremed careaged carechld desirgov cnsrvtv4  cnsrvtv6 helpful fair cantrust congovt conlgovt conlegis conbluho taxautho1 taxautho2 polcorru offcorru offbribe educ sex age income partylr curgov

mi set flong 
mi register imputed taxwelf provwelf congovt conlgovt offcorru partylr curgov income
mi register regular educ age sex finalwt region blockno cnsrvtv4 cnsrvtv6

* mvn impute
mi impute mvn taxwelf provwelf congovt conlgovt offcorru partylr curgov income = educ age sex finalwt region blockno cnsrvtv4 cnsrvtv6, add(5) rseed(2825)
sum  _mi_id _mi_miss _mi_m
tab  _mi_m

mi estimate: reg taxwelf congovt educ sex age income partylr curgov
mi estimate: reg taxwelf conlgovt educ sex age income partylr curgov
mi estimate: reg taxwelf offcorru educ sex age income partylr curgov 
mi estimate: reg provwelf congovt educ sex age income partylr curgov
mi estimate: reg provwelf conlgovt educ sex age income partylr curgov
mi estimate: reg provwelf offcorru educ sex age income partylr curgov  

* chain impute
mi impute chained (ologit)  taxwelf provwelf congovt conlgovt offcorru partylr curgov income = educ age sex finalwt region blockno cnsrvtv4 cnsrvtv6, add(5) noisily rseed(2825)
mi estimate: reg taxwelf congovt educ sex age income partylr curgov
mi estimate: reg taxwelf conlgovt educ sex age income partylr curgov
mi estimate: reg taxwelf offcorru educ sex age income partylr curgov 
mi estimate: reg provwelf congovt educ sex age income partylr curgov
mi estimate: reg provwelf conlgovt educ sex age income partylr curgov
mi estimate: reg provwelf offcorru educ sex age income partylr curgov  


****************** Contextual Analysis ******************

tab1 vote2007 vote2012 thrmmtr1  thrmmtr2 thrmmtr3 thrmmtr4 thrmmtr5 thrmmtr6 thrmmtr7, missing
codebook thrmmtr1
replace thrmmtr1=. if thrmmtr1==-8
gen polarization=thrmmtr1
replace polarization=10 if polarization==1
replace polarization=10 if polarization==5
replace polarization=9 if polarization==2
replace polarization=9 if polarization==4
replace polarization=8 if polarization==3
gen polar= polarization-7
tab polar
loneway polar blockno [aweight=finalwt]

sort blockno
collapse (mean) localpolar=polar, by (blockno)
sort blockno
save block_polar_data

clear
use "naive_data.dta"
merge m:1 blockno using "block_polar_data.dta"
save merge_data
tab _merge


asdoc reg taxwelf c.congovt##c.localpolar educ sex age income partylr curgov, replace nest save(context1)
asdoc reg taxwelf c.conlgovt##c.localpolar educ sex age income partylr curgov, nest
asdoc reg taxwelf c.offcorru##c.localpolar educ sex age income partylr curgov, nest 
asdoc reg provwelf c.congovt##c.localpolar educ sex age income partylr curgov, next
asdoc reg provwelf c.conlgovt##c.localpolar educ sex age income partylr curgov, nest
asdoc reg provwelf c.offcorru##c.localpolar educ sex age income partylr curgov, nest 

svyset blockno [pweight = finalwt]
asdoc svy: reg taxwelf c.congovt##c.localpolar educ sex age income partylr curgov, replace nest save(context_svy1)
asdoc svy: reg taxwelf c.conlgovt##c.localpolar educ sex age income partylr curgov, nest
asdoc svy: reg taxwelf c.offcorru##c.localpolar educ sex age income partylr curgov, nest 
asdoc svy: reg provwelf c.congovt##c.localpolar educ sex age income partylr curgov, nest
asdoc svy: reg provwelf c.conlgovt##c.localpolar educ sex age income partylr curgov, nest
asdoc svy: reg provwelf c.offcorru##c.localpolar educ sex age income partylr curgov, nest 



