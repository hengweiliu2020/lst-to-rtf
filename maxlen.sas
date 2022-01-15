%macro maxlen(inds1, inds2, inds3, inds4, inds5, byvar);

* this macro remove the message multiple length were specified for the by variable;
* set the length of the by variable to be the maximum length among the datasers;
* inds1-inds5 are input datasets;
* inds1 and inds2 must have value, inds3-inds5 can be blank;
* byvar is the by variable, it is assumed to be character variable;

%let maxlen=0;

%do k=1 %to 5;
%if &&inds&k ne %then %do; 
proc contents data=&&inds&k out=m&k noprint;
run;

data m&k; set m&k; if upcase(name)=upcase("&byvar"); length&k=length; 

proc sql noprint;
select length&k into :len&k trimmed from m&k;

%if %eval(&&len&k)>%eval(&maxlen) %then %let maxlen=&&len&k;

%end;
%end;


%do k=1 %to 5;
%if &&inds&k ne %then %do;

data &&inds&k;
length &byvar $&maxlen..;
set &&inds&k;
run;

%end;
%end;


%mend;

** example; 
** %maxlen(pp,qq,,,,y);

