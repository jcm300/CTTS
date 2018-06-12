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
    int refCount;
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
Dicionario: LinhaDic LinhasDic '.'                                 {dictionary=unionST($1,$2);}
          ;
LinhasDic:                                                         {$$=NULL;}
         | ';' LinhaDic LinhasDic                                  {$$=unionST($2,$3);}
         ;
LinhaDic: Palavra ':' Significado ':' Palavra ':' '[' Sinonimos    {$$=createSingleTerm($1,$3,$5,$8);}
        ;
Sinonimos: ']'                                                     {$$=NULL;}
         | Palavra ListaSin ']'                                    {$$=createSin($1,$2);}
         ;
ListaSin:                                                          {$$=NULL;}
        | ',' Palavra ListaSin                                     {$$=createSin($2,$3);}
        ;
Palavra: pal                                                       {$$=$1;}
       ;
Significado: str                                                   {$$=$1;}
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
    aux->refCount=0;
    aux->sinonyms = ss;
    aux->next=NULL;
    return aux;
}

char *searchTerm(char *term){
    SingleTerm dictAux=dictionary;  
    Sinonym sinAux=NULL;
    char *termEN=NULL;

    while(dictAux && !termEN){ 
        if(!strcmp(dictAux->term,term))
            termEN=dictAux->designationEN;
        sinAux=dictAux->sinonyms;
        while(sinAux && !termEN){
            if(strcmp(sinAux->sinonym,term))
                termEN=dictAux->designationEN;
            sinAux=sinAux->next;
        }
        dictAux=dictAux->next;
    }

    return termEN;
}

void beginLatex(FILE *f){
    fprintf(f,"\\documentclass{article}\n");
    fprintf(f,"\\usepackage[bottom]{footmisc}\n");
    fprintf(f,"\n\\begin{document}\n");
}

void makeAppendix(FILE *f){
    SingleTerm aux = dictionary;
    
    fprintf(f,"\n\\appendix\n");
    fprintf(f,"\\begin{itemize}\n");

    while(aux){
        if(aux->refCount>0){
            fprintf(f,"\\item %s Def: %s\n",aux->term,aux->definition);
            aux->refCount=0;
        }
        aux=aux->next;
    }
    
    fprintf(f,"\\end{itemize}\n");
    fprintf(f,"\n\\end{document}\n");
}

int yyerror(char *m){
    printf("%s in line: %d\n", m, yylineno);
}

//TODO: allow the user to specify whether it wants to overwrite the file being parsed
int main(int argc, char **argv){
    if(argc>2){
        yyin = fopen(argv[1],"r");
        if(yyin){
            parseDict();        //BEGIN DICT on flex
            yyparse();
            fclose(yyin);
            
            if(yynerrs==0){     //check if any syntax where found by yacc
                parseFiles();   //BEGIN FILES on flex
                for(int i=2; i<argc; i++){
                    yyin = fopen(argv[i],"r");
                    if(yyin){
                        yyout = fopen(".aux","w");
                        beginLatex(yyout);
                        yylex();
                        makeAppendix(yyout);
                        fclose(yyin);
                        fclose(yyout);
                        remove(argv[i]);
                        rename(".aux",argv[i]);
                    }else{
                        fprintf(stderr,"File %s was not found. Parsing will resume.\n",argv[i]);
                    }   
                }
            }else{
                fprintf(stderr,"Files not parsed. Fix the bugs on your dictionary file.\n");
            }
        }else{
            fprintf(stderr,"Dictionary file doesn't exist.\n");
        }   
    }else{
        fprintf(stderr,"Few arguments.\n");
    }

    return 0;
}
