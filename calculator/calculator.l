%{
    #include "y.tab.h"
    #include <stdio.h>
    #include <stdlib.h>
  
    #define YYSTYPE int
    //extern int yylval;
    
%}
digit [0-9]+
vari [A-Z]
tab [\t ]+
assign "="
nl \n
%%
{vari}       {yylval = yytext[0];return VAR;}
{digit}     {yylval = atoi(yytext);return NUMBER;}
{tab}       {}
{assign}    {return '=';}
[+*/-]      { return yytext[0]; } // Match arithmetic operators
{nl}        { return '\n'; } // Match newlines
.      {return yytext[0];}
%%

int yywrap(){
    return 1;
}
