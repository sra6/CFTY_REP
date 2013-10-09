
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

data views.cmd;
set views.cmd;
format cmdctu1c cross.;
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

/*cmd*/


%gethead(cmd);
data cmd1;
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
set ct4_cmd;
patient=trim(left(put(sid1a,10.)));
cli_plan_eve_name=trim(left(put(visnam1a,20.)));
dci_name='CONCOMITANT MEDICATIONS';
dcm_name='CMD';
dcm_subset_name='CMD4';
dcm_question_grp_name='CMD';
subevent_number=0;
repeat=1;
qualifying_value='CMDG006YN_4';
study='CFTY720D2306';
rec_n=1;
dtarep1c=trim(left(put(dtarep1c,17.)));
where CMDCAT1C = 0;
proc sort data= cmd1;by patient CLI_PLAN_EVE_NAME Subevent_Number DCI_NAME dcm_name dcm_subset_name dcm_question_grp_name rec_n qualifying_value study;run;data cmd1;set cmd1;by patient CLI_PLAN_EVE_NAME DCI_NAME ;if repeat=0 then do;                       
 if first.patient and first.CLI_PLAN_EVE_NAME then repeat_sn=0;repeat_sn+1;end;if repeat=1 then do;repeat_sn=1;if first.CLI_PLAN_EVE_NAME;end;run;proc transpose data=cmd1 out=tran_cmd1;
by patient CLI_PLAN_EVE_NAME Subevent_Number DCI_NAME dcm_name dcm_subset_name dcm_question_grp_name repeat_sn qualifying_value study;var _all_;run;data tran_cmd1;length dcm_subset_name $8;set tran_cmd1;_NAME_=upcase(_NAME_);
data cmd1(drop=variable dataset);set newdata.formats;length _name_ $21 dcm_subset_name $8;if dataset='CMD1';_name_=variable ;run;
proc sort data=cmd1;by dcm_subset_name _name_;run;proc sort data=tran_cmd1 out=cmd1_data;by dcm_subset_name _name_;run;
data occ_cmd1;merge cmd1_data cmd1;by dcm_subset_name _name_;run;proc sort data=occ_cmd1;
by patient CLI_PLAN_EVE_NAME Subevent_Number DCI_NAME dcm_name dcm_subset_name dcm_question_grp_name _name_ dcm_que_occ_sn repeat_sn ;run;
data tran.cmd1;retain patient CLI_PLAN_EVE_NAME Subevent_Number DCI_NAME dcm_name dcm_subset_name  dcm_question_grp_name  dcm_question_name dcm_que_occ_sn repeat_sn value_text qualifying_value study;
keep patient CLI_PLAN_EVE_NAME Subevent_Number DCI_NAME dcm_name dcm_subset_name  dcm_question_grp_name  dcm_question_name dcm_que_occ_sn repeat_sn value_text qualifying_value study;
length dci_name dcm_question_grp_name $30 value_text $500 qualifying_value $30; set occ_cmd1(rename=(_name_=dcm_question_name col1=value_text));
if dcm_question_name in('PATIENT','CLI_PLAN_EVE_NAME','SUBEVENT_NUMBER','DCI_NAME','DCM_NAME','DCM_SUBSET_NAME','DCM_QUESTION_GRP_NAME', 'DCM_QUE_OCC_SN','REPEAT','REPEAT_SN','REC_N','QUALIFYING_VALUE','STUDY') then delete;run;
%gethead(cmd);
data cmd2;
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
keep verbatim_whodrug;
keep cmdrsn1a;
keep cmdctu1c;
keep cmdunt1c;
keep cmdunt1a;
keep cmddos1a;
keep cmdfrq2c;
keep cmdfrq1a;
keep cmdrte1c;
keep day1;
keep month1;
keep year1;
keep day2;
keep month2;
keep year2;
set ct4_cmd;
patient=trim(left(put(sid1a,10.)));
cli_plan_eve_name=trim(left(put(visnam1a,20.)));
dci_name='CONCOMITANT MEDICATIONS';
dcm_name='CMD';
dcm_subset_name='CMD4';
dcm_question_grp_name='CMDR';
subevent_number=0;
repeat=0;
qualifying_value='CMDG006YN_4';
study='CFTY720D2306';
rec_n=rec1n;
verbatim_whodrug=trim(left(put(cmdnam1a,70.)));
cmdctu1c=trim(left(put(cmdctu1c,11.)));
cmdunt1c=trim(left(put(cmdunt1c,19.)));
cmdfrq2c=trim(left(put(cmdfrq2c,11.)));
cmdrte1c=trim(left(put(cmdrte1c,15.)));
day1=substr(CMDSTT1D,1,2);
month1=substr(CMDSTT1D,3,3);
year1=substr(CMDSTT1D,6,4);
day2=substr(CMDEND1D,1,2);
month2=substr(CMDEND1D,3,3);
year2=substr(CMDEND1D,6,4);
where CMDCAT1C = 0 and cmdnam1a ne '';
proc sort data= cmd2;by patient CLI_PLAN_EVE_NAME Subevent_Number DCI_NAME dcm_name dcm_subset_name dcm_question_grp_name rec_n qualifying_value study;run;data cmd2;set cmd2;by patient CLI_PLAN_EVE_NAME DCI_NAME ;if repeat=0 then do;                       
 if first.patient and first.CLI_PLAN_EVE_NAME then repeat_sn=0;repeat_sn+1;end;if repeat=1 then do;repeat_sn=1;if first.CLI_PLAN_EVE_NAME;end;run;proc transpose data=cmd2 out=tran_cmd2;
