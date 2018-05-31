%option noyywrap

%%
[.;[]:,]        {return yytext[0];}
[A-Za-z]+       {yylval.s=strdup(yytext); return str;}
.|\n            {;}

%%
