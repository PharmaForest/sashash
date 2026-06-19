options obs=100;

/* ---------------------------------------------------------------------
   Bundle setup for %kduppchk
   A small subject/visit dataset that intentionally contains duplicate
   (subjid, visit) key combinations so the duplicate-key detector fires.
   --------------------------------------------------------------------- */
data input_data;
  infile datalines dsd truncover;
  input subjid :$4. visit :$8.;
  datalines;
S001,Baseline
S001,Week4
S002,Baseline
S002,Baseline
S003,Baseline
S003,Week4
S003,Week4
S004,Baseline
;
run;