by patient CLI_PLAN_EVE_NAME Subevent_Number DCI_NAME dcm_name dcm_subset_name dcm_question_grp_name repeat_sn qualifying_value study;var _all_;run;data tran_cmd2;length dcm_subset_name $8;set tran_cmd2;_NAME_=upcase(_NAME_);
data cmd2(drop=variable dataset);set newdata.formats;length _name_ $21 dcm_subset_name $8;if dataset='CMD2';_name_=variable ;run;
proc sort data=cmd2;by dcm_subset_name _name_;run;proc sort data=tran_cmd2 out=cmd2_data;by dcm_subset_name _name_;run;
data occ_cmd2;merge cmd2_data cmd2;by dcm_subset_name _name_;run;proc sort data=occ_cmd2;
by patient CLI_PLAN_EVE_NAME Subevent_Number DCI_NAME dcm_name dcm_subset_name dcm_question_grp_name _name_ dcm_que_occ_sn repeat_sn ;run;
data tran.cmd2;retain patient CLI_PLAN_EVE_NAME Subevent_Number DCI_NAME dcm_name dcm_subset_name  dcm_question_grp_name  dcm_question_name dcm_que_occ_sn repeat_sn value_text qualifying_value study;
keep patient CLI_PLAN_EVE_NAME Subevent_Number DCI_NAME dcm_name dcm_subset_name  dcm_question_grp_name  dcm_question_name dcm_que_occ_sn repeat_sn value_text qualifying_value study;
length dci_name dcm_question_grp_name $30 value_text $500 qualifying_value $30; set occ_cmd2(rename=(_name_=dcm_question_name col1=value_text));
if dcm_question_name in('PATIENT','CLI_PLAN_EVE_NAME','SUBEVENT_NUMBER','DCI_NAME','DCM_NAME','DCM_SUBSET_NAME','DCM_QUESTION_GRP_NAME', 'DCM_QUE_OCC_SN','REPEAT','REPEAT_SN','REC_N','QUALIFYING_VALUE','STUDY') then delete;run;
data tran.cmd2;
set tran.cmd2;
	if repeat_sn>10 then do;dci_name='CONCOMITANT MEDICATIONS-REP';DCM_SUBSET_NAME='CMD5';QUALIFYING_VALUE='CMDG006_4';end;
run;


