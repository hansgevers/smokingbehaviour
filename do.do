/*
Stata code supporting paper "The Influence of Cigarettes Smoking and Behaviour on Health: A Pooled Analysis of 32 Countries from the European Social Survey 2014 and 2023"
Author: Hans Gevers - Junior Research Fellow at the Estonian Business School
https://orcid.org/0009-0001-0249-4142 hans.gevers@ebs.ee
*/

clear all
use "C:\Users\hansg\Documents\bestanden\PhD ebs\JRF work Stata\ESS 2\process\ESS11e04_1.dta"
log using output.smcl, replace name("HealthBehaviour")

codebook etfruit eatveg dosprt cgtsmok alcfreq hlpfmly hltprhc hltprhb hltprbp hltpral hltprbn hltprpa hltprpf hltprsd hltprsc hltprsh hltprdi fltsd fltlnl fltdpr fnsdfml gndr agea maritalb eduyrs pdwrk iphlppla pspwght stflife health hlthhmp cntry, compact

codebook hltprhc hltprhb hltprbp hltpral hltprbn hltprpa hltprpf hltprsd hltprsc hltprsh hltprdi

egen healthproblems=rowtotal(hltprhc hltprhb hltprbp hltpral hltprbn hltprpa hltprpf hltprsd hltprsc hltprsh hltprdi)
drop hltprhc hltprhb hltprbp hltpral hltprbn hltprpa hltprpf hltprsd hltprsc hltprsh hltprdi
keep etfruit eatveg dosprt cgtsmok alcfreq hlpfmly healthproblems fltsd fltlnl fltdpr fnsdfml gndr agea maritalb eduyrs pdwrk iphlppla pspwght stflife health hlthhmp cntry

generate smoke=5
replace smoke=1 if cgtsmok==1 | cgtsmok==2
replace smoke=2 if cgtsmok==3
replace smoke=3 if cgtsmok==4
replace smoke=4 if cgtsmok==5
label define smL 1 "I smoke daily" 2 "I smoke but not every day" 3 "I don't smoke now but I used to" 4 "I have only smoked a few times" 5 "I have never smoked"
label values smoke smL
drop cgtsmok
rename smoke cgtsmke
rename iphlppla iphlppl
generate year=2023
save "C:\Users\hansg\Documents\bestanden\PhD ebs\JRF work Stata\ESS 2\ESS11.dta", replace

clear all
use "C:\Users\hansg\Documents\bestanden\PhD ebs\JRF work Stata\ESS 2\process\ESS7e02_3"

codebook etfruit eatveg dosprt cgtsmke alcfreq hlpfmly hltprhc hltprhb hltprbp hltpral hltprbn hltprpa hltprpf hltprsd hltprsc hltprsh hltprdi fltsd fltlnl fltdpr fnsdfml gndr agea maritalb eduyrs pdwrk iphlppl pspwght stflife health hlthhmp cntry, compact
egen healthproblems=rowtotal(hltprhc hltprhb hltprbp hltpral hltprbn hltprpa hltprpf hltprsd hltprsc hltprsh hltprdi)
drop hltprhc hltprhb hltprbp hltpral hltprbn hltprpa hltprpf hltprsd hltprsc hltprsh hltprdi

keep etfruit eatveg dosprt cgtsmke alcfreq hlpfmly healthproblems fltsd fltlnl fltdpr fnsdfml gndr agea maritalb eduyrs pdwrk iphlppl pspwght stflife health hlthhmp cntry
generate year=2014

append using "ESS11.dta"

cd "C:\Users\hansg\Documents\bestanden\PhD ebs\JRF work Stata\ESS 2"
save "dataset.dta", replace

encode cntry, generate(country)
drop cntry

drop if agea>90 | agea<15

asdoc codebook etfruit eatveg dosprt cgtsmke alcfreq hlpfmly healthproblems fltsd fltlnl fltdpr fnsdfml gndr agea maritalb eduyrs pdwrk iphlppl pspwght stflife health hlthhmp country year, compact save(report.doc) replace

