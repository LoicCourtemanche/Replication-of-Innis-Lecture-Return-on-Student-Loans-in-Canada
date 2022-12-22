

//variable, disbursement file
//edinst: institution code, in repayment file
//edinstname: institution name, in disbursement file



gen inst_cat_cslp = . //3 categories
gen inst_cat_rank_cslp = . //rank within each category

label variable inst_cat_cslp "Institution Category"
label variable inst_cat_rank_cslp "Rank within Category"

//1. primary undergraduate
replace inst_cat_cslp = 1 if edinst == "GUAF"
replace inst_cat_cslp = 1 if edinst == "AUAG"
replace inst_cat_cslp = 1 if edinst == "EUAW"
replace inst_cat_cslp = 1 if edinst == "HUAA"
replace inst_cat_cslp = 1 if edinst == "BUAD"
replace inst_cat_cslp = 1 if edinst == "HUAG"
replace inst_cat_cslp = 1 if edinst == "HUAH"
replace inst_cat_cslp = 1 if edinst == "FUAA"
replace inst_cat_cslp = 1 if edinst == "EUAL"
replace inst_cat_cslp = 1 if edinst == "EUBS"
replace inst_cat_cslp = 1 if edinst == "IUAA"
replace inst_cat_cslp = 1 if edinst == "EUAM"
replace inst_cat_cslp = 1 if edinst == "GUAA"
replace inst_cat_cslp = 1 if edinst == "GUAB"|edinst=="GUAE"
replace inst_cat_cslp = 1 if edinst == "DUAD"
replace inst_cat_cslp = 1 if edinst == "EUBC"
replace inst_cat_cslp = 1 if edinst == "HUAD"
replace inst_cat_cslp = 1 if edinst == "DUAA"
replace inst_cat_cslp = 1 if edinst == "HUAJ"

replace inst_cat_rank_cslp = 1 if edinst == "GUAF"
replace inst_cat_rank_cslp = 2 if edinst == "AUAG"
replace inst_cat_rank_cslp = 3 if edinst == "EUAW"
replace inst_cat_rank_cslp = 4 if edinst == "HUAA"
replace inst_cat_rank_cslp = 5 if edinst == "BUAD"
replace inst_cat_rank_cslp = 6 if edinst == "HUAG"
replace inst_cat_rank_cslp = 6 if edinst == "HUAH"
replace inst_cat_rank_cslp = 8 if edinst == "FUAA"
replace inst_cat_rank_cslp = 8 if edinst == "EUAL"
replace inst_cat_rank_cslp = 10 if edinst == "EUBS"
replace inst_cat_rank_cslp = 11 if edinst == "IUAA"
replace inst_cat_rank_cslp = 12 if edinst == "EUAM"
replace inst_cat_rank_cslp = 13 if edinst == "GUAA"
replace inst_cat_rank_cslp = 14 if edinst == "GUAB"|edinst=="GUAE"
replace inst_cat_rank_cslp = 15 if edinst == "DUAD"
replace inst_cat_rank_cslp = 16 if edinst == "EUBC"
replace inst_cat_rank_cslp = 17 if edinst == "HUAD"
replace inst_cat_rank_cslp = 18 if edinst == "DUAA"
replace inst_cat_rank_cslp = 18 if edinst == "HUAJ"



//2. comprehensive
replace inst_cat_cslp = 2 if edinst == "AUAE"
replace inst_cat_cslp = 2 if edinst == "AUAF"
replace inst_cat_cslp = 2 if edinst == "EUAX"
replace inst_cat_cslp = 2 if edinst == "EUAK"
replace inst_cat_cslp = 2 if edinst == "EUAE"
replace inst_cat_cslp = 2 if edinst == "EUAZ"
replace inst_cat_cslp = 2 if edinst == "EUBB"
replace inst_cat_cslp = 2 if edinst == "JUAA"|edinst == "JUAB"
replace inst_cat_cslp = 2 if edinst == "GUAG"|edinst == "GUAH"
replace inst_cat_cslp = 2 if edinst == "FUAC"
replace inst_cat_cslp = 2 if edinst == "FUAG"
replace inst_cat_cslp = 2 if edinst == "EUBF"
replace inst_cat_cslp = 2 if edinst == "EUBA"
replace inst_cat_cslp = 2 if edinst == "EUBD"
replace inst_cat_cslp = 2 if edinst == "CUAB"

