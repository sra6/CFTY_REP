
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
%include "&user\CFTY720D/CFTY720D2306/EDC_Migration/Loadable_output\visit.sas";
%include "&user\CFTY720D/CFTY720D2306/EDC_Migration/Loadable_output\pt_test.sas";

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

/*msr*/


%gethead(msr);
data msr1;
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
keep rlp3c;
set ct4_msr;
patient=trim(left(put(sid1a,10.)));
cli_plan_eve_name=trim(left(put(visnam1a,20.)));
dci_name='MS ATTACK';
dcm_name='MSR';
dcm_subset_name='MSR1';
dcm_question_grp_name='GLSTDNR';
subevent_number=0;
repeat=1;
qualifying_value='MSRS001YN_1';
study='CFTY720D2306';
rec_n=1;
rlp3c=trim(left(put(dtarep1c,yno11_.)));

RUN;
proc sort data= msr1;by patient CLI_PLAN_EVE_NAME Subevent_Number DCI_NAME dcm_name dcm_subset_name dcm_question_grp_name rec_n qualifying_value study;run;data msr1;set msr1;by patient CLI_PLAN_EVE_NAME DCI_NAME ;if repeat=0 then do;                       
 if first.patient and first.CLI_PLAN_EVE_NAME then repeat_sn=0;repeat_sn+1;end;if repeat=1 then do;repeat_sn=1;if first.CLI_PLAN_EVE_NAME;end;run;proc transpose data=msr1 out=tran_msr1;
by patient CLI_PLAN_EVE_NAME Subevent_Number DCI_NAME dcm_name dcm_subset_name dcm_question_grp_name repeat_sn qualifying_value study;var _all_;run;data tran_msr1;length dcm_subset_name $8;set tran_msr1;_NAME_=upcase(_NAME_);
data msr1(drop=variable dataset);set newdata.formats;length _name_ $21 dcm_subset_name $8;if dataset='MSR1';_name_=variable ;run;
proc sort data=msr1;by dcm_subset_name _name_;run;proc sort data=tran_msr1 out=msr1_data;by dcm_subset_name _name_;run;
data occ_msr1;merge msr1_data msr1;by dcm_subset_name _name_;run;proc sort data=occ_msr1;
by patient CLI_PLAN_EVE_NAME Subevent_Number DCI_NAME dcm_name dcm_subset_name dcm_question_grp_name _name_ dcm_que_occ_sn repeat_sn ;run;
data tran.msr1;retain patient CLI_PLAN_EVE_NAME Subevent_Number DCI_NAME dcm_name dcm_subset_name  dcm_question_grp_name  dcm_question_name dcm_que_occ_sn repeat_sn value_text qualifying_value study;
keep patient CLI_PLAN_EVE_NAME Subevent_Number DCI_NAME dcm_name dcm_subset_name  dcm_question_grp_name  dcm_question_name dcm_que_occ_sn repeat_sn value_text qualifying_value study;
length dci_name dcm_question_grp_name $30 value_text $500 qualifying_value $30; set occ_msr1(rename=(_name_=dcm_question_name col1=value_text));
if dcm_question_name in('PATIENT','CLI_PLAN_EVE_NAME','SUBEVENT_NUMBER','DCI_NAME','DCM_NAME','DCM_SUBSET_NAME','DCM_QUESTION_GRP_NAME', 'DCM_QUE_OCC_SN','REPEAT','REPEAT_SN','REC_N','QUALIFYING_VALUE','STUDY') then delete;run;
%gethead(msr);
data msr2;
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
keep hos1c;
keep stothy1c;
keep msrrcv1c;
keep exr1c;
keep aevsev1c;
keep rlpcfm1c;
keep day1;
keep month1;
keep year1;
keep day2;
keep month2;
keep year2;
keep day3;
keep month3;
keep year3;
set ct4_msr;
patient=trim(left(put(sid1a,10.)));
cli_plan_eve_name=trim(left(put(visnam1a,20.)));
dci_name='MS ATTACK';
dcm_name='MSR';
dcm_subset_name='MSR1';
dcm_question_grp_name='MSRR';
subevent_number=0;
repeat=0;
qualifying_value='MSRS001YN_1';
study='CFTY720D2306';
rec_n=trim(left(put(rec1n,8.)));
hos1c=trim(left(put(hos1c,17.)));
stothy1c=trim(left(put(stothy1c,17.)));
msrrcv1c=trim(left(put(msrrcv1c,8.)));
exr1c=trim(left(put(exr1c,17.)));
aevsev1c=trim(left(put(sev1c,Sev21_.)));
rlpcfm1c=trim(left(put(rlpcfm1c,17.)));
day1=substr(RLPSTT1D,1,2);
month1=substr(RLPSTT1D,3,3);
year1=substr(RLPSTT1D,6,4);
day2=substr(RLPEND1D,1,2);
month2=substr(RLPEND1D,3,3);
year2=substr(RLPEND1D,6,4);
day3=substr(RLP1D,1,2);
month3=substr(RLP1D,3,3);
year3=substr(RLP1D,6,4);
RUN;
proc sort data= msr2;by patient CLI_PLAN_EVE_NAME Subevent_Number DCI_NAME dcm_name dcm_subset_name dcm_question_grp_name rec_n qualifying_value study;run;data msr2;set msr2;by patient CLI_PLAN_EVE_NAME DCI_NAME ;if repeat=0 then do;                       
 if first.patient and first.CLI_PLAN_EVE_NAME then repeat_sn=0;repeat_sn+1;end;if repeat=1 then do;repeat_sn=1;if first.CLI_PLAN_EVE_NAME;end;run;proc transpose data=msr2 out=tran_msr2;
