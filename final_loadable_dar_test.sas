
options fmtsearch=(views work ct_org);
DATA _null_;
*  set default;
   WINDOW usergroups IROW=1 ICOLUMN=1 ROWS=40 COLUMNS=200
    GROUP=WN1
     #03 @05 '********************************'
     #04 @05 '**   Input  User information  **'
     #05 @05 '********************************'
     #06 @05 'Please input'
     #08 @06 'USERID(CT4)      =>' @25 id_CT    $20.   attr=REV_VIDEO
    ;



    DISPLAY usergroups.WN1 ;
      call symput('user',   upcase(trimn(id_CT)));
          STOP ;
RUN ;

/*proc datasets lib=work kill;quit; run;*/
libname ct_org "&user\CFTY720D/CFTY720D2306/EDC_Migration/CT4_data"; run;
libname views "&user\CFTY720D/CFTY720D2306/EDC_Migration/Loadable_output\views"; run;

/*CROSSED PROGRAM STARTS*/
options fmtsearch=(ct_org views work );

proc datasets lib=views kill;quit; run;
proc copy in=ct_org out=views;
run;


proc format LIBRARY=VIEWS;
value cross 
1='Yes'
0='No';
run;

proc format LIBRARY=VIEWS;
value crossed 
0='Yes'
1='No';
run;


data views.dar;
set views.dar;
format darlst1c crossed.;
run;

/*CROSSED PROGRAM ENDS*/

libname views "&user\CFTY720D/CFTY720D2306/EDC_Migration/Loadable_output\views"; run;
libname sasdata "&user\CFTY720D/CFTY720D2306/EDC_Migration/Loadable_output"; run;
libname newdata "&user\CFTY720D/CFTY720D2306/EDC_Migration/Loadable_output";
libname tran "&user\CFTY720D/CFTY720D2306/EDC_Migration/Loadable_output";

options ls=180 ps=40 mlogic mprint symbolgen ;
/*%let headvars=STUDY USUBJID SITEID SUBJECT VISIT VISITNUM REPEATSN QUALIFYV SUBSETSN;*/
%let sortvars=patient CLI_PLAN_EVE_NAME repeat;
* gethead macro to assign vars always present;
%macro gethead(dset);
   data ct4_&dset;
    set views.&dset;
  run;
      * SORT AS YOU THINK SUITABLE  this sort is so that repeating question groups can merge; 
  proc sort data=ct4_&dset;by SID1A VISNAM1A ;run;
%mend;

/*dar*/

%gethead(dar);
data dar1;
keep patient;
keep cli_plan_eve_name;
keep dci_name;
keep dcm_name;
keep dcm_subset_name;
keep dcm_question_grp_name;
keep subevent_number;
keep repeat;
keep qualifying_value;
keep study;
keep rec_n;
keep dtarep1c;
set ct4_dar;
patient=trim(left(put(sid1a,10.)));
cli_plan_eve_name=trim(left(put(visnam1a,20.)));
dci_name='DOSAGE ADMINISTRATION1';
dcm_name='DAR';
dcm_subset_name='DAR3';
dcm_question_grp_name='GLSTDNR';
subevent_number=0;
repeat=1;
qualifying_value='DARM005_625_1';
study='CFTY720D2306';
rec_n=1;
dtarep1c=trim(left(put(dtarep1c,17.)));
where pag1a eq "DAR" and DTAREP1C ne .;
proc sort data= dar1;by patient CLI_PLAN_EVE_NAME Subevent_Number DCI_NAME dcm_name dcm_subset_name dcm_question_grp_name rec_n qualifying_value study;run;data dar1;set dar1;by patient CLI_PLAN_EVE_NAME DCI_NAME ;if repeat=0 then do;                       
 if first.patient and first.CLI_PLAN_EVE_NAME then repeat_sn=0;repeat_sn+1;end;if repeat=1 then do;repeat_sn=1;if first.CLI_PLAN_EVE_NAME;end;run;proc transpose data=dar1 out=tran_dar1;
