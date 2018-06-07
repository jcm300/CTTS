%option noyywrap
%option yylineno
%x DICT FILES

%%
<DICT>{
[].;[:,]        {return yytext[0];}
[A-Za-z]+       {yylval.p=strdup(yytext); return pal;}
\"[^"]+\"       {yylval.s=strndup(yytext+1,strlen(yytext+1)-1); return str;}
.|\n            {;}
}

<FILES>{

}
%%

void parseDict(){
    BEGIN DICT;
}

void parseFiles(){
    BEGIN FILES;
}
