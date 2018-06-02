%{
    SingleTerm *dictionary=(SingleTerm*)malloc(sizeof(SingleTerm));
    *dictionary=NULL;
%}
%union{
    char *p;
    char *s;
    SingleTerm *st;
    Sinonym *sm;
}
%token <p> pal;
%token <s> str;

%type <p> Palavra
%type <s> Significado
%type <sm> ListaSin
%type <st> LinhasDic LinhaDic 
%%
Dicionario: LinhaDic LinhasDic '.'                      {dictionary=unionST($1,$2);}
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
    struct singleTerm *next;
}*SingleTerm;

SingleTerm *unionST(SingleTerm* st, SingleTerm* dict){
    (*st)->next=*dict;   
    dict=st;
    return dict;
}

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
    aux->next=NULL;
    return aux;
}

int yyerror(char *m){
    printf("Erro Sintático %s\n", m);
}

int main(){
    yyparse();
    return 0;
}