by patient CLI_PLAN_EVE_NAME Subevent_Number DCI_NAME dcm_name dcm_subset_name dcm_question_grp_name repeat_sn qualifying_value study;var _all_;run;data tran_dar1;length dcm_subset_name $8;set tran_dar1;_NAME_=upcase(_NAME_);
data dar1(drop=variable dataset);set newdata.formats;length _name_ $21 dcm_subset_name $8;if dataset='DAR1';_name_=variable ;run;
proc sort data=dar1;by dcm_subset_name _name_;run;proc sort data=tran_dar1 out=dar1_data;by dcm_subset_name _name_;run;
data occ_dar1;merge dar1_data dar1;by dcm_subset_name _name_;run;proc sort data=occ_dar1;
by patient CLI_PLAN_EVE_NAME Subevent_Number DCI_NAME dcm_name dcm_subset_name dcm_question_grp_name _name_ dcm_que_occ_sn repeat_sn ;run;
data tran.dar1;retain patient CLI_PLAN_EVE_NAME Subevent_Number DCI_NAME dcm_name dcm_subset_name  dcm_question_grp_name  dcm_question_name dcm_que_occ_sn repeat_sn value_text qualifying_value study;
keep patient CLI_PLAN_EVE_NAME Subevent_Number DCI_NAME dcm_name dcm_subset_name  dcm_question_grp_name  dcm_question_name dcm_que_occ_sn repeat_sn value_text qualifying_value study;
length dci_name dcm_question_grp_name $30 value_text $500 qualifying_value $30; set occ_dar1(rename=(_name_=dcm_question_name col1=value_text));
if dcm_question_name in('PATIENT','CLI_PLAN_EVE_NAME','SUBEVENT_NUMBER','DCI_NAME','DCM_NAME','DCM_SUBSET_NAME','DCM_QUESTION_GRP_NAME', 'DCM_QUE_OCC_SN','REPEAT','REPEAT_SN','REC_N','QUALIFYING_VALUE','STUDY') then delete;run;
%gethead(dar);
data dar2;
keep patient;
keep cli_plan_eve_name;
keep dci_name;
keep dcm_name;
keep dcm_subset_name;
keep dcm_question_grp_name;
keep subevent_number;
keep repeat;
keep qualifying_value;
keep study;
keep rec_n;
keep captak1n;
keep rsndos1c;
keep day1;
keep month1;
keep year1;
keep day2;
keep month2;
keep year2;
format captak1n 4.;
set ct4_dar;
patient=trim(left(put(sid1a,10.)));
cli_plan_eve_name=trim(left(put(visnam1a,20.)));
dci_name='DOSAGE ADMINISTRATION1';
dcm_name='DAR';
dcm_subset_name='DAR3';
dcm_question_grp_name='DARR';
subevent_number=0;
repeat=0;
qualifying_value='DARM005_625_1';
study='CFTY720D2306';
rec_n=rec1n;
captak1n=trim(left(put(captak1n,4.)));
rsndos1c=trim(left(put(rsndos1c,32.)));
day1=substr(SMDSTT1D,1,2);
month1=substr(SMDSTT1D,3,3);
year1=substr(SMDSTT1D,6,4);
day2=substr(SMDEND1D,1,2);
month2=substr(SMDEND1D,3,3);
year2=substr(SMDEND1D,6,4);
where pag1a eq "DAR" and DTAREP1C ne .;

proc sort data= dar2;by patient CLI_PLAN_EVE_NAME Subevent_Number DCI_NAME dcm_name dcm_subset_name dcm_question_grp_name rec_n qualifying_value study;run;data dar2;set dar2;by patient CLI_PLAN_EVE_NAME DCI_NAME ;if repeat=0 then do;                       
 if first.patient and first.CLI_PLAN_EVE_NAME then repeat_sn=0;repeat_sn+1;end;if repeat=1 then do;repeat_sn=1;if first.CLI_PLAN_EVE_NAME;end;run;proc transpose data=dar2 out=tran_dar2;
