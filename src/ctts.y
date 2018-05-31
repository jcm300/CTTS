%union{
    char * s;
}
%token <s> str;

%%
Dicionario: LinhaDic LinhasDic '.'
          ;
LinhasDic:
         | ';' LinhaDic LinhasDic
         ;
LinhaDic: Palavra ':' Palavra ':' '[' ListaSin ']'
        ;
ListaSin:
        | Palavra ',' ListaSin
        ;
Palavra: str
       ;
%%
#include "lex.yy.c"

typedef struct singleTerm{
    char *term;
    char *definition;
    char *sinonyms[];
}*SingleTerm;

int yyerror(char *m){
    printf("Erro Sintático %s\n", m);
}

int main(){
    yyparse();
    return 0;
}
