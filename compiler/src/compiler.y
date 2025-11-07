/*
 *   This file is part of SIL Compiler.
 *
 *  SIL Compiler is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  SIL Compiler is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with SIL Compiler.  If not, see <http://www.gnu.org/licenses/>.
 */

%{	
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include <limits.h>
	#include "../include/AST.h"
	#include "y.tab.h"
    // #define YYSTYPE TNode*
	int yylex();
	void yyerror( char* );
        int i;	
	struct SymolTable* root = NULL;
	struct ASTNode* forest = NULL;

	// struct ASTNode* rootAST = NULL;
	//struct for Nodes in syntax tree
	// typedef struct TNode{
	// 	char* nodetype;
	// 	struct TNode* left;
	// 	struct TNode* right;
	// 	int value;
	// } TNode;

	//struct for symbol table
	// typedef struct symbol_entry{
	// 	char* name;
	// 	int value;
	// 	int isDefined;
	// 	struct symbol_entry* next;
	// } symbol_entry;

	// symbol_entry*  SYM_TABLE = NULL;

	// Node creation function
	// TNode* createASTNode(char* nodetype,TNode* left,TNode* right,int value){
	// 	TNode* new = (TNode*)malloc(sizeof(TNode));
	// 	new->nodetype = strdup(nodetype);
	// 	new->left = left;
	// 	new->right = right;
	// 	new->value = value? value: NULL;
	// 	return new;
	// }

	//prints syntax tree
	// void print_tree(TNode* root,int level){
	// 	if(!root) return;

	// 	for(int i = 0;i<level;i++) printf(" ");
	// 	printf("%s\n",root->nodetype);
	// 	if(root->value) printf("(%d)",root->value);
	// 	printf("\n");

	// 	print_tree(root->left,level+1);
	// 	print_tree(root->right,level+1);

	// }

	// void add_symbol(char* name,int value,int isDefined){
	// 	symbol_entry* new = (symbol_entry*)malloc(sizeof(symbol_entry));
	// 	new->name = strdup(name);
	// 	new->value = value;
	// 	new->isDefined = isDefined;
	// 	new->next = SYM_TABLE;
	// 	SYM_TABLE = new;
	// }

	// void update_symbol(char* name,int value){
	// 	symbol_entry* temp = SYM_TABLE;
	// 	while(temp){
	// 		if(strcmp(temp->name,name)==0){
	// 			temp->value = value;
	// 			temp->isDefined = 1;
	// 			return;
	// 		}
	// 		temp = temp->next;
	// 	}
	// 	printf("Error:the symbol %s is not in symbol table\n",name);
	// }

	// int lookup_symbol(char* name){
	// 	symbol_entry* temp = SYM_TABLE;
	// 	while(temp){
	// 		if(strcmp(temp->name,name)== 0){
	// 			return temp->isDefined? temp->value:-1;
	// 		}
	// 		temp = temp->next;
	// 	}
	// 	return -1;
	// }
%}
%union{
	int num;
	char* var;
	struct ASTNode* node;
}

%token BEG END
%token T_INT T_BOOL
%token READ WRITE
%token DECL ENDDECL
/* %token VAR NUM */
%token IF THEN ELSE ENDIF
%token LOGICAL_AND LOGICAL_NOT LOGICAL_OR
%token EQUALEQUAL LESSTHANOREQUAL GREATERTHANOREQUAL NOTEQUAL
%token WHILE DO ENDWHILE FOR BREAK
%token <node>T F 
%token MAIN RETURN

//types
%type <node> Gdecl ret_type Glist Gid func assign_stmt expr var_expr statement write_stmt cond_stmt stmt_list1 break_stmt
%token <num> NUM 
%token <var> VAR






