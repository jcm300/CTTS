%option noyywrap
%{
#include "ctts.tabs.h"
%}

%%
[\.;\[\]:,]     {return yytext[0];}
[A-Za-z]+       {yylval=strdup(yytext);return str;}
.|\n            {;}

%%
