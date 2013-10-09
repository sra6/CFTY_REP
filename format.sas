/*****************************************************************************/
/* PROGRAM  : Format.sas                                                     */
/* AUTHOR   : Raja Sekahra Reddy                                                */
/* DATE     : 09-Oct-2013                                                    */
/* FUNCTION : To download the formats from CT4 to work library               */
/*                                                                           */
/* MODIFICATION HISTORY:                                                     */
/*                                                                           */
/* Init Date        Description                                              */
/* ==== =========== ======================================================== */
/* R.S  09-Oct-2013  Initial Version                                         */
/*                                                                           */
/*****************************************************************************/

proc download incat=data_s.formats outcat=work.formats; 
run;

