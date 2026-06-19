/* ---------------------------------------------------------------------
   %kduppchk  -  inline duplicate-key detector
   Macro body below is the sashash package source
   (sashash/06_macros/kduppchk.sas). On _N_=1 it builds a hash keyed on
   the supplied variables; for each subsequent row whose key is already
   present it writes a WARNING to the log and sets dupchk=1. The
   (subjid visit) combination repeats for S002/Baseline and S003/Week4.
   --------------------------------------------------------------------- */

%macro kduppchk(key);
%local name qkey;
if _N_=1 then do;
%let name = &sysindex;
%let qkey = %sysfunc( tranwrd( %str("&key") , %str( ) , %str(",") ) );
declare hash h&name();
h&name..definekey(&qkey);
h&name..definedone();
end;
if h&name..check() = 0
then do;
put "WARNING:Dupp" +2 (&key.) (=);
dupchk=1;
end;
else if cmiss(of &key) = 0 then do;
h&name..add();
end;
%mend ;

/* caller: flag duplicate (subjid, visit) combinations inline */
data checked;
  set input_data;
  dupchk = 0;
  %kduppchk(subjid visit);
run;

proc print data=checked noobs;
  title "kduppchk: dupchk=1 marks repeated (subjid, visit) keys";
run;
