%{
    SingleTerm **dictionary;
%}
%union{
    char *p;
    char *s;
}
%token <p> pal;
%token <s> str;
%%
Dicionario: LinhaDic LinhasDic '.'                      {}
          ;
LinhasDic:                                              {$$=NULL;}
         | ';' LinhaDic LinhasDic                       {$$=unionST($2,$3);}
         ;
LinhaDic: Palavra ':' Significado ':' '[' ListaSin ']'  {$$=createSingleTerm($1,$3,$6);}
        ;
ListaSin:                                               {$$=NULL;}
        | Palavra ',' ListaSin                          {$$=createSin($1,$3);}
        ;
Palavra: pal                                            {$$=$1;}
       ;
Significado: str
           ;
%%
#include "lex.yy.c"

typedef struct sinonym {
    char *sinonym;
    struct sinonym *next;
}*Sinonym;

typedef struct singleTerm{
    char *term;
    char *definition;
    Sinonym *sinonyms;
}*SingleTerm;

Sinonym *createSin(char *word, Sinonym *list){
    Sinonym *aux = (char **)malloc(sizeof(void*));
    *aux = strdup(word);
    aux->next=list;
    return aux;
}

SingleTerm *createSingleTerm(char *t, char *d, char *ss){
    SingleTerm *aux = (SingleTerm *)malloc(sizeof(struct singleTerm));
    aux->term = strdup(t);
    aux->definition = strdup(d);
    aux->sinonyms = ss;
    return aux;
}

int yyerror(char *m){
    printf("Erro Sintático %s\n", m);
}

int main(){
    yyparse();
    return 0;
}