by patient CLI_PLAN_EVE_NAME Subevent_Number DCI_NAME dcm_name dcm_subset_name dcm_question_grp_name repeat_sn qualifying_value study;var _all_;run;data tran_dar2;length dcm_subset_name $8;set tran_dar2;_NAME_=upcase(_NAME_);
data dar2(drop=variable dataset);set newdata.formats;length _name_ $21 dcm_subset_name $8;if dataset='DAR2';_name_=variable ;run;
proc sort data=dar2;by dcm_subset_name _name_;run;proc sort data=tran_dar2 out=dar2_data;by dcm_subset_name _name_;run;
data occ_dar2;merge dar2_data dar2;by dcm_subset_name _name_;run;proc sort data=occ_dar2;
by patient CLI_PLAN_EVE_NAME Subevent_Number DCI_NAME dcm_name dcm_subset_name dcm_question_grp_name _name_ dcm_que_occ_sn repeat_sn ;run;
data tran.dar2;retain patient CLI_PLAN_EVE_NAME Subevent_Number DCI_NAME dcm_name dcm_subset_name  dcm_question_grp_name  dcm_question_name dcm_que_occ_sn repeat_sn value_text qualifying_value study;
keep patient CLI_PLAN_EVE_NAME Subevent_Number DCI_NAME dcm_name dcm_subset_name  dcm_question_grp_name  dcm_question_name dcm_que_occ_sn repeat_sn value_text qualifying_value study;
length dci_name dcm_question_grp_name $30 value_text $500 qualifying_value $30; set occ_dar2(rename=(_name_=dcm_question_name col1=value_text));
if dcm_question_name in('PATIENT','CLI_PLAN_EVE_NAME','SUBEVENT_NUMBER','DCI_NAME','DCM_NAME','DCM_SUBSET_NAME','DCM_QUESTION_GRP_NAME', 'DCM_QUE_OCC_SN','REPEAT','REPEAT_SN','REC_N','QUALIFYING_VALUE','STUDY') then delete;run;
%gethead(dar);
data dar3;
keep patient;
keep cli_plan_eve_name;
keep dci_name;
keep dcm_name;
keep dcm_subset_name;
keep dcm_question_grp_name;
keep subevent_number;
keep repeat;
keep qualifying_value;
keep study;
keep rec_n;
keep dtarep1c;

set ct4_dar;
patient=trim(left(put(sid1a,10.)));
cli_plan_eve_name=trim(left(put(visnam1a,20.)));
dci_name='DOSAGE ADMINISTRATION2';
dcm_name='DAR';
dcm_subset_name='DAR4';
dcm_question_grp_name='GLSTDNR';
subevent_number=0;
repeat=1;
qualifying_value='DARM005_625_2';
study='CFTY720D2306';
rec_n=1;
dtarep1c=trim(left(put(dtarep1c,17.)));
where pag1a eq "DAR_2" and DTAREP1C ne .;
proc sort data= dar3;by patient CLI_PLAN_EVE_NAME Subevent_Number DCI_NAME dcm_name dcm_subset_name dcm_question_grp_name rec_n qualifying_value study;run;data dar3;set dar3;by patient CLI_PLAN_EVE_NAME DCI_NAME ;if repeat=0 then do;                       
 if first.patient and first.CLI_PLAN_EVE_NAME then repeat_sn=0;repeat_sn+1;end;if repeat=1 then do;repeat_sn=1;if first.CLI_PLAN_EVE_NAME;end;run;proc transpose data=dar3 out=tran_dar3;
