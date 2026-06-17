/* ---------------------------------------------------------------------
   %keycheck  -  hash-based key existence check
   Macro body below is the sashash package source
   (sashash/06_macros/keycheck.sas), exercised by a caller that flags
   whether each incoming Name exists in the master, in a single data
   step. cat=YN returns 'Y'/'N'; the macro builds the hash once on _N_=1.
   --------------------------------------------------------------------- */

%macro keycheck(master=, wh=, key=,fl=,cat=YN,dropviewflg=Y);
%let name  = &sysindex;
%let qkey  = %sysfunc( tranwrd( %str("&key") , %str( ) , %str(",") ) );
if 0 then set &master(keep= &key);
if _N_=1 then do;
%if %length(&wh) ne 0 %then %do;
rc&name.=dosubl("proc sql noprint;
create view h&name.(label=%unquote(%bquote('master=&master'))) as select * from &master where &wh;
quit;");
drop rc&name.;
%end;
%if %length(&wh) ne 0 %then %do;
declare hash h&name.(dataset:"h&name.(keep= &key)" ,  multidata:'Y');
%end;
%else %do;
declare hash h&name.(dataset:"&master(keep= &key)", multidata:'Y');
%end;
h&name..definekey(&qkey);
h&name..definedone();
%if %length(&wh) ne 0 and %upcase(&dropviewflg) eq Y %then %do;
call execute("proc sql noprint;
drop view h&name. ;
quit;");
%end;
end;
&fl = ifc(h&name..check()=0,"Y","N");
%if &cat=Y %then %do; if &fl="N" then &fl=""; %end;
%if &cat=NUM %then %do;
if &fl ="Y" then &fl.n=1;
if &fl ="N" then &fl.n=0;
%end;
%mend keycheck;

/* caller: flag whether each incoming Name exists in the master */
data validated;
  set incoming;
  %keycheck(master=master,
            key=Name,
            fl=exist_flag,
            cat=YN);
run;

proc print data=validated noobs;
  title "keycheck: exist_flag = Y when Name is enrolled in master";
run;
