
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

proc sort data =views.scr out=scr1;
by sid1a exccri5c INCCRI5C descending exccri6c;
run;
data views.scr;
set scr1; 
by sid1a; if first.sid1a; run;

data views.scr;
set views.scr;
visnam1a = 'V1 - Screening';
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

/*scr*/


%gethead(scr);
data dmg2;
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
keep sbjini1a;
keep sex1c;
keep day;
keep month;
keep year;
keep rce5c ETH2C SRCREF1A SRCREF1C ETHSPY1A BIMIFC1C BIMIFC3C AGEDRV1N;
set ct4_scr;
patient=trim(left(put(sid1a,10.)));
cli_plan_eve_name='V1 - Screening';
dci_name='DEMOGRAPHY';
dcm_name='DMG';
dcm_subset_name='DMG2';
dcm_question_grp_name='DMG';
subevent_number=0;
repeat=1;
AGEDRV1N= age1n;
day=substr(DOB1D,1,2);
month=substr(DOB1D,3,3);
year=substr(DOB1D,6,4);
qualifying_value='DMGS006_2';
study='CFTY720D2306';
rec_n=1;
proc sort data= dmg2;by patient CLI_PLAN_EVE_NAME Subevent_Number DCI_NAME dcm_name dcm_subset_name dcm_question_grp_name rec_n qualifying_value study;run;data dmg2;set dmg2;by patient CLI_PLAN_EVE_NAME DCI_NAME ;if repeat=0 then do; 
if first.patient and first.CLI_PLAN_EVE_NAME then repeat_sn=0;repeat_sn+1;end;if repeat=1 then do;repeat_sn=1;if first.CLI_PLAN_EVE_NAME;end;run;proc transpose data=dmg2 out=tran_dmg2;
by patient CLI_PLAN_EVE_NAME Subevent_Number DCI_NAME dcm_name dcm_subset_name dcm_question_grp_name repeat_sn qualifying_value study;var _all_;run;data tran_dmg2;length dcm_subset_name $8;set tran_dmg2;_NAME_=upcase(_NAME_);
data dmg2(drop=variable dataset);set newdata.formats;length _name_ $21 dcm_subset_name $8;if dataset='DMG';_name_=variable ;run;
proc sort data=dmg2;by dcm_subset_name _name_;run;proc sort data=tran_dmg2 out=dmg_data1;by dcm_subset_name _name_;run;
data occ_dmg2;set dmg_data1 ;by dcm_subset_name _name_;run;proc sort data=occ_dmg2;
by patient CLI_PLAN_EVE_NAME Subevent_Number DCI_NAME dcm_name dcm_subset_name dcm_question_grp_name _name_ repeat_sn ;run;

data tran.dmg2;retain patient CLI_PLAN_EVE_NAME Subevent_Number DCI_NAME dcm_name dcm_subset_name  dcm_question_grp_name  dcm_question_name repeat_sn value_text qualifying_value study;
keep patient CLI_PLAN_EVE_NAME Subevent_Number DCI_NAME dcm_name dcm_subset_name  dcm_question_grp_name  dcm_question_name repeat_sn value_text qualifying_value study;
length dci_name dcm_question_grp_name $30 value_text $500 qualifying_value $30; set occ_dmg2(rename=(_name_=dcm_question_name col1=value_text));
dcm_question_name = upcase(dcm_question_name);
if dcm_question_name in('PATIENT','CLI_PLAN_EVE_NAME','SUBEVENT_NUMBER','DCI_NAME','DCM_NAME','DCM_SUBSET_NAME','DCM_QUESTION_GRP_NAME', 'DCM_QUE_OCC_SN','REPEAT','REPEAT_SN','REC_N','QUALIFYING_VALUE','STUDY') then delete;run;


