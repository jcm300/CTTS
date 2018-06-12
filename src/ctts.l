%option noyywrap
%option yylineno
%x DICT FILES
%{
    char *match;
    char *searchTerm(char*);
    void underlineAnnotate(char*,char*);
%}

%%
<DICT>{
[].;[:,]        {return yytext[0];}
[A-Za-z]+       {yylval.p=strdup(yytext); return pal;}
\"[^"]+\"       {yylval.s=strndup(yytext+1,strlen(yytext+1)-1); return str;}
.|\n            {;}
}

<FILES>{
[A-Za-z]+       {if((match=searchTerm(yytext)))
                    underlineAnnotate(yytext,match);          
                 else fprintf(yyout,"%s",yytext);
                }
}
%%

void parseDict(){
    BEGIN DICT;
}

void parseFiles(){
    BEGIN FILES;
}

void underlineAnnotate(char *termPT, char *termEN){
    fprintf(yyout,"\\underline{%s}\\footnote{%s}",termPT,termEN);
}
