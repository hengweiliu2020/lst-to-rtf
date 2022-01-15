
                                                          
*read the title footnote file in txt format and create macro variables;

%macro title_foot2(txtfile=, tabno=);

options FORMCHAR='|_---|+|---+=|-/\<>*'  nodate nonumber nocenter mprint mlogic symbolgen orientation=landscape
     ls=132 ps=52;    
%global tl1 tl2 hline;

   
   data _null_;
      set sashelp.vextfl;
      if (substr(fileref,1,3)='_LN' or substr
         (fileref,1,3)='#LN' or substr(fileref,1,3)='SYS') and
         index(upcase(xpath),'.SAS')>0 then do;
         call symput("pgmname",trim(scan(xpath,-1,'\')));
         call symput('pgm',scan(trim(scan(xpath,-1,'\')),1, '.'));
         stop;
      end;

data spec;
company="Hengrui USA";
pgmname="Program Name: &pgmname";
protocol="Protocol No.: &protocol";


pagenum='Page#';
len1=132-length(company)-length(pagenum);
len2=132-length(protocol);
call symput('len1', put(len1, best.));
call symput('len2', put(len2, best.));
run;

data spec; 
length space1 $&len1.. space2 $&len2..  ;
set spec; 
space1=repeat(' ',len1);
space2=repeat(' ',len2);
hline=repeat('_',132);

t1=company||space1||pagenum;
t2=protocol||space2;

call symput('tl1', trim(left(t1)));
call symput('tl2', trim(left(t2)));
call symput('hline', trim(left(hline)));
run;

data titlef;
      infile "&txtfile" print lrecl=132 pad missover end=eof;
      input text $ 1-132;
      y=index(upcase(substr(text,1,5)),'TABLE') + index(upcase(substr(text,1,7)),'LISTING') + index(upcase(substr(text,1,6)),'FIGURE');
      if substr(upcase(text),1,4)='NOTE' then foot=2;
      if y>0 then num=compress(scan(text,2,' '),':');
      
      data titlef; set titlef;
      retain temp1 ;
      if num>' '  then temp1= num;
      else num=temp1;
      if text=' ' then delete;
      
      proc sort data=titlef; by num;
      
      data titlef; set titlef;
      by num;
      retain temp2;
      if first.num then temp2=.;
      if foot>0 then temp2=foot;
      else foot=temp2;
      if foot<.z then foot=1;
     
      
      data titlef; set titlef;
      where num="&tabno";
      lentext=length(text);
      len1=int((132-lentext)/2);
      len2=132-lentext-len1;
      text=repeat(' ',len1)||text||repeat(' ',len2);
      run;
      
      data _null_;
      set titlef end=eof;
      where foot=1;
      i+1;
      call symput(compress("tle"||put(i, best.)), text);
      if eof then call symput('numtle', trim(left(put(_n_, best.))));
      run;
      
      
      title1 "&tl1";
      title2 "&tl2";
      %do k=1 %to &numtle;
      title%eval(2+&k) "&&tle&k";
      %end;
      title%eval(2+&numtle+1) "&hline";
      run;
      
      
      proc sql noprint;
      select count(*) into :footobs from titlef where foot=2;
      
      %if &footobs=0 %then %do;
      footnote1 "&hline";
      footnote2 "&lastfoot";
      %end;
      
      %else %do;
      
      data _null_;
      set titlef end=eof;
      where foot=2;
      i+1;
      call symput(compress("fot"||put(i, best.)), trim(left(text)));
      if eof then call symput('numfot', trim(left(put(_n_, best.))));
      run;
      
      footnote1 "&hline";
      %do i=1 %to &numfot;
      footnote%eval(1+&i) "&&fot&i";
      %end;
      footnote%eval(&numfot+2) "&lastfoot";
      %end;
   
%mend;