by patient CLI_PLAN_EVE_NAME Subevent_Number DCI_NAME dcm_name dcm_subset_name dcm_question_grp_name repeat_sn qualifying_value study;var _all_;run;data tran_dar3;length dcm_subset_name $8;set tran_dar3;_NAME_=upcase(_NAME_);
data dar3(drop=variable dataset);set newdata.formats;length _name_ $21 dcm_subset_name $8;if dataset='DAR3';_name_=variable ;run;
proc sort data=dar3;by dcm_subset_name _name_;run;proc sort data=tran_dar3 out=dar3_data;by dcm_subset_name _name_;run;
data occ_dar3;merge dar3_data dar3;by dcm_subset_name _name_;run;proc sort data=occ_dar3;
by patient CLI_PLAN_EVE_NAME Subevent_Number DCI_NAME dcm_name dcm_subset_name dcm_question_grp_name _name_ dcm_que_occ_sn repeat_sn ;run;
data tran.dar3;retain patient CLI_PLAN_EVE_NAME Subevent_Number DCI_NAME dcm_name dcm_subset_name  dcm_question_grp_name  dcm_question_name dcm_que_occ_sn repeat_sn value_text qualifying_value study;
keep patient CLI_PLAN_EVE_NAME Subevent_Number DCI_NAME dcm_name dcm_subset_name  dcm_question_grp_name  dcm_question_name dcm_que_occ_sn repeat_sn value_text qualifying_value study;
length dci_name dcm_question_grp_name $30 value_text $500 qualifying_value $30; set occ_dar3(rename=(_name_=dcm_question_name col1=value_text));
if dcm_question_name in('PATIENT','CLI_PLAN_EVE_NAME','SUBEVENT_NUMBER','DCI_NAME','DCM_NAME','DCM_SUBSET_NAME','DCM_QUESTION_GRP_NAME', 'DCM_QUE_OCC_SN','REPEAT','REPEAT_SN','REC_N','QUALIFYING_VALUE','STUDY') then delete;run;
%gethead(dar);
data dar4;
keep patient;
keep cli_plan_eve_name;
keep dci_name;
keep dcm_name;
keep dcm_subset_name;
keep dcm_question_grp_name;
keep subevent_number;
keep repeat;
keep qualifying_value;
keep study;
keep rec_n;
keep captak1n;
keep rsndos1c;
keep DOSLELDC;
keep day1;
keep month1;
keep year1;
keep day2;
keep month2;
keep year2;
format captak1n 4.;
set ct4_dar;
patient=trim(left(put(sid1a,10.)));
cli_plan_eve_name=trim(left(put(visnam1a,20.)));
dci_name='DOSAGE ADMINISTRATION2';
dcm_name='DAR';
dcm_subset_name='DAR4';
dcm_question_grp_name='DARR';
subevent_number=0;
repeat=0;
qualifying_value='DARM005_625_2';
study='CFTY720D2306';
rec_n=rec1n;
captak1n=trim(left(put(captak1n,4.)));
rsndos1c=trim(left(put(rsndos1c,32.)));
day1=substr(SMDSTT1D,1,2);
month1=substr(SMDSTT1D,3,3);
year1=substr(SMDSTT1D,6,4);
day2=substr(SMDEND1D,1,2);
month2=substr(SMDEND1D,3,3);
year2=substr(SMDEND1D,6,4);
where pag1a eq "DAR_2" and DTAREP1C ne .;
proc sort data= dar4;by patient CLI_PLAN_EVE_NAME Subevent_Number DCI_NAME dcm_name dcm_subset_name dcm_question_grp_name rec_n qualifying_value study;run;data dar4;set dar4;by patient CLI_PLAN_EVE_NAME DCI_NAME ;if repeat=0 then do;                       
 if first.patient and first.CLI_PLAN_EVE_NAME then repeat_sn=0;repeat_sn+1;end;if repeat=1 then do;repeat_sn=1;if first.CLI_PLAN_EVE_NAME;end;run;proc transpose data=dar4 out=tran_dar4;
