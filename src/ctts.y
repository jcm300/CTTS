%{

%}

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