replace inst_cat_rank_cslp = 1 if edinst == "AUAE"
replace inst_cat_rank_cslp = 2 if edinst == "AUAF"
replace inst_cat_rank_cslp = 3 if edinst == "EUAX"
replace inst_cat_rank_cslp = 4 if edinst == "EUAK"
replace inst_cat_rank_cslp = 5 if edinst == "EUAE"
replace inst_cat_rank_cslp = 6 if edinst == "EUAZ"
replace inst_cat_rank_cslp = 7 if edinst == "EUBB"
replace inst_cat_rank_cslp = 8 if edinst == "JUAA"|edinst == "JUAB"
replace inst_cat_rank_cslp = 8 if edinst == "GUAG"|edinst == "GUAH"
replace inst_cat_rank_cslp = 10 if edinst == "FUAC"
replace inst_cat_rank_cslp = 11 if edinst == "FUAG"
replace inst_cat_rank_cslp = 11 if edinst == "EUBF"
replace inst_cat_rank_cslp = 13 if edinst == "EUBA"
replace inst_cat_rank_cslp = 14 if edinst == "EUBD"
replace inst_cat_rank_cslp = 14 if edinst == "CUAB"




//3. medical doctoral
replace inst_cat_cslp = 3 if edinst == "FUAN"|edinst == "FUAV"
replace inst_cat_cslp = 3 if edinst == "EUAV"
replace inst_cat_cslp = 3 if edinst == "AUAA"
replace inst_cat_cslp = 3 if edinst == "EUAN"
replace inst_cat_cslp = 3 if edinst == "BUAA"
replace inst_cat_cslp = 3 if edinst == "EUAP"
replace inst_cat_cslp = 3 if edinst == "EUAY"
replace inst_cat_cslp = 3 if edinst == "HUAB"
replace inst_cat_cslp = 3 if edinst == "BUAC"
replace inst_cat_cslp = 3 if edinst == "FUAD"
replace inst_cat_cslp = 3 if edinst == "EUAO"
replace inst_cat_cslp = 3 if edinst == "FUAU"
replace inst_cat_cslp = 3 if edinst == "FUAL"
replace inst_cat_cslp = 3 if edinst == "DUAB"
replace inst_cat_cslp = 3 if edinst == "CUAC"

replace inst_cat_rank_cslp = 1 if edinst == "FUAN"|edinst == "FUAV"
replace inst_cat_rank_cslp = 2 if edinst == "EUAV"
replace inst_cat_rank_cslp = 3 if edinst == "AUAA"
replace inst_cat_rank_cslp = 4 if edinst == "EUAN"
replace inst_cat_rank_cslp = 5 if edinst == "BUAA"
replace inst_cat_rank_cslp = 5 if edinst == "EUAP"
replace inst_cat_rank_cslp = 7 if edinst == "EUAY"
replace inst_cat_rank_cslp = 8 if edinst == "HUAB"
replace inst_cat_rank_cslp = 9 if edinst == "BUAC"
replace inst_cat_rank_cslp = 10 if edinst == "FUAD"
replace inst_cat_rank_cslp = 11 if edinst == "EUAO"
replace inst_cat_rank_cslp = 12 if edinst == "FUAU"
replace inst_cat_rank_cslp = 13 if edinst == "FUAL"
replace inst_cat_rank_cslp = 14 if edinst == "DUAB"
replace inst_cat_rank_cslp = 15 if edinst == "CUAC"

//insitution category
label define inst_cat_cslp 1 "Primarily Undergraduate" 2 "Comprehensive" 3 "Medical Doctoral"
label values inst_cat_cslp inst_cat_cslp

//rank by reputation, 2020, 49 in total
gen inst_cslp = .

