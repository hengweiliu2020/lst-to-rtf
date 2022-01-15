%macro report(indata=, outdir=);

libname outd "&outdir";
ods document name=outd.&pgm.(write);

ods listing file="&outdir\&pgm..lst"; 

proc report data=&indata headline headskip spacing=1 missing split='^';
columns tagn tag catlabel &val1 ('Active' '__' &val2 &val3);
define tagn/group noprint order; 
define tag/group noprint order; 
define catlabel/width=%eval(132-&tot*25-&tot) " " flow spacing=0;
%do k=1 %to &tot; 
define &&val&k/width=25 right "&&trt&k";
%end;

compute before tag; 
line @1 tag $100.;
endcomp;

break after tagn/skip;

run;

ods listing close; 
%mpagenum2(input=&outdir\&pgm..lst,mls=%sysfunc(getoption(linesize)),pointer=Page#);
run;
ods document close; 

%mend;