by patient CLI_PLAN_EVE_NAME Subevent_Number DCI_NAME dcm_name dcm_subset_name dcm_question_grp_name repeat_sn qualifying_value study;var _all_;run;data tran_dar4;length dcm_subset_name $8;set tran_dar4;_NAME_=upcase(_NAME_);
data dar4(drop=variable dataset);set newdata.formats;length _name_ $21 dcm_subset_name $8;if dataset='DAR4';_name_=variable ;run;
proc sort data=dar4;by dcm_subset_name _name_;run;proc sort data=tran_dar4 out=dar4_data;by dcm_subset_name _name_;run;
data occ_dar4;merge dar4_data dar4;by dcm_subset_name _name_;run;proc sort data=occ_dar4;
by patient CLI_PLAN_EVE_NAME Subevent_Number DCI_NAME dcm_name dcm_subset_name dcm_question_grp_name _name_ dcm_que_occ_sn repeat_sn ;run;
data tran.dar4;retain patient CLI_PLAN_EVE_NAME Subevent_Number DCI_NAME dcm_name dcm_subset_name  dcm_question_grp_name  dcm_question_name dcm_que_occ_sn repeat_sn value_text qualifying_value study;
keep patient CLI_PLAN_EVE_NAME Subevent_Number DCI_NAME dcm_name dcm_subset_name  dcm_question_grp_name  dcm_question_name dcm_que_occ_sn repeat_sn value_text qualifying_value study;
length dci_name dcm_question_grp_name $30 value_text $500 qualifying_value $30; set occ_dar4(rename=(_name_=dcm_question_name col1=value_text));
if dcm_question_name in('PATIENT','CLI_PLAN_EVE_NAME','SUBEVENT_NUMBER','DCI_NAME','DCM_NAME','DCM_SUBSET_NAME','DCM_QUESTION_GRP_NAME', 'DCM_QUE_OCC_SN','REPEAT','REPEAT_SN','REC_N','QUALIFYING_VALUE','STUDY') then delete;run;





data load1;
retain PATIENT CLI_PLAN_EVE_NAME subevent_number DCI_NAME DCM_NAME DCM_SUBSET_NAME 
DCM_QUESTION_GRP_NAME  DCM_QUESTION_NAME DCM_QUE_OCC_SN REPEAT_SN VALUE_TEXT QUALIFYING_VALUE STUDY;
set tran.dar1 tran.dar2;
by DCM_NAME ;
PATIENT=upcase(PATIENT);

DCI_NAME=upcase(DCI_NAME);
DCM_NAME=upcase(DCM_NAME);
DCM_SUBSET_NAME=UPCASE(DCM_SUBSET_NAME); 
DCM_QUESTION_GRP_NAME=UPCASE(DCM_QUESTION_GRP_NAME); 
value_text=left(value_text);
if value_text='.' then value_text='';

%include "&user\CFTY720D/CFTY720D2306/EDC_Migration/Loadable_output\visit.sas";
%include "&user\CFTY720D/CFTY720D2306/EDC_Migration/Loadable_output\pt_test.sas";


if DCM_QUESTION_NAME='DAY1' then DCM_QUE_OCC_SN=1;
else if DCM_QUESTION_NAME='DAY2' then DCM_QUE_OCC_SN=2;
else if DCM_QUESTION_NAME='DAY3' then DCM_QUE_OCC_SN=3;
else if DCM_QUESTION_NAME='MONTH2' then DCM_QUE_OCC_SN=2;
else if DCM_QUESTION_NAME='MONTH1' then DCM_QUE_OCC_SN=1;
else if DCM_QUESTION_NAME='MONTH3' then DCM_QUE_OCC_SN=3;
else if DCM_QUESTION_NAME='YEAR2' then DCM_QUE_OCC_SN=2;
else if DCM_QUESTION_NAME='YEAR1' then DCM_QUE_OCC_SN=1;
else if DCM_QUESTION_NAME='YEAR3' then DCM_QUE_OCC_SN=3;
else if DCM_QUESTION_NAME='TMHOUR1' then DCM_QUE_OCC_SN=1;
else if DCM_QUESTION_NAME='TMHOUR2' then DCM_QUE_OCC_SN=2;
else if DCM_QUESTION_NAME='TMMIN1' then DCM_QUE_OCC_SN=1;
else if DCM_QUESTION_NAME='TMMIN2' then DCM_QUE_OCC_SN=2;
else if DCM_QUESTION_NAME='TMHOUR3' then DCM_QUE_OCC_SN=3;
else if DCM_QUESTION_NAME='TMMIN3' then DCM_QUE_OCC_SN=3;
else DCM_QUE_OCC_SN=0;


