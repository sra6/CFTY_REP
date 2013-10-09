/*****************************************************************************/
/* PROGRAM  : Blank_data.sas                                                 */
/* AUTHOR   : Raja Sekhara Reddy S                                                */
/* DATE     : 09-Oct-2013                                                    */
/* FUNCTION : To find out the blank records in CT4 datasets                  */
/*                                                                           */
/* MODIFICATION HISTORY:                                                     */
/*                                                                           */
/* Init Date        Description                                              */
/* ==== =========== ======================================================== */
/* R.S  09-Oct-2013  Initial Version                                         */
/*                                                                           */
/*****************************************************************************/

 
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


libname CT "&user\CFTY720D/CFTY720D2306/EDC_Migration/CT4_data";
libname BL "&user\CFTY720D/CFTY720D2306/EDC_Migration/BL"; 

/*aev*/
data bl.aev;
set ct.aev;
where aevnam1a eq '';
run;

/*cmd*/
data bl.cmd;
set ct.cmd;
where cmdnam1a eq '';
run;


/*dar*/
data bl.dar;
set ct.dar;
if pag1a='DAR' and dtarep1c in (1, .) and CAPTAK1N=. ;
run;


/*dmg*/
data bl.dmg;
set ct.dmg;
if sid1a eq '';
run;

/*INF*/
data bl.inf;
set ct.inf;
if sid1a eq '';
run;

/*msr*/
data bl.msr;
set ct.msr;
if DTAREP1C = 0 and RLPSTT1D = '' ;
run;

/*scr*/
proc sort data =ct.scr out=scr1;
by sid1a exccri5c INCCRI5C descending exccri6c;
run;
data scr (drop=STATUS ENTRYDT DB_ID CT_RECID);
set scr1; 
by sid1a; 
if first.sid1a = 0 ;
run;


/*vis*/
data bl.vis;
set ct.vis;
if sid1a eq '';
where visnam1a = 'V1 - Screening';
run;



