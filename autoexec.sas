options sasautos=("C:\yang2");
libname adam "C:\yang2";

%global version protocol lastfoot trt1 trt2 trt3 outdir txtfile; 
%let version=Draft; * this is the version of the TFL, can be Draft or Final;
%let protocol=compound_YYYYY; 
%let txtfile=C:\yang2\title.txt;
%let outdir=C:\yang2;

   data _null_;
      set sashelp.vextfl;
      if (substr(fileref,1,3)='_LN' or substr
         (fileref,1,3)='#LN' or substr(fileref,1,3)='SYS') and
         index(upcase(xpath),'.SAS')>0 then do;
         call symput("pgmname",trim(scan(xpath,-1,'\')));
         call symput('pgm',scan(trim(scan(xpath,-1,'\')),1, '.'));
         stop;
      end;
run;

data _null_;
      call symput("fdate",left(put("&sysdate"d,yymmdd10.)));
   run;

data temp;
prog_source="Program Source: &pgmname";
sdatec="Executed: (&version) &fdate";
leng1=length(prog_source);
leng2=length(sdatec);
leng3=132-leng1-leng2; 
call symput("leng3", put(leng3, best.));
run;

data _null_;
length space3 $&leng3..; 
set temp; 
space3=repeat('', leng3);
lastfoot=prog_source||space3||sdatec; 
call symput("lastfoot", trim(left(lastfoot)));
run;
 


