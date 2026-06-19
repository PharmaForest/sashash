options obs=100;

/* ---------------------------------------------------------------------
   Bundle setup for %kvlookup
   A small master dataset (demographics) plus a transactional dataset
   that carries only the key (Name). The master shape mirrors the
   sashelp.class example shown in the package README.
   --------------------------------------------------------------------- */
data master;
  infile datalines dsd truncover;
  input Name :$12. Sex $ Age Height Weight;
  datalines;
Alfred,M,14,69.0,112.5
Alice,F,13,56.5,84.0
Barbara,F,13,65.3,98.0
Carol,F,14,62.8,102.5
Henry,M,14,63.5,102.5
James,M,12,57.3,83.0
Jane,F,12,59.8,84.5
Janet,F,15,62.5,112.5
John,M,12,59.0,99.5
Joyce,F,11,51.3,50.5
;
run;

/* transactions reference master by Name; one key is absent from master */
data txn;
  infile datalines dsd truncover;
  input Name :$12.;
  datalines;
Alice
Henry
Janet
Zelda
John
;
run;
