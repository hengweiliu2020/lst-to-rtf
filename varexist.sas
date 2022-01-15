


*this macro checks if a variable exists in a dataset;
*creates a global macro variable result;
*result is 1 if the variable exists, 0 otherwise;

%macro VarExist(ds, var);
    %global result;
    %local rc dsid ;
    %let dsid = %sysfunc(open(&ds));
 
    %if %sysfunc(varnum(&dsid, &var)) > 0 %then %do;
        %let result = 1;
        %put NOTE: Var &var exists in &ds;
    %end;
    %else %do;
        %let result = 0;
        %put NOTE: Var &var not exists in &ds;
    %end;
 
    %let rc = %sysfunc(close(&dsid));
  
	run;
%mend VarExist;
 