%gethead(scr);
data scr1;
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
keep rsnnct3c;
keep sbjctu1c;
keep rsnnct1a;
keep oth1a;
keep inccri5c;
keep exccri5c;
keep exccri6c;
set ct4_scr;
patient=trim(left(put(sid1a,10.)));
cli_plan_eve_name='V1 - Screening';
dci_name='SCREENING LOG';
dcm_name='SCR';
dcm_subset_name='SCR1';
dcm_question_grp_name='GLSTDNR';
subevent_number=0;
repeat=1;
qualifying_value='SCRS001';
study='CFTY720D2306';
rec_n=1;
rsnnct3c=trim(left(put(rsnnct3c,30.)));
sbjctu1c=trim(left(put(sbjctu1c,17.)));
inccri5c=trim(left(put(inccri5c,30.)));
exccri5c=trim(left(put(exccri5c,30.)));
exccri6c=trim(left(put(exccri6c,30.)));
proc sort data= scr1;by patient CLI_PLAN_EVE_NAME Subevent_Number DCI_NAME dcm_name dcm_subset_name dcm_question_grp_name rec_n qualifying_value study;run;data scr1;set scr1;by patient CLI_PLAN_EVE_NAME DCI_NAME ;if repeat=0 then do;                       
 if first.patient and first.CLI_PLAN_EVE_NAME then repeat_sn=0;repeat_sn+1;end;if repeat=1 then do;repeat_sn=1;if first.CLI_PLAN_EVE_NAME;end;run;proc transpose data=scr1 out=tran_scr1;
by patient CLI_PLAN_EVE_NAME Subevent_Number DCI_NAME dcm_name dcm_subset_name dcm_question_grp_name repeat_sn qualifying_value study;var _all_;run;data tran_scr1;length dcm_subset_name $8;set tran_scr1;_NAME_=upcase(_NAME_);
data scr1(drop=variable dataset);set newdata.formats;length _name_ $21 dcm_subset_name $8;if dataset='SCR1';_name_=variable ;run;
proc sort data=scr1;by dcm_subset_name _name_;run;proc sort data=tran_scr1 out=scr1_data;by dcm_subset_name _name_;run;
data occ_scr1;set scr1_data ;by dcm_subset_name _name_;run;proc sort data=occ_scr1;
by patient CLI_PLAN_EVE_NAME Subevent_Number DCI_NAME dcm_name dcm_subset_name dcm_question_grp_name _name_ repeat_sn ;run;
data tran.scr1;retain patient CLI_PLAN_EVE_NAME Subevent_Number DCI_NAME dcm_name dcm_subset_name  dcm_question_grp_name  dcm_question_name repeat_sn value_text qualifying_value study;
keep patient CLI_PLAN_EVE_NAME Subevent_Number DCI_NAME dcm_name dcm_subset_name  dcm_question_grp_name  dcm_question_name repeat_sn value_text qualifying_value study;
length dci_name dcm_question_grp_name $30 value_text $500 qualifying_value $30; set occ_scr1(rename=(_name_=dcm_question_name col1=value_text));
if dcm_question_name in('PATIENT','CLI_PLAN_EVE_NAME','SUBEVENT_NUMBER','DCI_NAME','DCM_NAME','DCM_SUBSET_NAME','DCM_QUESTION_GRP_NAME', 'DCM_QUE_OCC_SN','REPEAT','REPEAT_SN','REC_N','QUALIFYING_VALUE','STUDY') then delete;run;


%gethead(enroll);
data scr2;
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
keep sbjctu1c;
set ct4_enroll;
patient=trim(left(put(sid1a,10.)));
cli_plan_eve_name='V1 - Screening';
dci_name='SCREENING LOG';
dcm_name='SCR';
dcm_subset_name='SCR1';
dcm_question_grp_name='GLSTDNR';
subevent_number=0;
repeat=1;
qualifying_value='SCRS001';
study='CFTY720D2306';
rec_n=1;
sbjctu1c='Yes';
proc sort data= scr2;by patient CLI_PLAN_EVE_NAME Subevent_Number DCI_NAME dcm_name dcm_subset_name dcm_question_grp_name rec_n qualifying_value study;run;data scr2;set scr2;by patient CLI_PLAN_EVE_NAME DCI_NAME ;if repeat=0 then do;                       
 if first.patient and first.CLI_PLAN_EVE_NAME then repeat_sn=0;repeat_sn+1;end;if repeat=1 then do;repeat_sn=1;if first.CLI_PLAN_EVE_NAME;end;run;proc transpose data=scr2 out=tran_scr2;
