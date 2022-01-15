%macro onelevel(tagn=, tag=, indata=, outdata=, classvar=, level1=, percent=Y, where=, indent=, indent2=N, wheref=&where); 

%if &where ne %then %do; 
data _&indata; set &indata;
where &where; 
run;
%end;
%else %do;
data _&indata; set &indata;
run;
%end;

%global any_rec;
proc sql noprint;
select count(*) into: any_rec from _&indata; 

%if &any_rec=0 %then %do;
data &outdata; 
tagn=.;
tag=' ';
catlabel=' ';
indent=' ';
indent2=' ';
%do k=1 %to &tot; &&val&k=' '; %end;

run; 
%end;

%else %do; 

proc sql;
create table lev1 as 
select distinct &level1, &classvar, count(distinct usubjid) as n from _&indata
group by &level1, &classvar; 

proc transpose data=lev1 out=tlev1; 
id &classvar;
var n;
by &level1;
run;

data tlev1; length catlabel $100.; set tlev1; catlabel=&level1; indent="&indent"; indent2="&indent2";

proc sort data=tlev1; by catlabel;
run;

%do k=1 %to &tot;
%varexist(tlev1, &&val&k);
%if &result=0 %then %do;
data tlev1; set tlev1; 
&&val&k=.;
%end;
%end;

data &outdata(drop= %do k=1 %to &tot; &&val&k %end; ); 
length %do k=1 %to &tot; &&val&k..c  %end; $30. tag $100.; 
set tlev1; 
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
run;

data &outdata; 
set &outdata; 
rename %do k=1 %to &tot; &&val&k..c=&&val&k %end;; 
run;

proc sql;
create table frame as 
select distinct &level1 as catlabel from &indata %if &wheref ne %then %do; where &wheref %end;;


%maxlen(&outdata, frame, ,,, catlabel);

data &outdata;
merge &outdata frame;
by catlabel;
%do m=1 %to &tot;
if grp&m=' ' then grp&m='0';
%end;
tagn=&tagn; 
run;

proc sort data=&outdata;
by tagn catlabel;
run;
%end;

%mend;
