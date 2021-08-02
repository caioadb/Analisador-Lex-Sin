digit[0-9]
STletter[a-zA-Z_]
AFletter[a-zA-Z_0-9]
WHITESPACE[" "]
quebra[\r]?[\n]
TAB[\t]
validsymbol[a-zA-Z_0-9\+\-\*\<\/\>\=\,\;\:\(\)\{\}\.]


%{
    #include "y.tab.h"
    
    FILE *out;
    int linha;

%}
%option yylineno
%x COMMENT


%%


{quebra}

"{" { linha=yylineno; BEGIN(COMMENT); }

<COMMENT>"}" { BEGIN(INITIAL); }

<COMMENT>(.|\n);

<COMMENT><<EOF>> {return ErroComentario;}

if {return simb_IF;}
then {return simb_THEN;}
else {return simb_ELSE;}
while {return simb_WHILE;}
do {return simb_DO;}
var {return simb_VAR;}
integer {return simb_INTEGER;}
real {return simb_REAL;}
begin {return simb_BEGIN;}
end {return simb_END;}
program {return simb_PROGRAM;}

"+" {return simb_MAIS;}
"-" {return simb_MENOS;}
"*" {return simb_ASTERISCO;}
"/" {return simb_BARRA;}
"<" {return simb_MENORQUE;}
">" {return simb_MAIORQUE;}
"<=" {return simb_MENORIGUAL;}
">=" {return simb_MAIORIGUAL;}
"=" {return simb_IGUAL;}
"<>" {return simb_DIFERENTE;}
"," {return simb_VIRGULA;}
";" {return simb_PONTOVIRGULA;}
":" {return simb_DOISPONTOS;}
":=" {return simb_ATRIBUICAO;}
"(" {return simb_ABREPARENTESES;}
")" {return simb_FECHAPARENTESES;}
"." {return simb_PONTO;}

{WHITESPACE}+|{quebra}|{TAB}+

{STletter}{AFletter}{0,14} {return ID;}

{STletter}{AFletter}{0,14}{AFletter}+ {return ErroIDTam;}
{digit}+{STletter}+{digit}* {return ErroIntForm;}
{digit}+{STletter}+{digit}*"."{digit}*|-?{digit}+"."{digit}*{STletter}+{digit}*|-?{digit}+{STletter}+{digit}*"."{digit}*{STletter}+{digit}* {return ErroRealForm;}
{digit}{1,9}{digit}* {if(yyleng > 10)return ErroTamInt; double num = atoi(yytext); if (num <= 2147483647 && num >= -2147483648) return Inteiro; else return ErroTamInt;}
{digit}{1,38}{digit}*"."{digit}+ {if (yyleng > 39)return ErroTamReal;long double num = atof(yytext); if (num <= 3.4E38 && num >= -3.4E38) return Real; else return ErroTamReal;}

[^{validsymbol}] {return ErroSimbolo;}


%%

int main(int argc, char *argv[]){
    FILE *arquivo = fopen(argv[1],"r");
    if (!arquivo) {
        printf("Arquivo nao existente\n");
        return -1;
    }
    yyin = arquivo;
    out = fopen(argv[2],"w");
    
    int tok;
    while(tok = yyparse()){}


    return 0;
}