by patient CLI_PLAN_EVE_NAME Subevent_Number DCI_NAME dcm_name dcm_subset_name dcm_question_grp_name repeat_sn qualifying_value study;var _all_;run;data tran_msr2;length dcm_subset_name $8;set tran_msr2;_NAME_=upcase(_NAME_);
data msr2(drop=variable dataset);set newdata.formats;length _name_ $21 dcm_subset_name $8;if dataset='MSR2';_name_=variable ;run;
proc sort data=msr2;by dcm_subset_name _name_;run;proc sort data=tran_msr2 out=msr2_data;by dcm_subset_name _name_;run;
data occ_msr2;merge msr2_data msr2;by dcm_subset_name _name_;run;proc sort data=occ_msr2;
by patient CLI_PLAN_EVE_NAME Subevent_Number DCI_NAME dcm_name dcm_subset_name dcm_question_grp_name _name_ dcm_que_occ_sn repeat_sn ;run;
data tran.msr2;retain patient CLI_PLAN_EVE_NAME Subevent_Number DCI_NAME dcm_name dcm_subset_name  dcm_question_grp_name  dcm_question_name dcm_que_occ_sn repeat_sn value_text qualifying_value study;
keep patient CLI_PLAN_EVE_NAME Subevent_Number DCI_NAME dcm_name dcm_subset_name  dcm_question_grp_name  dcm_question_name dcm_que_occ_sn repeat_sn value_text qualifying_value study;
length dci_name dcm_question_grp_name $30 value_text $500 qualifying_value $30; set occ_msr2(rename=(_name_=dcm_question_name col1=value_text));
if dcm_question_name in('PATIENT','CLI_PLAN_EVE_NAME','SUBEVENT_NUMBER','DCI_NAME','DCM_NAME','DCM_SUBSET_NAME','DCM_QUESTION_GRP_NAME', 'DCM_QUE_OCC_SN','REPEAT','REPEAT_SN','REC_N','QUALIFYING_VALUE','STUDY') then delete;run;