label variable inst_cslp "Undergrad Institution"

replace inst_cslp = 1 if edinst == "EUAV"
replace inst_cslp = 2 if edinst == "EUAX"
replace inst_cslp = 3 if edinst == "AUAA"
replace inst_cslp = 4 if edinst == "FUAN"|edinst == "FUAV"
replace inst_cslp = 5 if edinst == "EUAN"
replace inst_cslp = 6 if edinst == "BUAA"
replace inst_cslp = 7 if edinst == "EUAP"
replace inst_cslp = 8 if edinst == "EUAY"
replace inst_cslp = 9 if edinst == "AUAE"
replace inst_cslp = 10 if edinst == "FUAD"
replace inst_cslp = 11 if edinst == "BUAC"
replace inst_cslp = 12 if edinst == "EUAK"
replace inst_cslp = 13 if edinst == "AUAF"
replace inst_cslp = 14 if edinst == "HUAB"
replace inst_cslp = 15 if edinst == "FUAU"
replace inst_cslp = 16 if edinst == "EUBF"
replace inst_cslp = 17 if edinst == "FUAC"
replace inst_cslp = 18 if edinst == "EUAO"
replace inst_cslp = 19 if edinst == "FUAL"
replace inst_cslp = 20 if edinst == "CUAC"
replace inst_cslp = 21 if edinst == "EUBB"
replace inst_cslp = 22 if edinst == "JUAA"|edinst == "JUAB"
replace inst_cslp = 23 if edinst == "DUAB"
replace inst_cslp = 24 if edinst == "EUAE"
replace inst_cslp = 25 if edinst == "EUAZ"
replace inst_cslp = 26 if edinst == "FUAG"
replace inst_cslp = 27 if edinst == "GUAF"
replace inst_cslp = 28 if edinst == "HUAG"
replace inst_cslp = 29 if edinst == "HUAA"
replace inst_cslp = 30 if edinst == "EUAW"
replace inst_cslp = 31 if edinst == "GUAG"|edinst == "GUAH"
replace inst_cslp = 32 if edinst == "EUBS"
replace inst_cslp = 33 if edinst == "CUAB"
replace inst_cslp = 34 if edinst == "AUAG"
replace inst_cslp = 35 if edinst == "BUAD"
replace inst_cslp = 36 if edinst == "HUAH"
replace inst_cslp = 37 if edinst == "DUAD"
replace inst_cslp = 38 if edinst == "EUBD"
replace inst_cslp = 39 if edinst == "FUAA"
replace inst_cslp = 40 if edinst == "EUBA"
replace inst_cslp = 41 if edinst == "IUAA"
replace inst_cslp = 42 if edinst == "EUAL"
replace inst_cslp = 43 if edinst == "HUAD"
replace inst_cslp = 44 if edinst == "GUAB"|edinst=="GUAE"
replace inst_cslp = 45 if edinst == "EUAM"
replace inst_cslp = 46 if edinst == "HUAJ"
replace inst_cslp = 47 if edinst == "GUAA"
replace inst_cslp = 48 if edinst == "DUAA"
replace inst_cslp = 49 if edinst == "EUBC"
replace inst_cslp = 50 if inst_cslp == . & insttype=="C"
replace inst_cslp = 51 if inst_cslp == . & insttype=="U"