if DCM_QUE_OCC_SN=. then DCM_QUE_OCC_SN=0;


if repeat_sn>10 then do;
dci_name='DOSAGE ADMINISTRATION1 REP';DCM_SUBSET_NAME='DAR5';QUALIFYING_VALUE='DMGS006_2';
end;

 REPEAT_SN1= REPEAT_SN - (FLOOR(REPEAT_SN/10)*10); 
 if REPEAT_SN1 eq 0 then do; REPEAT_SN1=10; end;

where value_text ne '';


run;

data load2;
retain PATIENT CLI_PLAN_EVE_NAME subevent_number DCI_NAME DCM_NAME DCM_SUBSET_NAME 
DCM_QUESTION_GRP_NAME  DCM_QUESTION_NAME DCM_QUE_OCC_SN REPEAT_SN VALUE_TEXT QUALIFYING_VALUE STUDY;
set tran.dar3 tran.dar4;
by DCM_NAME ;
PATIENT=upcase(PATIENT);

DCI_NAME=upcase(DCI_NAME);
DCM_NAME=upcase(DCM_NAME);
DCM_SUBSET_NAME=UPCASE(DCM_SUBSET_NAME); 
DCM_QUESTION_GRP_NAME=UPCASE(DCM_QUESTION_GRP_NAME); 
value_text=left(value_text);
if value_text='.' then value_text='';

%include "&path\Transfer_Programs\visit.sas";
%include "&path\Transfer_Programs\pt.sas";


if DCM_QUESTION_NAME='DAY1' then DCM_QUE_OCC_SN=1;
else if DCM_QUESTION_NAME='DAY2' then DCM_QUE_OCC_SN=2;
else if DCM_QUESTION_NAME='DAY3' then DCM_QUE_OCC_SN=3;
else if DCM_QUESTION_NAME='MONTH2' then DCM_QUE_OCC_SN=2;
else if DCM_QUESTION_NAME='MONTH1' then DCM_QUE_OCC_SN=1;
else if DCM_QUESTION_NAME='MONTH3' then DCM_QUE_OCC_SN=3;
else if DCM_QUESTION_NAME='YEAR2' then DCM_QUE_OCC_SN=2;
else if DCM_QUESTION_NAME='YEAR1' then DCM_QUE_OCC_SN=1;
else if DCM_QUESTION_NAME='YEAR3' then DCM_QUE_OCC_SN=3;
else if DCM_QUESTION_NAME='TMHOUR1' then DCM_QUE_OCC_SN=1;
else if DCM_QUESTION_NAME='TMHOUR2' then DCM_QUE_OCC_SN=2;
else if DCM_QUESTION_NAME='TMMIN1' then DCM_QUE_OCC_SN=1;
else if DCM_QUESTION_NAME='TMMIN2' then DCM_QUE_OCC_SN=2;
else if DCM_QUESTION_NAME='TMHOUR3' then DCM_QUE_OCC_SN=3;
else if DCM_QUESTION_NAME='TMMIN3' then DCM_QUE_OCC_SN=3;
else DCM_QUE_OCC_SN=0;

/*if substr(DCM_QUESTION_NAME,1,3)='DAY' then DCM_QUESTION_NAME=substr(DCM_QUESTION_NAME,1,3);*/
/*if substr(DCM_QUESTION_NAME,1,5)='MONTH' then DCM_QUESTION_NAME=substr(DCM_QUESTION_NAME,1,5);*/
/*if substr(DCM_QUESTION_NAME,1,4)='YEAR' then DCM_QUESTION_NAME=substr(DCM_QUESTION_NAME,1,4);*/
/*if substr(DCM_QUESTION_NAME,1,6)='TMHOUR' then DCM_QUESTION_NAME=substr(DCM_QUESTION_NAME,1,6);*/
/*if substr(DCM_QUESTION_NAME,1,5)='TMMIN' then DCM_QUESTION_NAME=substr(DCM_QUESTION_NAME,1,5);*/
if DCM_QUE_OCC_SN=. then DCM_QUE_OCC_SN=0;