by patient CLI_PLAN_EVE_NAME Subevent_Number DCI_NAME dcm_name dcm_subset_name dcm_question_grp_name repeat_sn qualifying_value study;var _all_;run;data tran_scr2;length dcm_subset_name $8;set tran_scr2;_NAME_=upcase(_NAME_);
data scr2(drop=variable dataset);set newdata.formats;length _name_ $21 dcm_subset_name $8;if dataset='SCR2';_name_=variable ;run;
proc sort data=scr2;by dcm_subset_name _name_;run;proc sort data=tran_scr2 out=scr2_data;by dcm_subset_name _name_;run;
data occ_scr2;set scr2_data ;by dcm_subset_name _name_;run;proc sort data=occ_scr2;
by patient CLI_PLAN_EVE_NAME Subevent_Number DCI_NAME dcm_name dcm_subset_name dcm_question_grp_name _name_ repeat_sn ;run;
data tran.scr2;retain patient CLI_PLAN_EVE_NAME Subevent_Number DCI_NAME dcm_name dcm_subset_name  dcm_question_grp_name  dcm_question_name repeat_sn value_text qualifying_value study;
keep patient CLI_PLAN_EVE_NAME Subevent_Number DCI_NAME dcm_name dcm_subset_name  dcm_question_grp_name  dcm_question_name repeat_sn value_text qualifying_value study;
length dci_name dcm_question_grp_name $30 value_text $500 qualifying_value $30; set occ_scr2(rename=(_name_=dcm_question_name col1=value_text));

if dcm_question_name in('PATIENT','CLI_PLAN_EVE_NAME','SUBEVENT_NUMBER','DCI_NAME','DCM_NAME','DCM_SUBSET_NAME','DCM_QUESTION_GRP_NAME', 'DCM_QUE_OCC_SN','REPEAT','REPEAT_SN','REC_N','QUALIFYING_VALUE','STUDY') then delete;run;


data load;
retain PATIENT CLI_PLAN_EVE_NAME subevent_number DCI_NAME DCM_NAME DCM_SUBSET_NAME 
DCM_QUESTION_GRP_NAME  DCM_QUESTION_NAME DCM_QUE_OCC_SN REPEAT_SN VALUE_TEXT QUALIFYING_VALUE STUDY;
set tran.dmg2 tran.scr1 tran.scr2;
by DCM_NAME ;
PATIENT=upcase(PATIENT);
CLI_PLAN_EVE_NAME=upcase(CLI_PLAN_EVE_NAME);
DCI_NAME=upcase(DCI_NAME);
DCM_NAME=upcase(DCM_NAME);
DCM_SUBSET_NAME=UPCASE(DCM_SUBSET_NAME); 
DCM_QUESTION_GRP_NAME=UPCASE(DCM_QUESTION_GRP_NAME); 
value_text=left(value_text);
if value_text='.' then value_text='';
/*%include "&path\Transfer_Programs\pt.sas";*/
%include "&user\CFTY720D/CFTY720D2306/EDC_Migration/Loadable_output\visit.sas";
%include "&user\CFTY720D/CFTY720D2306/EDC_Migration/Loadable_output\pt_test.sas";
/*patient=substr(patient,2);*/
if value_text='' then delete;
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

if substr(DCM_QUESTION_NAME,1,3)='DAY' then DCM_QUESTION_NAME=substr(DCM_QUESTION_NAME,1,3);
if substr(DCM_QUESTION_NAME,1,5)='MONTH' then DCM_QUESTION_NAME=substr(DCM_QUESTION_NAME,1,5);
if substr(DCM_QUESTION_NAME,1,4)='YEAR' then DCM_QUESTION_NAME=substr(DCM_QUESTION_NAME,1,4);
if substr(DCM_QUESTION_NAME,1,6)='TMHOUR' then DCM_QUESTION_NAME=substr(DCM_QUESTION_NAME,1,6);
if substr(DCM_QUESTION_NAME,1,5)='TMMIN' then DCM_QUESTION_NAME=substr(DCM_QUESTION_NAME,1,5);
if DCM_QUE_OCC_SN=. then DCM_QUE_OCC_SN=0;
/*CLI_PLAN_EVE_NAME='SCREENING-WEEK-4';*/
run;


Data _null_;   
   file "&user\CFTY720D/CFTY720D2306/EDC_Migration/Loadable_output\EDCMigration_FileTransfer_FTY720D2306_OCRDC _OC_SCR_LOADABLE.txt" dsd dlm='|';
   set load;
   put (_all_) (+0);
   run;

