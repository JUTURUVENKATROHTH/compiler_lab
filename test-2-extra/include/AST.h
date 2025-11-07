#ifndef AST_H
#define AST_H

typedef struct ASTNode {
    int nodetype;
    int value;
    char* name;
    int dimension;
    int* offset;
    struct ASTNode* left;
    struct ASTNode* right;
    struct ASTNode* next;
    struct IFNode* ifnode;
    struct FORNode* fornode;
    struct DOWHILENode* dowhilenode; 
    
}ASTNode;
typedef struct IFNode {
    ASTNode* cond;
    ASTNode* if_stmt_list;
    ASTNode* else_stmt_list;

}IFNode;
typedef struct FORNode {
    ASTNode* assign_stmt1;
    ASTNode* cond_stmt;
    ASTNode* assign_stmt2;
    ASTNode* statement_list;

}FORNode;
typedef struct DOWHILENode {
    
    ASTNode* cond_stmt;
    
    ASTNode* statement_list;

}DOWHILENode;

ASTNode* createASTNode(int* offset,int nodetype, int value, char* name,int dimension, ASTNode* left,ASTNode* right,IFNode* ifnode,FORNode* fornode,DOWHILENode* dowhilenode);
void print_tree(ASTNode* start, int depth);

typedef struct SymbolTable{
	char* name;
	int value;
    int index;
    int dimension;
    int* offset;
	// int isDefined;
	struct SymbolTable* next;
} SymbolTable;
ASTNode* update_forest(ASTNode* node,ASTNode* forest);
void print_forest(ASTNode* forest);
SymbolTable* addSymbol(char* name,int value,int offset,SymbolTable* root);
int updateSymbol(char* name, int value,int offset,SymbolTable* root);
SymbolTable* updateArray(char* name,int value,int offset,SymbolTable* root);
int lookupSymbol(char* name,int offset,SymbolTable* root);

IFNode* createIFNode(ASTNode* cond,ASTNode* if_stmt_list,ASTNode* else_stmt_list);
FORNode* createFORNode(ASTNode* assign_stmt1,ASTNode* cond_stmt,ASTNode* assign_stmt2,ASTNode* statement_list);
DOWHILENode* createDOWHILENode(ASTNode* cond_stmt,ASTNode* statement_list);

int evaluate_ST(ASTNode* forest,SymbolTable* root);
int eval_expr(ASTNode* expr,SymbolTable* root);
#endif