codebook

graph bar (count), over(year, label(angle(90) labsize(tiny))) over(country, label(angle(90) labsize(small))) scheme(s2color) ytitle("Number of respondents", margin(small)) ylabel(0(500)3000,angle(0) labsize(small) grid) yline(1000) nofill
graph export cntry.svg, replace height(2400)

graph bar (count) if year==2014, over(age, label(angle(90) labsize(tiny))) over(year, label(labsize(small))) scheme(s2color) ytitle("Number of respondents", margin(small)) ylabel(0(100)700,angle(0) labsize(small) grid) yline(500) nofill
graph export age14.svg, replace height(2400) width (4800)
graph bar (count) if year==2023, over(age, label(angle(90) labsize(tiny))) over(year, label(labsize(small))) scheme(s2color) ytitle("Number of respondents", margin(small)) ylabel(0(100)1000,angle(0) labsize(small) grid) yline(500) nofill
graph export age23.svg, replace height(2400) width (4800)

asdoc spearman etfruit eatveg dosprt, append save(report.doc)
asdoc spearman healthproblems hlpfmly iphlppl, append save(report.doc)
asdoc spearman fltsd fltlnl fltdpr stflife, append save(report.doc)
asdoc spearman healthproblems health hlthhmp, append save(report.doc)

asdoc spearman health hlthhmp cgtsmke eatveg etfruit dosprt alcfreq hlpfmly healthproblems fltsd fltlnl fltdpr fnsdfml gndr agea maritalb eduyrs pdwrk iphlppl stflife country year, star(.05) append save(report.doc)

**HEALTH

*OLOGIT
ologit health i.cgtsmke ib(2).hlpfmly ib(2).gndr c.agea i.maritalb c.eduyrs i.pdwrk c.iphlppl
outreg2 using results_olog.xls, excel replace dec(3) alpha(0.001, 0.01, 0.05) symbol(***, **, *) ctitle("Core") stnum(replace coef=exp(coef), replace se=coef*se)
asdoc estat parallel, save(oddsass.doc) append

ologit health i.cgtsmke i.cgtsmke##ib(2).hlpfmly i.cgtsmke##ib(2).gndr c.agea i.maritalb c.eduyrs i.pdwrk i.cgtsmke##c.iphlppl
outreg2 using results_olog.xls, excel append dec(3) alpha(0.001, 0.01, 0.05) symbol(***, **, *) ctitle("Base") stnum(replace coef=exp(coef), replace se=coef*se)

ologit health i.cgtsmke i.cgtsmke##ib(2).hlpfmly i.cgtsmke##c.healthproblems i.cgtsmke##ib(2).gndr c.agea i.maritalb c.eduyrs i.pdwrk i.cgtsmke##c.iphlppl c.stflife
outreg2 using results_olog.xls, excel append dec(3) alpha(0.001, 0.01, 0.05) symbol(***, **, *) ctitle("Reduc") stnum(replace coef=exp(coef), replace se=coef*se)

ologit health i.cgtsmke i.cgtsmke##c.eatveg i.cgtsmke##c.etfruit i.cgtsmke##c.dosprt c.alcfreq i.cgtsmke##ib(2).hlpfmly i.cgtsmke##c.healthproblems i.cgtsmke##c.fltsd i.cgtsmke##c.fltlnl i.cgtsmke##c.fltdpr c.fnsdfml i.cgtsmke##ib(2).gndr c.agea i.maritalb c.eduyrs i.pdwrk i.cgtsmke##c.iphlppl c.stflife
outreg2 using results_olog.xls, excel append dec(3) alpha(0.001, 0.01, 0.05) symbol(***, **, *) ctitle("Full") stnum(replace coef=exp(coef), replace se=coef*se)

