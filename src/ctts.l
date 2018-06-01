%option noyywrap

%%
[.;[]:,]        {return yytext[0];}
[A-Za-z]+       {yylval.p=strdup(yytext); return pal;}
\"[^"]+\"       {yylval.s=strdup(yytext); return str;}
.|\n            {;}
%%
