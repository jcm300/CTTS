%{

%}

%%
Dicionario: LinhaDic
          | LinhasDic ';' LinhaDic
          ;
LinhaDic:
        | LinhasDic ';' LinhaDic
        ;
LinhaDic: Palavra ':' Palavra ':' '[' ListaSin ']'
        ;
ListaSin:
        | ListaSin ';' Palavra
        ;
%%