ologit health i.cgtsmke i.cgtsmke##c.eatveg i.cgtsmke##c.etfruit i.cgtsmke##c.dosprt c.alcfreq i.cgtsmke##ib(2).hlpfmly i.cgtsmke##c.healthproblems i.cgtsmke##c.fltsd i.cgtsmke##c.fltlnl i.cgtsmke##c.fltdpr c.fnsdfml i.cgtsmke##ib(2).gndr c.agea i.maritalb c.eduyrs i.pdwrk i.cgtsmke##c.iphlppl c.stflife i.country i.year [pweight=pspwght]
outreg2 using results_olog.xls, excel append dec(3) alpha(0.001, 0.01, 0.05) symbol(***, **, *) ctitle("Full Macro") stnum(replace coef=exp(coef), replace se=coef*se)

ologit health i.cgtsmke i.cgtsmke##c.eatveg i.cgtsmke##c.etfruit i.cgtsmke##c.dosprt c.alcfreq i.cgtsmke##i.hlthhmp i.cgtsmke##ib(2).hlpfmly i.cgtsmke##c.healthproblems i.cgtsmke##c.fltsd i.cgtsmke##c.fltlnl i.cgtsmke##c.fltdpr c.fnsdfml i.cgtsmke##ib(2).gndr c.agea i.maritalb c.eduyrs i.pdwrk i.cgtsmke##c.iphlppl c.stflife i.country i.year [pweight=pspwght]
outreg2 using results_olog.xls, excel append dec(3) alpha(0.001, 0.01, 0.05) symbol(***, **, *) ctitle("Full Macro2") stnum(replace coef=exp(coef), replace se=coef*se)

*SLOGIT
slogit health i.cgtsmke ib(2).hlpfmly ib(2).gndr c.agea i.maritalb c.eduyrs i.pdwrk c.iphlppl [pweight=pspwght]
outreg2 using results_slog.xls, excel replace dec(3) alpha(0.001, 0.01, 0.05) symbol(***, **, *) ctitle("Core") stnum(replace coef=exp(coef), replace se=coef*se)

slogit health i.cgtsmke i.cgtsmke##ib(2).hlpfmly i.cgtsmke##ib(2).gndr c.agea i.maritalb c.eduyrs i.pdwrk i.cgtsmke##c.iphlppl [pweight=pspwght]
outreg2 using results_slog.xls, excel append dec(3) alpha(0.001, 0.01, 0.05) symbol(***, **, *) ctitle("Base") stnum(replace coef=exp(coef), replace se=coef*se)

slogit health i.cgtsmke i.cgtsmke##ib(2).hlpfmly i.cgtsmke##c.healthproblems i.cgtsmke##ib(2).gndr c.agea i.maritalb c.eduyrs i.pdwrk i.cgtsmke##c.iphlppl c.stflife [pweight=pspwght]
outreg2 using results_slog.xls, excel append dec(3) alpha(0.001, 0.01, 0.05) symbol(***, **, *) ctitle("Reduc") stnum(replace coef=exp(coef), replace se=coef*se)

slogit health i.cgtsmke i.cgtsmke##c.eatveg i.cgtsmke##c.etfruit i.cgtsmke##c.dosprt c.alcfreq i.cgtsmke##ib(2).hlpfmly i.cgtsmke##c.healthproblems i.cgtsmke##c.fltsd i.cgtsmke##c.fltlnl i.cgtsmke##c.fltdpr c.fnsdfml i.cgtsmke##ib(2).gndr c.agea i.maritalb c.eduyrs i.pdwrk i.cgtsmke##c.iphlppl c.stflife [pweight=pspwght]
outreg2 using results_slog.xls, excel append dec(3) alpha(0.001, 0.01, 0.05) symbol(***, **, *) ctitle("Full") stnum(replace coef=exp(coef), replace se=coef*se)

