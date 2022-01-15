

data adsl; set adam.adsl; 
if trt01p='Placebo' then trt='trt1';
else if trt01p='Active_low' then trt='trt2';
else if trt01p='Active_high' then trt='trt3';
run;

%bign(classvar=trt); 
%category_stat(byvarn=, byvar=, tagn=1, tag=Any Metastatic Disease, category=Y#N, catlabel=Yes#No, indata=adsl, invar=metafl, 
              classvar=trt, outdata=p1, percent=Y, where=, missing=, indent=Y, indent2=N, countby=distinct usubjid);

%onelevel(tagn=2, tag=Location of Metastatic Disease, indata=adsl, outdata=p2, classvar=trt, level1=metaloc, percent=Y, 
           where=%str(metaloc>' '), indent=Y, indent2=N, wheref=&where); 

%onelevel(tagn=2, tag=Location of Metastatic Disease, indata=adsl, outdata=p3, classvar=trt, level1=specify, percent=Y, 
           where=%str(specify>' '), indent=Y, indent2=Y, wheref=&where); 


data final; set p1 p2 p3; 
if indent='Y' then catlabel=' '||catlabel;
if indent2='Y' then catlabel='  '||catlabel; 

%let trt0=; 
%let trt1=Placebo^(N=&bign1);
%let trt2=Low Dose^(N=&bign2);
%let trt3=High Dose^(N=&bign3);

%title_foot2(txtfile=&txtfile, tabno=14.5.1);
%report(indata=final, outdir=&outdir);
%lst2rtf(
  _lstfn=&outdir\&pgm..lst
 ,_rtffn=&outdir\&pgm..rtf);



