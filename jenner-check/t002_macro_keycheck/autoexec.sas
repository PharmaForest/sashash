options obs=100;

/* ---------------------------------------------------------------------
   Bundle setup for %keycheck
   A master dataset of enrolled subjects, plus an incoming dataset whose
   keys we want to validate against the master in a single data step.
   --------------------------------------------------------------------- */
data master;
  infile datalines dsd truncover;
  input Name :$12. Age;
  datalines;
Alfred,14
Alice,13
Barbara,13
Carol,14
Henry,14
James,12
Janet,15
John,12
;
run;

/* incoming keys to validate; Mike and Zelda are not enrolled */
data incoming;
  infile datalines dsd truncover;
  input Name :$12.;
  datalines;
Alice
Mike
Henry
Zelda
Janet
;
run;