slogit health i.cgtsmke i.cgtsmke##c.eatveg i.cgtsmke##c.etfruit i.cgtsmke##c.dosprt c.alcfreq i.cgtsmke##ib(2).hlpfmly i.cgtsmke##c.healthproblems i.cgtsmke##c.fltsd i.cgtsmke##c.fltlnl i.cgtsmke##c.fltdpr c.fnsdfml i.cgtsmke##ib(2).gndr c.agea i.maritalb c.eduyrs i.pdwrk i.cgtsmke##c.iphlppl c.stflife i.country i.year [pweight=pspwght]
outreg2 using results_slog.xls, excel append dec(3) alpha(0.001, 0.01, 0.05) symbol(***, **, *) ctitle("Full Macro") stnum(replace coef=exp(coef), replace se=coef*se)

slogit health i.cgtsmke i.cgtsmke##c.eatveg i.cgtsmke##c.etfruit i.cgtsmke##c.dosprt c.alcfreq i.cgtsmke##i.hlthhmp i.cgtsmke##ib(2).hlpfmly i.cgtsmke##c.healthproblems i.cgtsmke##c.fltsd i.cgtsmke##c.fltlnl i.cgtsmke##c.fltdpr c.fnsdfml i.cgtsmke##ib(2).gndr c.agea i.maritalb c.eduyrs i.pdwrk i.cgtsmke##c.iphlppl c.stflife i.country i.year [pweight=pspwght]
outreg2 using results_slog.xls, excel append dec(3) alpha(0.001, 0.01, 0.05) symbol(***, **, *) ctitle("Full Macro2") stnum(replace coef=exp(coef), replace se=coef*se)

margins cgtsmke#hlpfmly
marginsplot, legend(lastlabel(1 "Yes, Very good") lastlabel(2 "Yes, Good") lastlabel(3 "Yes, Fair") lastlabel(4 "Yes, Bad") lastlabel(5 "Yes, Very bad") lastlabel(6 "No, Very good") lastlabel(7 "No, Good") lastlabel(8 "No, Fair") lastlabel(9 "No, Bad") lastlabel(10 "No, Very bad")) title("") xlabel(, angle(-45)) xtitle("") ytitle("")
graph export marginsplot_Helping.svg, as(svg) width(1600) height(1200)

slogit health i.cgtsmke i.cgtsmke##c.eatveg i.cgtsmke##c.etfruit i.cgtsmke##c.dosprt c.alcfreq i.cgtsmke##ib(2).hlpfmly i.cgtsmke##c.healthproblems i.cgtsmke##c.fltsd i.cgtsmke##c.fltlnl i.cgtsmke##c.fltdpr c.fnsdfml i.cgtsmke##ib(2).gndr c.agea i.maritalb c.eduyrs i.pdwrk i.cgtsmke##c.iphlppl c.stflife i.country i.year [pweight=pspwght] if year==2014
outreg2 using results_slog.xls, excel append dec(3) alpha(0.001, 0.01, 0.05) symbol(***, **, *) ctitle("Full Macro 14") stnum(replace coef=exp(coef), replace se=coef*se)

slogit health i.cgtsmke i.cgtsmke##c.eatveg i.cgtsmke##c.etfruit i.cgtsmke##c.dosprt c.alcfreq i.cgtsmke##ib(2).hlpfmly i.cgtsmke##c.healthproblems i.cgtsmke##c.fltsd i.cgtsmke##c.fltlnl i.cgtsmke##c.fltdpr c.fnsdfml i.cgtsmke##ib(2).gndr c.agea i.maritalb c.eduyrs i.pdwrk i.cgtsmke##c.iphlppl c.stflife i.country i.year [pweight=pspwght] if year==2023
outreg2 using results_slog.xls, excel append dec(3) alpha(0.001, 0.01, 0.05) symbol(***, **, *) ctitle("Full Macro 23") stnum(replace coef=exp(coef), replace se=coef*se)

log close HealthBehaviour
translate output.smcl output.pdf