where value_text ne '';

if repeat_sn>10 then do;
dci_name='DOSAGE ADMINISTRATION2 REP';DCM_SUBSET_NAME='DAR8';QUALIFYING_VALUE='OPHS003_1';
end;

 REPEAT_SN1= REPEAT_SN - (FLOOR(REPEAT_SN/10)*10); 
if REPEAT_SN1 eq 0 then do; REPEAT_SN1=10; end;

run;


data c3;
set LOAD1 LOAD2;
if repeat_sn in (1,2,3,4,5,6,7,8,9,10) then subevent_number = 0;
else if repeat_sn in (11,12,13,14,15,16,17,18,19,20) then subevent_number = 0;
else if repeat_sn in (21,22,23,24,25,26,27,28,29,30) then subevent_number = 1;
else if repeat_sn in (31,32,33,34,35,36,37,38,39,40) then subevent_number = 2;
else if repeat_sn in (41,42,43,44,45,46,47,48,49,50) then subevent_number = 3;
else if repeat_sn in (51,52,53,54,55,56,57,58,59,60) then subevent_number = 4;
else if repeat_sn in (61,62,63,64,65,66,67,68,69,70) then subevent_number = 5;
else if repeat_sn in (71,72,73,74,75,76,77,78,79,80) then subevent_number = 6;
else if repeat_sn in (81,82,83,84,85,86,87,88,89,90) then subevent_number = 7;
else if repeat_sn in (91,92,93,94,95,96,97,98,99,100) then subevent_number = 8;
else if repeat_sn in (101,102,103,104,105,106,107,108,109,110) then subevent_number=9;
else if repeat_sn in (111,112,113,114,115,116,117,118,119,120) then subevent_number=10;
else if repeat_sn in (121,122,123,124,125,126,127,128,129,130) then subevent_number=11;
else if repeat_sn in (131,132,133,134,135,136,137,138,139,140) then subevent_number=12;
else if repeat_sn in (141,142,143,144,145,146,147,148,149,150) then subevent_number=13;
else if repeat_sn in (151,152,153,154,155,156,157,158,159,160) then subevent_number=14;
else if repeat_sn in (161,162,163,164,165,166,167,168,169,170) then subevent_number=15;
else if repeat_sn in (171,172,173,174,175,176,177,178,179,180) then subevent_number=16;
else if repeat_sn in (181,182,183,184,185,186,187,188,189,190) then subevent_number=17;
else if repeat_sn in (191,192,193,194,195,196,197,198,199,200) then subevent_number=18;
else if repeat_sn in (201,202,203,204,205,206,207,208,209,210) then subevent_number=19;



repeat_sn=repeat_sn1;


if substr(DCM_QUESTION_NAME,1,3)='DAY' then DCM_QUESTION_NAME=substr(DCM_QUESTION_NAME,1,3);
if substr(DCM_QUESTION_NAME,1,5)='MONTH' then DCM_QUESTION_NAME=substr(DCM_QUESTION_NAME,1,5);
if substr(DCM_QUESTION_NAME,1,4)='YEAR' then DCM_QUESTION_NAME=substr(DCM_QUESTION_NAME,1,4);
if substr(DCM_QUESTION_NAME,1,6)='TMHOUR' then DCM_QUESTION_NAME=substr(DCM_QUESTION_NAME,1,6);
if substr(DCM_QUESTION_NAME,1,5)='TMMIN' then DCM_QUESTION_NAME=substr(DCM_QUESTION_NAME,1,5);
if value_text='' then delete;

drop repeat_sn1;


run;

Data _null_;   
   file "&user\CFTY720D/CFTY720D2306/EDC_Migration/Loadable_output\EDCMigration_FileTransfer_FTY720D2306_OCRDC _OC_DAR_LOADABLE.txt" dsd dlm='|';
   set c3;
   put (_all_) (+0);

   run;


