%option noyywrap
%option yylineno
%%
[].;[:,]        {return yytext[0];}
[A-Za-z]+       {yylval.p=strdup(yytext); return pal;}
\"[^"]+\"       {yylval.s=strndup(yytext+1,strlen(yytext+1)-1); return str;}
.|\n            {;}
%%