//label
#delimit ;
label define inst_cslp
1 "University of Toronto"
2 "University of Waterloo"
3 "University of British Columbia"
4 "McGill University"
5 "McMaster University"
6 "University of Alberta"
7 "Queen's University"
8 "University of Western Ontario"
9 "Simon Fraser University"
10 "Université de Montréal"
11 "University of Calgary"
12 "University of Guelph"
13 "University of Victoria"
14 "Dalhousie University"
15 "Université Laval"
16 "Ryerson University"
17 "Concordia University"
18 "University of Ottawa"
19 "Université de Sherbrooke"
20 "University of Saskatchewan"
21 "York University"
22 "Memorial University of Newfoundland"
23 "University of Manitoba"
24 "Carleton University"
25 "Wilfrid Laurier University"
26 "Université du Québec à Montréal"
27 "Mount Allison University"
28 "St. Francis Xavier University"
29 "Acadia University"
30 "Trent University"
31 "University of New Brunswick"
32 "University of Ontario Institute of Technology"
33 "University of Regina"
34 "University of Northern British Columbia"
35 "University of Lethbridge"
36 "Saint Mary's University"
37 "University of Winnipeg"
38 "Brock University"
39 "Bishop's University"
40 "University of Windsor"
41 "University of Prince Edward Island"
42 "Lakehead University"
43 "Mount St. Vincent University"
44 "Université de Moncton"
45 "Laurentian University"
46 "Cape Breton University"
47 "St. Thomas University"
48 "Brandon University"
49 "Nipissing University"
50 "Other Unranked Colleges"
51 "Other Unranked Universities";
#delimit cr

label values inst_cslp inst_cslp





//institution rank group
recode inst_cslp (1/10=1) (11/20=2) (21/30=3) (31/40=4) (41/49=5)(50=6)(51=7), gen(inst_rank_group10)
label define inst_rank_group10 1 "rank 1-10" 2 "rank 11-20" 3 "rank 21-30" 4 "rank 31-40" 5 "rank 41-49" 6 "Other Unranked Colleges" 7 "Other Unranked Universities"
label values inst_rank_group10 inst_rank_group10

label variable inst_rank_group10 "Institution Rank (group of 10)"

recode inst_cslp (1/5=1) (6/10=2)(11/15=3)(16/20=4)(21/25=5)(26/30=6)(31/35=7)(36/40=8)(41/45=9)(46/49=10)(50=11)(51=12), gen(inst_rank_group5)
label define inst_rank_group5 1 "rank 1-5" 2 "rank 6-10" 3 "rank 11-15" 4 "rank 16-20" 5 "rank 21-25" 6 "rank 26-30" ///
	7 "rank 31-35" 8 "rank 36-40" 9 "rank 41-45" 10 "rank 46-49" 11 "Other Unranked Colleges" 12 "Other Unranked Universities"
label values inst_rank_group5 inst_rank_group5

label variable inst_rank_group5 "Institution Rank (group of 5)"




//group 4 French speaking schools together


gen inst_cslp_new = inst_cslp

label variable inst_cslp_new "Undergrad Institution"

replace inst_cslp_new = 10 if inst_cslp_new==15|inst_cslp_new==19|inst_cslp_new==26




//label
#delimit ;
label define inst_cslp_new
1 "University of Toronto"
2 "University of Waterloo"
3 "University of British Columbia"
4 "McGill University"
5 "McMaster University"
6 "University of Alberta"
7 "Queen's University"
8 "University of Western Ontario"
9 "Simon Fraser University"
10 "Montreal/Laval/Sherbrooke/UQAM"
11 "University of Calgary"
12 "University of Guelph"
13 "University of Victoria"
14 "Dalhousie University"
16 "Ryerson University"
17 "Concordia University"
18 "University of Ottawa"
20 "University of Saskatchewan"
21 "York University"
22 "Memorial University of Newfoundland"
23 "University of Manitoba"
24 "Carleton University"
25 "Wilfrid Laurier University"
27 "Mount Allison University"
28 "St. Francis Xavier University"
29 "Acadia University"
30 "Trent University"
31 "University of New Brunswick"
32 "University of Ontario Institute of Technology"
33 "University of Regina"
34 "University of Northern British Columbia"
35 "University of Lethbridge"
36 "Saint Mary's University"
37 "University of Winnipeg"
38 "Brock University"
39 "Bishop's University"
40 "University of Windsor"
41 "University of Prince Edward Island"
42 "Lakehead University"
43 "Mount St. Vincent University"
44 "Université de Moncton"
45 "Laurentian University"
46 "Cape Breton University"
47 "St. Thomas University"
48 "Brandon University"
49 "Nipissing University"
50 "Other Unranked Colleges"
51 "Other Unranked Universities";
#delimit cr

label values inst_cslp_new inst_cslp_new