%gethead(cmd);
data cmd3;
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
set ct4_cmd;
patient=trim(left(put(sid1a,10.)));
cli_plan_eve_name=trim(left(put(visnam1a,20.)));
dci_name='STEROID TREATMENT';
dcm_name='CMD1';
dcm_subset_name='CMD1';
dcm_question_grp_name='GLSTDNR';
subevent_number=0;
repeat=1;
qualifying_value='CMDM004YN_625_2';
study='CFTY720D2306';
rec_n=1;
dtarep1c=trim(left(put(dtarep1c,17.)));
where CMDCAT1C = 11;
run;
proc sort data= cmd3;by patient CLI_PLAN_EVE_NAME Subevent_Number DCI_NAME dcm_name dcm_subset_name dcm_question_grp_name rec_n qualifying_value study;run;data cmd3;set cmd3;by patient CLI_PLAN_EVE_NAME DCI_NAME ;if repeat=0 then do;                       
 if first.patient and first.CLI_PLAN_EVE_NAME then repeat_sn=0;repeat_sn+1;end;if repeat=1 then do;repeat_sn=1;if first.CLI_PLAN_EVE_NAME;end;run;

proc transpose data=cmd3 out=tran_cmd3;
by patient CLI_PLAN_EVE_NAME Subevent_Number DCI_NAME dcm_name dcm_subset_name dcm_question_grp_name repeat_sn qualifying_value study;var _all_;run;

data tran_cmd3;length dcm_subset_name $8;set tran_cmd3;_NAME_=upcase(_NAME_);
data cmd3(drop=variable dataset);set newdata.formats;length _name_ $21 dcm_subset_name $8;if dataset='CMD3';_name_=variable ;run;
proc sort data=cmd3;by dcm_subset_name _name_;run;proc sort data=tran_cmd3 out=cmd3_data;by dcm_subset_name _name_;run;
data occ_cmd3;merge cmd3_data cmd3;by dcm_subset_name _name_;run;proc sort data=occ_cmd3;
by patient CLI_PLAN_EVE_NAME Subevent_Number DCI_NAME dcm_name dcm_subset_name dcm_question_grp_name _name_ dcm_que_occ_sn repeat_sn ;run;
data tran.cmd3;retain patient CLI_PLAN_EVE_NAME Subevent_Number DCI_NAME dcm_name dcm_subset_name  dcm_question_grp_name  dcm_question_name dcm_que_occ_sn repeat_sn value_text qualifying_value study;
keep patient CLI_PLAN_EVE_NAME Subevent_Number DCI_NAME dcm_name dcm_subset_name  dcm_question_grp_name  dcm_question_name dcm_que_occ_sn repeat_sn value_text qualifying_value study;
length dci_name dcm_question_grp_name $30 value_text $500 qualifying_value $30; set occ_cmd3(rename=(_name_=dcm_question_name col1=value_text)); 
if dcm_question_name in('PATIENT','CLI_PLAN_EVE_NAME','SUBEVENT_NUMBER','DCI_NAME','DCM_NAME','DCM_SUBSET_NAME','DCM_QUESTION_GRP_NAME', 'DCM_QUE_OCC_SN','REPEAT','REPEAT_SN','REC_N','QUALIFYING_VALUE','STUDY') then delete;run;
%gethead(cmd);
data cmd4;
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
keep verbatim_whodrug;
keep cmddos1a;
keep cmdunt1a;
keep cmdfrq1a;
keep cmdctu1c;
keep cmdfrq2c;
keep cmdrte1c;
keep day1;
keep month1;
keep year1;
keep day2;
keep month2 cmdunt1c;
keep year2;
set ct4_cmd;
patient=trim(left(put(sid1a,10.)));
cli_plan_eve_name=trim(left(put(visnam1a,20.)));
dci_name='STEROID TREATMENT';
dcm_name='CMD1';
dcm_subset_name='CMD1';
dcm_question_grp_name='STRR';
subevent_number=0;
repeat=0;
qualifying_value='CMDM004YN_625_2';
study='CFTY720D2306';
rec_n=rec1n;
verbatim_whodrug=trim(left(put(cmdnam1a,32.)));
cmdctu1c=trim(left(put(cmdctu1c,11.)));
cmdunt1c=trim(left(put(cmdunt1c,19.)));
cmdfrq2c=trim(left(put(cmdfrq2c,11.)));
cmdrte1c=trim(left(put(cmdrte1c,15.)));
day1=substr(CMDSTT1D,1,2);
month1=substr(CMDSTT1D,3,3);
year1=substr(CMDSTT1D,6,4);
day2=substr(CMDEND1D,1,2);
month2=substr(CMDEND1D,3,3);
year2=substr(CMDEND1D,6,4);
where CMDCAT1C = 11;
run;
proc sort data= cmd4;by patient CLI_PLAN_EVE_NAME Subevent_Number DCI_NAME dcm_name dcm_subset_name dcm_question_grp_name rec_n qualifying_value study;run;data cmd4;set cmd4;by patient CLI_PLAN_EVE_NAME DCI_NAME ;if repeat=0 then do;                       
 if first.patient and first.CLI_PLAN_EVE_NAME then repeat_sn=0;repeat_sn+1;end;if repeat=1 then do;repeat_sn=1;if first.CLI_PLAN_EVE_NAME;end;run;proc transpose data=cmd4 out=tran_cmd4;
