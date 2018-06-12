%{
#include <stdlib.h>
#include <ctype.h>
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
int yylex();
int yyerror(char *m);
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

int strcmpCInsensitive(char *s1, char *s2){
    int i=0, eq=1;

    while(s1[i] && s2[i] && (eq=(tolower(s1[i])==tolower(s2[i]))))
        i++;
    
    return (s1[i] || s2[i]) || !eq;
}

char *searchTerm(char *term){
    SingleTerm dictAux=dictionary;  
    Sinonym sinAux=NULL;
    char *termEN=NULL;

    while(dictAux && !termEN){ 
        if(!strcmpCInsensitive(dictAux->term,term))
            termEN=dictAux->designationEN;
        sinAux=dictAux->sinonyms;
        while(sinAux && !termEN){
            if(!strcmpCInsensitive(sinAux->sinonym,term))
                termEN=dictAux->designationEN;
            sinAux=sinAux->next;
        }
        dictAux=dictAux->next;
    }
    if(termEN) dictAux->refCount ++;

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
    fprintf(f,"\\section{Apendice}\n"); 
    fprintf(f,"\\begin{itemize}\n");

    while(aux){
        if(aux->refCount>0){
            fprintf(f,"\\item %s $\\to$ Def: %s\n",aux->term,aux->definition);
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

int getOutputFileName(char outfile[],int argc, char **argv, int i){
    if(i+1<argc && argv[i+1][0]=='-'){        //found a flag
        i++; 
        switch(argv[i][1]){
            case 'o':
                i ++;
                if(i<argc){
                    outfile[0]=0;
                    strcat(outfile,argv[i]);
                }else fprintf(stderr,"The -o flag requires an extra argument, please check the manual for usage\nWriting to the default output...\n");
                break;
            default:
                fprintf(stderr,"%s is not a valid flag, please check the manual for usage\n", argv[i]);
                break;
        }
    }
    return i;
}



int main(int argc, char **argv){
    char outfile[100];

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
                        outfile[0]=0;
                        strcat(outfile,argv[i]);
                        i=getOutputFileName(outfile,argc,argv,i); 
                        strcat(outfile,".tex");
                        yyout = fopen(outfile,"w");
                        beginLatex(yyout);
                        yylex();
                        makeAppendix(yyout);
                        fclose(yyin);
                        fclose(yyout);
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
