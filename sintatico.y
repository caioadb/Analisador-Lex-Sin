%{
#include<stdio.h>
#include<stdlib.h>
#include "y.tab.h"
#include<string.h>

extern int yylex(void);
extern int yylineno;
extern char *yytext;
extern FILE *out;
void yyerror(char *s);
int linAnt;
int  errorFound;
%}

%start program

%token ErroComentario
%token ErroSimbolo
%token ErroRealForm
%token ErroIntForm
%token ErroLiteralForm
%token ErroIDTam
%token ErroTamInt
%token ErroTamReal


%token simb_IF simb_THEN simb_ELSE simb_WHILE simb_DO simb_VAR simb_BEGIN simb_END simb_PROGRAM
%token simb_INTEGER simb_REAL
%token simb_MAIS simb_MENOS simb_ASTERISCO simb_BARRA simb_MENORQUE simb_MAIORQUE simb_MENORIGUAL simb_MAIORIGUAL simb_IGUAL simb_DIFERENTE
%token simb_VIRGULA simb_PONTOVIRGULA simb_DOISPONTOS simb_ATRIBUICAO simb_ABREPARENTESES simb_FECHAPARENTESES simb_PONTO

%token Inteiro
%token Real
%token ID


%%      /* inicio  da secao de regras */

program : linePV
     |
     ;

/* tipos de linha que terminam em ';'*/
linePV : DECLARATION simb_PONTOVIRGULA
     | PROGRAM_START simb_PONTOVIRGULA
     | ASSIGNMENT simb_PONTOVIRGULA
     | FUNC_CALL simb_PONTOVIRGULA
     | simb_END simb_PONTOVIRGULA
     | line                                  {linAnt = yylineno;errorFound = 0;}
     /* permitindo recursao */
     | linePV DECLARATION simb_PONTOVIRGULA
     | linePV PROGRAM_START simb_PONTOVIRGULA
     | linePV ASSIGNMENT simb_PONTOVIRGULA
     | linePV FUNC_CALL simb_PONTOVIRGULA
     | linePV simb_END simb_PONTOVIRGULA
     | linePV line                           {linAnt = yylineno;errorFound = 0;}
     /* tratamento de erros genericos*/
     | linePV error
     ;

/* tipos de linha que nao terminam em ';'*/
line : simb_BEGIN
     | simb_WHILE EXPRESSION simb_DO
     | simb_END simb_PONTO
     | CONDITIONAL
     /*tratamento de erros especificos*/
     | simb_END {fprintf(out, "Erro Sintatico - END seguido por \'\\n\' na linha %d\n", yylineno);errorFound = 1;}
     ;

/*declaracao de variavel*/
DECLARATION : simb_VAR IDENT simb_DOISPONTOS simb_INTEGER
     | simb_VAR IDENT simb_DOISPONTOS simb_REAL
     /*tratamento de erros especificos*/
     | simb_VAR simb_DOISPONTOS simb_INTEGER      {fprintf(out, "Erro Sintatico - Declaracao faltando ID na linha %d\n", yylineno);errorFound = 1;}
     | simb_VAR simb_DOISPONTOS simb_REAL         {fprintf(out, "Erro Sintatico - Declaracao faltando ID na linha %d\n", yylineno);errorFound = 1;}
     | simb_VAR IDENT simb_DOISPONTOS             {fprintf(out, "Erro Sintatico - Declaracao faltando valor na linha %d\n", yylineno);errorFound = 1;}
     | simb_VAR IDENT simb_INTEGER                {fprintf(out, "Erro Sintatico - Declaracao faltando \':\' na linha %d\n", yylineno);errorFound = 1;}
     | simb_VAR IDENT simb_REAL                   {fprintf(out, "Erro Sintatico - Declaracao faltando \':\' na linha %d\n", yylineno);errorFound = 1;}
     ;

/*atribuicao de valor*/
ASSIGNMENT : ID simb_ATRIBUICAO EXPRESSION
          /*tratamento de erros especificos*/
          | ID simb_ATRIBUICAO {fprintf(out, "Erro Sintatico - Atribuicao faltando expressao na linha %d\n", yylineno);errorFound = 1;}
          | ID simb_IGUAL {fprintf(out, "Erro Sintatico - Simbolo de Atribuicao incompleto na linha %d\n", yylineno);errorFound = 1;}
          | ID simb_DOISPONTOS {fprintf(out, "Erro Sintatico - Simbolo de Atribuicao incompleto na linha %d\n", yylineno);errorFound = 1;}
          | ID EXPRESSION {fprintf(out, "Erro Sintatico - ID seguido de expressao na linha %d\n", yylineno);errorFound = 1;}
          ;
