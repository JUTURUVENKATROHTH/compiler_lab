%{
    #include <stdio.h>
    #include <stdlib.h>
    int vars[26];
	  int yylex();
    //int yylval;
    

%}

%token NUMBER VAR
%left '+' '-'
%left '*' '/'

%%

list :
	list stmt '\n'
  | stmt  '\n'
	

	;

stmt : VAR '=' expr {vars[$1-'A'] = $3; printf("%d\n",$3); }
     | expr  {printf("%d\n", $1); }
     ;

expr : expr '+' expr {$$ = $1 + $3; }
     | expr '-' expr {$$ = $1 - $3; }
     | expr '*' expr {$$ = $1 * $3; }
     | expr '/' expr {if($3!=0)
	 					{$$ = $1 / $3;}
					  else {
						yyerror("you can't divide with zero");
						$$ = 0;
					  }
					}
     | NUMBER        {$$ = $1;}
     | VAR           {$$ = vars[$1-'A'];}
     ;
%%

int main(){
    printf("enter the expressions:\n");
    yyparse();
    return 0;
}

int yyerror(char *s){
    printf("Error:%s\n",s);
    return 0;
}

     