data load;
retain PATIENT CLI_PLAN_EVE_NAME subevent_number DCI_NAME DCM_NAME DCM_SUBSET_NAME 
DCM_QUESTION_GRP_NAME  DCM_QUESTION_NAME DCM_QUE_OCC_SN REPEAT_SN VALUE_TEXT QUALIFYING_VALUE STUDY;
set tran.msr1 tran.msr2;
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
%include "&path\Transfer_Programs\visit.sas";
%include "&path\Transfer_Programs\pt.sas";
/*patient=substr(patient,2);*/
/*if value_text='' then delete;*/
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

if repeat_sn in (1,2,3,4,5,6,7,8,9,10) then subevent_number = 0;
else if repeat_sn in (11,12,13,14,15,16,17,18,19,20) then subevent_number = 0;
  else if repeat_sn in (21,22,23,24,25,26,27,28,29,30) then subevent_number = 1;
    else if repeat_sn in (31,32,33,34,35,36,37,38,39,40) then subevent_number = 2;
	if repeat_sn in (41,42,43,44,45,46,47,48,49,50) then subevent_number = 3;
else if repeat_sn in (51,52,53,54,55,56,57,58,59,60) then subevent_number = 4;
  else if repeat_sn in (61,62,63,64,65,66,67,68,69,70) then subevent_number = 5;
    else if repeat_sn in (71,72,73,74,75,76,77,78,79,80) then subevent_number = 6;
		if repeat_sn in (81,82,83,84,85,86,87,88,89,90) then subevent_number = 7;
else if repeat_sn in (91,92,93,94,95,96,97,98,99,100) then subevent_number = 8;
	if repeat_sn>10 then do;dci_name='MS ATTACK REP';DCM_SUBSET_NAME='MSR2';QUALIFYING_VALUE='HISS003';end;

run;

proc sort data=load out=b;
by patient CLI_PLAN_EVE_NAME subevent_number DCI_NAME DCM_NAME DCM_SUBSET_NAME 
DCM_QUESTION_GRP_NAME  DCM_QUESTION_NAME;
run;
data c;
retain PATIENT CLI_PLAN_EVE_NAME subevent_number DCI_NAME DCM_NAME DCM_SUBSET_NAME 
DCM_QUESTION_GRP_NAME  DCM_QUESTION_NAME DCM_QUE_OCC_SN REPEAT_SN VALUE_TEXT QUALIFYING_VALUE STUDY;
set b(drop=repeat_sn);
by patient CLI_PLAN_EVE_NAME subevent_number DCI_NAME DCM_NAME DCM_SUBSET_NAME 
DCM_QUESTION_GRP_NAME  DCM_QUESTION_NAME ;
if   first.DCM_QUESTION_NAME  then repeat_sn=1;
else repeat_sn=repeat_sn+1;;
if substr(DCM_QUESTION_NAME,1,3)='DAY' then DCM_QUESTION_NAME=substr(DCM_QUESTION_NAME,1,3);
if substr(DCM_QUESTION_NAME,1,5)='MONTH' then DCM_QUESTION_NAME=substr(DCM_QUESTION_NAME,1,5);
if substr(DCM_QUESTION_NAME,1,4)='YEAR' then DCM_QUESTION_NAME=substr(DCM_QUESTION_NAME,1,4);
if substr(DCM_QUESTION_NAME,1,6)='TMHOUR' then DCM_QUESTION_NAME=substr(DCM_QUESTION_NAME,1,6);
if substr(DCM_QUESTION_NAME,1,5)='TMMIN' then DCM_QUESTION_NAME=substr(DCM_QUESTION_NAME,1,5);
if value_text='' then delete;
run;


Data _null_;   
   file "&user\CFTY720D/CFTY720D2306/EDC_Migration/Loadable_output\EDCMigration_FileTransfer_FTY720D2306_OCRDC _OC_MSR_LOADABLE.txt" dsd dlm='|';
   set c;
   put (_all_) (+0);
   run;


