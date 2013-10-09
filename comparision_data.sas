/*****************************************************************************/
/* PROGRAM  : Comparison data.sas                                            */
/* AUTHOR   : Raja Sekhara Reddy S                                                */
/* DATE     : 09-Oct-2013                                                    */
/* FUNCTION : To compare the CT4 and OC datasets                             */
/*                                                                           */
/* MODIFICATION HISTORY:                                                     */
/*                                                                           */
/* Init Date        Description                                              */
/* ==== =========== ======================================================== */
/* R.S  09-Oct-2013  Initial Version                                         */
/*                                                                           */
/*****************************************************************************/


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

libname OC  "&user\CFTY720D/CFTY720D2306/EDC_Migration/ASP_OCRDC_data"; run;
libname CT  "&user\CFTY720D/CFTY720D2306/EDC_Migration/CT4_data"; run;


options fmtsearch=(OC CT work);


data CT_AEV;
set ct.aev;
aevnam1a=left(aevnam1a);
orgnam3a = trim(left(orgnam3a));
where aevnam1a ne '';
run;
data OC_AEV;
set oc.aev;
aevnam1a=left(aevnam1a);
orgnam3a = trim(left(orgnam3a));
run;

proc sort data=CT_AEV(drop=drop=STATUS ENTRYDT DB_ID CT_RECID AEVNAM3A COD1O CODCNF1A CODUSR1A  rec1n codwkf1a RPEPAG1N RPEVIS1N SAEIDN1A ORGNAM3A);
by SID1A VISNAM1A  AEVNAM1A AEVSTT1D AEVEND1D AEVCTU1C AEVSEV1C ORGNAM1A ACNTAK2N ACNTAK3N;
run;
proc sort data= OC_AEV(DROP=COD1O CODCNF1A CODUSR1A codwkf1a rec1n AEVNAM3A RPEPAG1N RPEVIS1N SAEIDN1A ORGNAM3A);
by SID1A VISNAM1A  AEVNAM1A AEVSTT1D AEVEND1D AEVCTU1C AEVSEV1C ORGNAM1A ACNTAK2N ACNTAK3N;
run;

proc compare base=CT_AEV compare=OC_AEV listbasevar listcompvar;
run;


data ct_inf (drop=STATUS ENTRYDT DB_ID CT_RECID RPEPAG1N RPEVIS1N INFNAM3A COD1O CODCNF1A CODUSR1A NSMUSR1A NSMCOD1O rec1n NSMCNF1A SAEIDN1A ORGNAM3A);
set ct.inf;
INFNAM1A = LEFT(INFNAM1A);
run;

data oc_inf(drop = RPEPAG1N RPEVIS1N INFNAM3A COD1O CODCNF1A CODUSR1A NSMUSR1A NSMCOD1O NSMCNF1A SAEIDN1A ORGNAM3A rec1N);
set OC.inf;
run;

proc sort data = ct_inf;
by SID1A VISNAM1A INFNAM1A ORGNAM1A INFSTT1D ;
run;

proc sort data = oc_inf;
by SID1A VISNAM1A INFNAM1A ORGNAM1A INFSTT1D ;
run;

proc compare base= ct_inf compare=oc_inf listbasevar listcompvar;
run;




data CT_CMD (drop=STATUS ENTRYDT DB_ID CT_RECID COD1O CODCNF1A CODUSR1A REC1N CMDNAM3A RPEPAG1N RPEVIS1N);
set ct.CMD;
cmdrsn1a=upcase(trim(left(cmdrsn1a)));
cmdnam1a=upcase(left(compress(cmdnam1a,"09"x)));
cmdunt1a=trim(left(cmdunt1a));
cmdstt1d=left(cmdstt1d);
cmdend1d=left(cmdend1d);
CMDDOS1A=LEFT(CMDDOS1A);
cmdfrq1a=left(cmdfrq1a);
where cmdnam1a ne '';
run;
data OC_CMD (Drop = COD1O CODCNF1A CODUSR1A REC1N CMDNAM3A RPEPAG1N RPEVIS1N);
set oc.CMD;
cmdrsn1a=upcase(trim(left(cmdrsn1a)));
cmdnam1a=upcase(compress(cmdnam1a,"09"x));
cmdunt1a=trim(left(cmdunt1a));
cmdstt1d=left(cmdstt1d);
cmdend1d=left(cmdend1d);
CMDDOS1A=LEFT(CMDDOS1A);
cmdfrq1a=left(cmdfrq1a);
run;
proc sort data=CT_CMD ;
by SID1A VISNAM1A CMDNAM1A cmdstt1d cmdend1d cmdctu1c CMDDOS1A CMDRSN1A CMDCAT1C  CMDUNT1A cmdfrq1a;
run;
proc sort data=OC_CMD;
by SID1A VISNAM1A CMDNAM1A cmdstt1d cmdend1d cmdctu1c CMDDOS1A CMDRSN1A CMDCAT1C CMDUNT1A cmdfrq1a;
run;

