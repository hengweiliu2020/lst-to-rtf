/************************************************************
*  Author:  Hengwei Liu
**************************************************************/;

*-- count pages ;
%macro mpagenum2(input=,mls=%sysfunc(getoption(linesize)),pointer=Page#);

filename myfile "&input";

options mprint mlogic symbolgen;
   data _null_;
      infile myfile print lrecl=&mls pad missover end=eof;
      input text $ 1-&mls;
      retain totpage 0;
      if index(text,"&pointer") then totpage+1;
      ***** if eof then call symput('totpage',compress(totpage));
      if eof then call symput('totpage',compress(put(totpage,best.)));
      call symput("date",put(today(),mmddyy10.));
run;

   data _null_;
      infile myfile print lrecl=&mls pad missover sharebuffers;
      file "%sysfunc(pathname(work))\DELETEME" print ls=&mls notitles;
      length text $&mls;
      input text $char&mls..;
      put text $&mls..;
run;

   data _null_;
      infile "%sysfunc(pathname(work))\DELETEME" print lrecl=&mls pad missover sharebuffers;
      file "&input" print ls=&mls notitles;
      length text $&mls;
      input text $char&mls..;
      retain page 1;
      if index(text,"&pointer") then do;

         pageof=trim("Page "|| compress(trim(put(page, best.)) ) ||" of "||trim(put("&totpage",$10.)));
         a=(length(pageof));   
         page+1;
         substr(text,&mls-a+1) = pageof;
      end;
      put text $&mls..;
   run;
%mend ;
