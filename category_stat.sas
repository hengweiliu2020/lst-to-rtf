%macro category_stat(byvarn=, byvar=, tagn=, tag=, category=, catlabel=, indata=, invar=, classvar=, 
                    outdata=, percent=Y, where=, missing=, indent=N, indent2=N, countby=distinct usubjid);

%if &where ne %then %do; 
data _&indata; set &indata;
where &where; 
run;
%end;
%else %do;
data _&indata; set &indata;
run;
%end;

%if &missing=Y %then %do;
data _&indata; set _&indata;
if &invar=' ' then &invar='MISSING';
%end;
%else %do;
data _&indata; set _&indata;
if &invar=' ' then delete;
%end;

data get_cat; 
length catlabel $100.;
categ="&category";
catlab="&catlabel";
indent="&indent";
indent2="&indent2";
numcat=countw(categ,'#') ;
do k=1 to numcat;
catn=k;
&invar=scan(categ, k, '#');
if catlab>' ' then catlabel=scan(catlab, k, '#');
output;
end;
run;

%if &byvar ne %then %do;
proc sql noprint;
create table frame as 
select distinct &byvarn, &byvar from _&indata;

data _null;
set frame end=eof; 
i+1;
call symput(compress("byvarn"||put(i, best.)), trim(left(put(&byvarn,best.))));
call symput(compress("byvar"||put(i, best.)), trim(left(&byvar)));
if eof then call symput("totby", trim(left(put(_n_, best.))));
run;

data get_cat; 
length &byvar $100.;
set get_cat;
%do f=1 %to &totby;
&byvarn=&&byvarn&f;
&byvar="&&byvar&f"; 
output;
%end;

%end;


%if &classvar ne &invar %then %do;
proc sql;
create table out1 as 
select distinct %if &byvar ne %then %do; &byvarn, &byvar, %end; 
       &classvar, &invar, count(&countby) as cn from _&indata 
group by &classvar, &invar %if &byvar ne %then %do; ,&byvarn, &byvar %end;;
%end;
%else %do;
proc sql;
create table out1 as 
select distinct %if &byvar ne %then %do; &byvarn, &byvar, %end; 
       &classvar, count(&countby) as cn from _&indata 
group by &classvar %if &byvar ne %then %do; ,&byvarn, &byvar %end;;
%end;

proc sort data=out1; by &invar &byvarn &byvar;

proc transpose data=out1 out=out_&invar;
var cn;
by &invar &byvarn &byvar;
id &classvar;
run;


%maxlen(out_&invar, get_cat, ,,, &invar);
%if &byvar ne %then %do;
%maxlen(out_&invar, get_cat, ,,, &byvar);
%end;

proc sort data=get_cat; by &invar &byvarn &byvar;

%do k=1 %to &tot;
%varexist(out_&invar, &&val&k);
%if &result=0 %then %do;
data out_&invar; set out_&invar;
&&val&k=.;
%end;
%end; 

data &outdata(keep=indent indent2 catn tag tagn catlabel %do k=1 %to &tot; &&val&k..c %end; 
%if &byvarn ne %then %do; byvarn %end; 
%if &byvar ne %then %do; byvar %end;);
length %do k=1 %to &tot; &&val&k..c  %end; $30. tag $100.; 
merge out_&invar get_cat(in=a);
by &invar &byvarn &byvar;
if a; 
stat=&invar;
%do y=1 %to &tot;
if &&val&y<.z then &&val&y..c='0';
else do;
percent=put(100*&&val&y/&&bign&y,5.1);
%if &percent=Y %then %do;
&&val&y..c=strip(put(&&val&y, best.))||' ('||percent||')';
%end;
%else %do;
&&val&y..c=strip(put(&&val&y, best.));
%end;
end;
%end;
tag="&tag";
tagn=&tagn;
%if &byvarn ne %then %do; byvarn=&byvarn; %end;
%if &byvar ne %then %do; length byvar $100.; byvar=&byvar; %end;
run;

data &outdata; 
set &outdata; 
rename %do k=1 %to &tot; &&val&k..c=&&val&k %end;; 

proc sort data=&outdata ; by catn;
run;

%mend;







