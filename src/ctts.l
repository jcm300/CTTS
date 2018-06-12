%option noyywrap
%option yylineno
%x DICT FILES
%{
    char *match;
%}

%%
<DICT>{
[].;[:,]        {return yytext[0];}
[A-Za-z]+       {yylval.p=strdup(yytext); return pal;}
\"[^"]+\"       {yylval.s=strndup(yytext+1,strlen(yytext+1)-1); return str;}
.|\n            {;}
}

<FILES>{
\w+             {if((match=searchTerm(yytext[0])))
                   underlineAnnotate(yytext[0],match);          
                }
.|\n
}
%%

void parseDict(){
    BEGIN DICT;
}

void parseFiles(){
    BEGIN FILES;
}

void underlineAnnotate(char *termPT, char *termEN){
    printf("\\underline{%s}\\footnote{%s}",term,termEN);
}
