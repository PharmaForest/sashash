/* ---------------------------------------------------------------------
   %kvlookup  -  hash-based key/value lookup
   Macro body below is the sashash package source
   (sashash/06_macros/kvlookup.sas), exercised by a caller that retrieves
   Age and Sex from the master into the transaction stream in a single
   data step - no sort, no merge. Keys absent from the master (Zelda)
   come back with the retrieved variables set to missing.
   --------------------------------------------------------------------- */

%macro kvlookup(master=,key=,var=,wh=,warn=N,dropviewflg=Y);
%local name qkey qvar keynum key var wh;
%let key=%sysfunc(compbl(&key));
%if %length(&var) ne 0 %then %do;
%let var=%sysfunc(compbl(&var));
%end;
if 0 then set &master(keep= &key &var);
%let name  = &sysindex;
retain _N_&name 1;
if _N_&name = 1 then do;
%if %length(&wh) ne 0 %then %do;
rc&name.=dosubl("proc sql noprint;
create view h&name.(label=%unquote(%bquote('master=&master'))) as select * from &master where &wh;
quit;");
%end;
%let qkey  = %sysfunc( tranwrd( %str("&key") , %str( ) , %str(",") ) );
%let keynum = %sysfunc( count( &key, %str ( ) ));
%if %length(&wh) ne 0 %then %do;
declare hash h&name.(dataset:"h&name.(keep= &key &var)" ,  duplicate:'E');
%end;
%else %do;
declare hash h&name.(dataset:"&master.(keep= &key &var)" ,  duplicate:'E');
%end;
h&name..definekey(&qkey);
%if %length(&var) ne 0 %then %do;
h&name..definedata(all:'Y');
%end;
h&name..definedone();
_N_&name = 0 ;
%put &=dropviewflg;
%if %length(&wh) ne 0 and %upcase(&dropviewflg) eq Y %then %do;
call execute("proc sql noprint;
drop view h&name. ;
quit;");
drop  rc&name.;
%end;
end;
drop _N_&name ;
if h&name..find() ne  0 then do;
%if %length(&var) ne 0 %then %do;
call missing(of &var );
%end;
%if %upcase( &warn )= Y %then %do;
if cmiss(of &key) ne &keynum +1 then putlog "WARNING:not exist master" +2 (&key.) (=);
%end;
end;
%mend kvlookup;

/* caller: retrieve Age and Sex from master keyed by Name */
data enriched;
  set txn;
  %kvlookup(master=master,
            key=Name,
            var=Age Sex);
run;

proc print data=enriched noobs;
  title "kvlookup: Age/Sex retrieved from master by Name";
run;
