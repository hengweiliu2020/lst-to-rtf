%macro lst2rtf(
  _lstfn= /*Text file to convert to RTF*/
 ,_rtffn= /*RTF file that is to be output to*/
 ,_pgwh=15840 /*Page width in twips*/
 ,_pght=12240 /*Page height in twips*/
 ,_mgns=1440 /*Margin width in twips*/
 ,_lspe=%str(\landscape) /*If landscape, need to add this value*/
 ,_fnsz=7 /*Font point size - integer*/
);
 
 options errors=0;
 data _null_;
 infile "&_lstfn" end=eof;
 length _lst $150;
 input;
 file "&_rtffn";
 if _n_=1 then do;
 put '{\rtf1\ansi\ansicpg1252\deff0\deflang1033' /
 '{\fonttbl{\f0\fmodern\fprq1\fcharset0 Courier New;}}' /
 '{\colortbl \red0\green0\blue0;}' /
 "\paperw&_pgwh.\paperh&_pght.\margl&_mgns.\margr&_mgns." /
 "\margt&_mgns.\margb&_mgns.&_lspe." /
 "\viewkind4\uc1\pard\ql\fi0\li0\ri0\sb0\sa0\sl-%eval(&_fnsz*25)" /
 "\cf0\f0\fs%eval(&_fnsz*2) \hich\af2\dbch\af31505\loch\f2 " _infile_;
 end;
 else do;
 
 if substr(_infile_,1,1)=byte(12) then do;
 _lst='\page '||substr(_infile_,2);
 put _lst;
 end;
 

 

 else if ^eof then put '\par \hich\af2\dbch\af31505\loch\f2 ' _infile_;
 else if eof then put '\par \hich\af2\dbch\af31505\loch\f2 ' _infile_ '}';
 end;
 run;
 options errors=20;
 
 %mend;




 %*lst2rtf(_lstfn=/home/hliu/macros_sdtm/FDA_request/lpat-bor-discord.lst, _rtffn=/home/hliu/macros_sdtm/FDA_request/lpat-bor-discord.rtf);