proc compare base= CT_CMD compare=OC_CMD listbasevar listcompvar;
run;




data CT_DAR (drop =  STATUS ENTRYDT DB_ID CT_RECID REC1N RPEVIS1N RPEPAG1N PAG1A);
set ct.dar;
if pag1a='DAR' and dtarep1c in (1, .) and CAPTAK1N=. then delete;
run;

proc sort data=CT_DAR ;
by sid1a visnam1a SMDSTT1D SMDEND1D DTAREP1C;
run;
data OC_DAR (drop=rec1n rpepag1n  RPEVIS1N PAG1A);
set oc.dar;
run;

proc sort data=OC_DAR ;
by sid1a visnam1a SMDSTT1D SMDEND1D DTAREP1C;
run;
proc compare base= CT_DAR compare=OC_DAR listbasevar listcompvar; 
run;


data CT_MSR (drop=STATUS ENTRYDT DB_ID CT_RECID REC1N RPEPAG1N RPEVIS1N);
set ct.msr;
if DTAREP1C = 0 then delete;
if RLPSTT1D = '' then delete;
run;
data OC_MSR (Drop = REC1N RPEPAG1N RPEVIS1N);
set oc.msr;
if DTAREP1C = 0 then delete;
if RLPSTT1D = '' then delete;
run;

proc sort data = CT_MSR;
by SID1A VISNAM1A  RLPSTT1D RLP1D HOS1C STOTHY1C SEV1C ;
run;

proc sort data = OC_MSR;
by SID1A VISNAM1A RLPSTT1D RLP1D HOS1C STOTHY1C SEV1C;
run;

proc compare base= CT_MSR compare=OC_MSR listbasevar listcompvar;
run;



data CT_dmg(drop=STATUS ENTRYDT DB_ID CT_RECID SBJDTA1C TIMPNT2N TIMPNT3N COU1A);
set CT.dmg;
run;
data OC_dmg(DROP= TIMPNT2N TIMPNT3N COU1A SBJDTA1C);
set OC.dmg;
run;
proc compare base=CT_dmg compare=OC_dmg listbasevar listcompvar;
run;



proc sort data =ct.scr out=CT_SCR1;
by sid1a exccri5c INCCRI5C descending exccri6c;
run;
data CT_SCR (drop=STATUS ENTRYDT DB_ID CT_RECID);
set CT_SCR1; 
by sid1a; if first.sid1a; run;

data OC_SCR;
set OC.scr;
run;

proc sort data = CT_SCR;
by SID1A VISNAM1A  CXRITP1C;
run;

proc sort data = OC_SCR;
by SID1A VISNAM1A  CXRITP1C;
run;

proc compare base= CT_SCR compare=OC_SCR listbasevar listcompvar;
run;





data CT_vis (DROP= STATUS ENTRYDT DB_ID CT_RECID RPEPAG1N RPEVIS1N ) ; 
set CT.vis;   
where visnam1a = 'V1 - Screening';
run; 
data OC_vis; 
set OC.vis; 

run; 
proc sort data=CT_vis; 
by sid1a  visnam1a vis1d ; 
run; 
data ct_vis; 
set ct_vis; 
by sid1a  visnam1a vis1d   ; 
if first.vis1d; 
run;

proc compare base= CT_vis compare=OC_vis listbasevar listcompvar; 
run;