/*estrutura if then*/
CONDITIONAL : simb_IF EXPRESSION simb_THEN
          /*tratamento de erros especificos*/
          | simb_IF simb_THEN                     {fprintf(out, "Erro Sintatico - Estrutura IF/THEN faltando expressao na linha %d\n", yylineno);errorFound = 1;}
          | simb_IF EXPRESSION                    {fprintf(out, "Erro Sintatico - Estrutura IF/THEN faltando THEN na linha %d\n", yylineno);errorFound = 1;}
          ; 

/*invocacao de funcao*/
FUNC_CALL : ID simb_ABREPARENTESES EXPRESSION simb_FECHAPARENTESES
          | ID simb_ABREPARENTESES IDENT simb_FECHAPARENTESES
          | ID simb_ABREPARENTESES simb_FECHAPARENTESES
          /*tratamento de erros especificos*/
          | ID simb_ABREPARENTESES EXPRESSION     {fprintf(out, "Erro Sintatico - Invocacao de funcao faltando \')\' na linha %d\n", yylineno);errorFound = 1;}
          ;

/*expressao*/
EXPRESSION : VALUE RELATIONAL_OP VALUE

          | VALUE MATH_OP VALUE

          /*tratamento de erros especificos*/
          | VALUE RELATIONAL_OP              {fprintf(out, "Erro Sintatico - expressao faltando relacao na linha %d\n", yylineno);errorFound = 1;}

          | VALUE MATH_OP                    {fprintf(out, "Erro Sintatico - expressao faltando relacao na linha %d\n", yylineno);errorFound = 1;}

          ;

/*operacao de relacao*/
RELATIONAL_OP : simb_IGUAL
          | simb_DIFERENTE
          | simb_MENORQUE
          | simb_MAIORQUE
          | simb_MENORIGUAL
          | simb_MAIORIGUAL
          ;

/*relacao matematica*/
MATH_OP : simb_MAIS
          | simb_MENOS
          | simb_ASTERISCO
          | simb_BARRA
          ;

/*identificadores*/
IDENT : ID
     | ID simb_VIRGULA IDENT
     /*tratamento de erros especificos*/
     | ID IDENT                  {fprintf(out, "Erro Sintatico - Erro de separacao de IDs na linha %d\n", yylineno);errorFound = 1;}
     ;

/*valor*/
VALUE : Inteiro
     | Real
     | ID
     | ERRO_LEX
     ;

/*program id;*/
PROGRAM_START : simb_PROGRAM ID
     /*tratamento de erros especificos*/
     | simb_PROGRAM           {fprintf(out, "Erro Sintatico - Declaracao de programa faltando ID na linha %d\n", yylineno);errorFound = 1;}
     ;

/* erros lexicos */
ERRO_LEX : ErroComentario     {fprintf(out, "Erro Lexico - Comentario nao fechado na linha %d\n", yylineno);}
          | ErroSimbolo       {fprintf(out, "Erro Lexico - Simbolo nao pertencente a linguagem na linha %d\n", yylineno);}
          | ErroRealForm      {fprintf(out, "Erro Lexico - Numero real mal formado na linha %d\n", yylineno);}
          | ErroIntForm       {fprintf(out, "Erro Lexico - Numero inteiro mal formado na linha %d\n", yylineno);}
          | ErroIDTam         {fprintf(out, "Erro Lexico - Tamanho excessivo de identificador na linha %d\n", yylineno);}
          | ErroTamInt        {fprintf(out, "Erro Lexico - Tamanho excessivo de numero inteiro na linha %d\n", yylineno);}
          | ErroTamReal       {fprintf(out, "Erro Lexico - Tamanho excessivo de numero real na linha %d\n", yylineno);}
          ;

%%

/* Erros genericos*/
void yyerror(char *s){
     /* Erro de falta de ';'*/
     if (errorFound == 1) return;
     extern int yychar;
     if (linAnt != yylineno && yychar > ErroTamReal){
          fprintf(out, "Erro Sintatico - token \'%s\' inesperado na linha %d: esqueceu \';\' na linha anterior?\n", yytext, yylineno);
     }
     /* Erro generico */
     else if (yychar > ErroTamReal)
          fprintf(out, "Erro Sintatico - token \'%s\' inesperado na linha %d: %s\n", yytext, yylineno, s);
     return;
}
