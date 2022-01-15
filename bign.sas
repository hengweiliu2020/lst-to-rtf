

%macro bign(classvar=, inadsl=adsl, where=);

%if &where ne %then %do;
data _&inadsl; set &inadsl;
where &where;
%end;
%else %do; 
data _&inadsl; set &inadsl;
%end;
run;

%global tot; 

proc sql noprint;
select count(distinct &classvar) into :tot trimmed from _&inadsl;

%do k=1 %to &tot; %global val&k bign&k;   %end;

proc sql noprint;
select distinct &classvar into :val1-:val&tot from _&inadsl; 
select count(distinct usubjid) into :bign1-:bign&tot from _&inadsl group by &classvar;
quit;

%mend;
