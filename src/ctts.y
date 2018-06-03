%{
#include <stdlib.h>
typedef struct sinonym {
    char *sinonym;
    struct sinonym *next;
}*Sinonym;

typedef struct singleTerm{
    char *term;
    char *definition;
    char *designationEN;
    Sinonym sinonyms;
    struct singleTerm *next;
}*SingleTerm;

SingleTerm dictionary=NULL;
SingleTerm unionST(SingleTerm , SingleTerm);
Sinonym createSin(char *, Sinonym );
SingleTerm createSingleTerm(char *, char *, char *, Sinonym );

%}
%union{
    char *p;
    char *s;
    SingleTerm st;
    Sinonym sm;
}
%token <p> pal
%token <s> str

%type <p> Palavra
%type <s> Significado
%type <sm> ListaSin Sinonimos
%type <st> LinhasDic LinhaDic 
%%
Dicionario: LinhaDic LinhasDic '.'                                          {dictionary=unionST($1,$2);}
          ;
LinhasDic: %empty                                                           {$$=NULL;}
         | ';' LinhaDic LinhasDic                                           {$$=unionST($2,$3);}
         ;
LinhaDic: Palavra ':' Significado ':' Palavra ':' '[' Sinonimos             {$$=createSingleTerm($1,$3,$5,$8);}
        ;
Sinonimos: ']'                                                              {$$=NULL;}
         | Palavra ListaSin ']'                                             {$$=createSin($1,$2);}
         ;
ListaSin: %empty                                                            {$$=NULL;}
        | ',' Palavra ListaSin                                              {$$=createSin($2,$3);}
        ;
Palavra: pal                                                                {$$=$1;}
       ;
Significado: str                                                            {$$=$1;}
           ;
%%
#include "lex.yy.c"

SingleTerm unionST(SingleTerm st, SingleTerm dict){
    st->next=dict;   
    dict=st;
    return dict;
}

Sinonym createSin(char *word, Sinonym list){
    Sinonym aux = (Sinonym)malloc(sizeof(struct sinonym));
    aux->sinonym = strdup(word);
    aux->next=list;
    return aux;
}

SingleTerm createSingleTerm(char *t, char *d, char *dE, Sinonym ss){
    SingleTerm aux=(SingleTerm)malloc(sizeof(struct singleTerm));
    aux->term = strdup(t);
    aux->definition = strdup(d);
    aux->designationEN = strdup(dE);
    aux->sinonyms = ss;
    aux->next=NULL;
    return aux;
}

int yyerror(char *m){
    printf("%s in line: %d\n", m, yylineno);
}

int main(){
    yyparse();
    return 0;
}