%left '<' '>'
%left EQUALEQUAL LESSTHANOREQUAL GREATERTHANOREQUAL NOTEQUAL
%left '+' '-'
%left '*' '/'
%left '%'
%left LOGICAL_AND LOGICAL_OR
%left LOGICAL_NOT
%%

	Prog	:	Gdecl_sec Fdef_sec MainBlock{print_symbolTable(root);}
		;
		
	Gdecl_sec:	DECL Gdecl_list ENDDECL{print_forest(forest); forest=NULL;}
		;
		
	Gdecl_list: 
		| 	Gdecl Gdecl_list {forest = update_forest($1,forest);}
		;
		
	Gdecl 	:	ret_type Glist ';'{$$ = createASTNode(1,NULL,"DECL_STMT",NULL,$1,$2,NULL,NULL);}
		;
		
	ret_type:	T_INT		{$$ = createASTNode(3,NULL,"INT",NULL,NULL,NULL,NULL,NULL); }
		;
		
	Glist 	:	Gid {$$=$1;}
		| 	func 
		|	Gid ',' Glist {$1->right = $3;$$=$1;}
		|	func ',' Glist
		;
	
	Gid	:	VAR		{SymbolTable* temp = addSymbol($1,NULL,-1,root);if(temp!=NULL) root = temp;else yyerror("symbol already exists cannot add another one\n");$$ = createASTNode(0,NULL,$1,-1,NULL,NULL,NULL,NULL);}
		|	Gid '[' NUM ']'	{SymbolTable* temp = updateArray($1->name,NULL,0,root);
								if(temp!=NULL) root = temp;
								else yyerror("symbol already exists cannot add another one\n");
					for(int i=1;i<$3;i++){
								SymbolTable* temp = addSymbol($1->name,NULL,i,root);
								// if(temp!=NULL) 
								root = temp;
								// else yyerror("symbol already exists cannot add another one\n");
					}
					// char result[50];
					// char* initial = strdup($1->name); 
					// sprintf(result, "%d", $3);
					// strcat(initial, "[");
					// strcat(initial, result);
					// strcat(initial, "]");
					$$ = createASTNode(0,NULL,$1->name,$3,NULL,NULL,NULL,NULL);
		}

		;
		
	func 	:	VAR '(' arg_list ')' 					{ 					}
		;
			
	arg_list:	
		|	arg_list1
		;
		
	arg_list1:	arg_list1 ';' arg
		|	arg
		;
		
	arg 	:	arg_type var_list	
		;
		
	arg_type:	T_INT		 {  }
		;

	var_list:	VAR 		 { }
		|	VAR ',' var_list { 	}
		;
		
	Fdef_sec:	
		|	Fdef_sec Fdef
		;
		
	Fdef	:	func_ret_type func_name '(' FargList ')' '{' Ldecl_sec BEG stmt_list ret_stmt END '}'	{}
		;
		
	func_ret_type:	T_INT		{ }
		;
			
	func_name:	VAR		{ 					}
		;
		
	FargList:	arg_list	{ 					}
		;

	ret_stmt:	RETURN expr ';'	{ 					}
		;
			
	MainBlock: 	func_ret_type main '('')''{' Ldecl_sec BEG stmt_list ret_stmt END  '}'		{ 				  	  }
		|stmt_list    {print_forest(forest);
		evaluate_ST(forest,root);
		forest = NULL;}
					  
		;
		
	main	:	MAIN		{ 					}
		;
		
	Ldecl_sec:	DECL Ldecl_list ENDDECL	{}
		;

	Ldecl_list:		
		|	Ldecl Ldecl_list
		;

	Ldecl	:	type Lid_list ';'		
		;

	type	:	T_INT			{ }
		;

	Lid_list:	Lid
		|	Lid ',' Lid_list
		;
		
	Lid	:	VAR			{ 						}
		;

	stmt_list:	/* NULL */		{  }
		|	statement stmt_list	{forest = update_forest($1,forest);}
		|	error ';' 		{  }
		;
	stmt_list1:	/* NULL */		{ $$=NULL; }
		|	statement stmt_list1	{$1->next=$2;$$=$1;}
		|	error ';' 		{  }
		;
	statement:	assign_stmt  ';'{$$=$1;}
		|	read_stmt ';'		{}
		|	write_stmt ';'		{$$=$1; }
		|	cond_stmt 		{$$=$1;}
		|	break_stmt ';' {$$=$1;}
		|	func_stmt ';'		{}
		;
	break_stmt: BREAK 		{$$= createASTNode(1,NULL,"BREAK", NULL,NULL,NULL,NULL,NULL);}
	
	;


	read_stmt:	READ '(' var_expr ')' {						 }
		;

	write_stmt:	WRITE '(' expr ')' 	{$$= createASTNode(1,NULL,"FUNC_CALL",NULL,createASTNode(1,NULL,"WRITE",NULL,NULL,NULL,NULL,NULL),$3,NULL,NULL);}
		 | WRITE '(''"' str_expr '"'')'      { }

		;
	
	assign_stmt:	var_expr '=' expr 	{$$ = createASTNode(1,NULL,"ASSIGN_STMT",NULL,$1,$3,NULL,NULL);}
				| 	/*NULL*/				{$$=NULL;}
		;

	cond_stmt:	IF expr THEN stmt_list1 ENDIF 	{ $$=createASTNode(4,NULL,"IF_THEN",NULL,NULL,NULL,createIFNode($2,$4,NULL),NULL);}
		|	IF expr THEN stmt_list1 ELSE stmt_list1 ENDIF 	{$$=createASTNode(4,NULL,"IF_THEN_ELSE",NULL,NULL,NULL,createIFNode($2,$4,$6),NULL);}
	        |    FOR '(' assign_stmt  ';'  expr ';'  assign_stmt ')' '{' stmt_list1 '}' {$$=createASTNode(5,NULL,"FOR_LOOP",NULL,NULL,NULL,NULL,createFORNode($3,$5,$7,$10));}
		;
	
	func_stmt:	func_call 		{ 						}
		;
		
	func_call:	VAR '(' param_list ')'	{ 						   }
		;
		
	param_list:				
		|	param_list1		
		;
		
	param_list1:	para			
		|	para ',' param_list1	
		;

	para	:	expr			{ 						}
		;

	expr	:	NUM 		{$$ = createASTNode(2,$1,NULL,NULL,NULL,NULL,NULL,NULL);}
		|	'-' NUM			{ $$ =  createASTNode(2,-1*$2,"UNARY_MINUS",NULL,NULL,createASTNode(2,$2,NULL,NULL,NULL,NULL,NULL,NULL),NULL,NULL);}
		|	var_expr		{$$ = $1;}
		|	T			{$$ = createASTNode(1,1,"TRUE",NULL,NULL,NULL,NULL,NULL);}
		|	F			{$$ = createASTNode(1,0,"FALSE",NULL,NULL,NULL,NULL,NULL);}
		|	'(' expr ')'		{$$=$2;}

		|	expr '+' expr 		{$$ = createASTNode(1,0,"ADD",NULL,$1,$3,NULL,NULL);}
		|	expr '-' expr	 	{$$ = createASTNode(1,0,"SUB",NULL,$1,$3,NULL,NULL);}
		|	expr '*' expr 		{$$ = createASTNode(1,0,"MUL",NULL,$1,$3,NULL,NULL);}
		|	expr '/' expr 		{$$ = createASTNode(1,0,"DIV",NULL,$1,$3,NULL,NULL);}
		|	expr '%' expr 		{$$ = createASTNode(1,0,"REM",NULL,$1,$3,NULL,NULL);}
		|	expr '<' expr		{$$ = createASTNode(1,0,"LESSTHAN",NULL,$1,$3,NULL,NULL);}
		|	expr '>' expr		{$$ = createASTNode(1,0,"GREATERTHAN",NULL,$1,$3,NULL,NULL);}
		|	expr GREATERTHANOREQUAL expr	{$$ = createASTNode(1,0,"GREATERTHANOREQUAL",NULL,$1,$3,NULL,NULL);}
		|	expr LESSTHANOREQUAL expr	{$$ = createASTNode(1,0,"LESSTHANOREQUAL",NULL,$1,$3,NULL,NULL);}
		|	expr NOTEQUAL expr			{$$ = createASTNode(1,0,"NOTEQUAL",NULL,$1,$3,NULL,NULL);}
		|	expr EQUALEQUAL expr	{$$ = createASTNode(1,0,"EQUALEQUAL",NULL,$1,$3,NULL,NULL);}
		|	LOGICAL_NOT expr	{$$ = createASTNode(1,0,"LOGICAL_NOT",NULL,$2,NULL,NULL,NULL);}
		|	expr LOGICAL_AND expr	{$$ = createASTNode(1,0,"LOGICAL_AND",NULL,$1,$3,NULL,NULL);}
		|	expr LOGICAL_OR expr	{$$ = createASTNode(1,0,"LOGICAL_OR",NULL,$1,$3,NULL,NULL);}
		|	func_call		{  }

		;
	str_expr :  VAR                       {}
                  | str_expr VAR   { }
                ;
	
	var_expr:	VAR	{int a = lookupSymbol($1,-1,root);
				if(a!=INT_MIN) {$$ = createASTNode(0,a,$1,-1,NULL,NULL,NULL,NULL);} 
				else {$$ = createASTNode(0,NULL,$1,-1,NULL,NULL,NULL,NULL);};
				}
		|	var_expr '[' expr ']'	{/*int a = lookupSymbol($1->name,$3->value,root);
										if(a!=INT_MIN) {$$ = createASTNode(0,a,$1->name,$3->value,NULL,NULL,NULL,NULL);} 
										else {$$ = createASTNode(0,NULL,$1->name,$3->value,NULL,NULL,NULL,NULL);}*/
										$$ = createASTNode(6,NULL,$1->name,NULL,$3,NULL,NULL,NULL);
										}
		;
%%
void yyerror ( char  *s) {
   fprintf (stderr, "%s\n", s);
 }

main(){
yyparse();
}