by patient CLI_PLAN_EVE_NAME Subevent_Number DCI_NAME dcm_name dcm_subset_name dcm_question_grp_name repeat_sn qualifying_value study;var _all_;run;data tran_cmd4;length dcm_subset_name $8;set tran_cmd4;_NAME_=upcase(_NAME_);
data cmd4(drop=variable dataset);set newdata.formats;length _name_ $21 dcm_subset_name $8;if dataset='CMD4';_name_=variable ;run;
proc sort data=cmd4;by dcm_subset_name _name_;run;proc sort data=tran_cmd4 out=cmd4_data;by dcm_subset_name _name_;run;
data occ_cmd4;merge cmd4_data cmd4;by dcm_subset_name _name_;run;proc sort data=occ_cmd4;
by patient CLI_PLAN_EVE_NAME Subevent_Number DCI_NAME dcm_name dcm_subset_name dcm_question_grp_name _name_ dcm_que_occ_sn repeat_sn ;run;
data tran.cmd4;retain patient CLI_PLAN_EVE_NAME Subevent_Number DCI_NAME dcm_name dcm_subset_name  dcm_question_grp_name  dcm_question_name dcm_que_occ_sn repeat_sn value_text qualifying_value study;
keep patient CLI_PLAN_EVE_NAME Subevent_Number DCI_NAME dcm_name dcm_subset_name  dcm_question_grp_name  dcm_question_name dcm_que_occ_sn repeat_sn value_text qualifying_value study;
length dci_name dcm_question_grp_name $30 value_text $500 qualifying_value $30; set occ_cmd4(rename=(_name_=dcm_question_name col1=value_text));
if dcm_question_name in('PATIENT','CLI_PLAN_EVE_NAME','SUBEVENT_NUMBER','DCI_NAME','DCM_NAME','DCM_SUBSET_NAME','DCM_QUESTION_GRP_NAME', 'DCM_QUE_OCC_SN','REPEAT','REPEAT_SN','REC_N','QUALIFYING_VALUE','STUDY') then delete;run;

data tran.cmd4;
set tran.cmd4;
	if repeat_sn>10 then do;dci_name='STEROID TREATMENT-REP';DCM_SUBSET_NAME='CMD12';QUALIFYING_VALUE='CMDG006_4';end;
run;



data load;
retain PATIENT CLI_PLAN_EVE_NAME subevent_number DCI_NAME DCM_NAME DCM_SUBSET_NAME 
DCM_QUESTION_GRP_NAME  DCM_QUESTION_NAME DCM_QUE_OCC_SN REPEAT_SN VALUE_TEXT QUALIFYING_VALUE STUDY;
length DCM_NAME $4;
set tran.cmd1 tran.cmd2 tran.cmd3 tran.cmd4;
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
data q ;
set c;
RUN;


Data _null_;   
   file "&user\CFTY720D/CFTY720D2306/EDC_Migration/Loadable_output\EDCMigration_FileTransfer_FTY720D2306_OCRDC _OC_CMD_LOADABLE.txt" dlm='|';
   set q;
   put (_all_) (+0);
/*   where dcm_name='VSN';*/
   run;

