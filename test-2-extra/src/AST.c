#include <stdio.h>
#include <stdlib.h>
#include <limits.h>
#include <string.h>
#include "../include/AST.h"

int start = 1 ;

ASTNode* createASTNode(int* offset,int nodetype, int value, char* name,int dimension, ASTNode* left,ASTNode* right,IFNode* ifnode,FORNode* fornode,DOWHILENode* dowhilenode) {
    ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
    node->nodetype = nodetype;
    node->value = value;
    node->name = name;
    node->left = left;
    node->right = right;
    int* offset_new = (int*)malloc(sizeof(int)*dimension);
    for(int i = 0;i<dimension;i++){
        offset_new[i] = offset[i];
    }
    node->offset=offset_new;
    node->next = NULL;
    node->ifnode=ifnode;
    node->fornode=fornode;
    node->dowhilenode = dowhilenode;
    return node;
}

void print_tree(ASTNode* root, int depth) {
    if (root == NULL) return;

    
    for (int i = 0; i < depth; i++) {
        if (i == depth - 1)
            printf("│   "); 
            printf("    "); 
    }

    
    if (depth > 0) printf("└── ");

    
    if (root->nodetype == 3 || root->nodetype == 1) {
        printf("%s\n", root->name);
        
    } 
    else if((root->nodetype == 0) ){
        char result[50];
        char* initial = strdup(root->name);
        if(root->offset != -1){
            sprintf(result, "%d", root->offset);
            strcat(initial, "[");
            strcat(initial, result);
            strcat(initial, "]");
        }
        printf("%s\n", initial);;
    }else if (root->nodetype == 2) {
        printf("%s value:%d\n",root->name,root->value);
        // printf("%d\n", root->value);
    }
    else if(root->nodetype==4){
        printf("%s\n",root->name);
        printf("         Condition_statement:\n\n");

        print_tree(root->ifnode->cond, depth+1);
        ASTNode* temp=root->ifnode->if_stmt_list;
        ASTNode* temp1=root->ifnode->else_stmt_list;
        printf("         If_stmt_list:\n\n");

        while(temp!=NULL){
            print_tree(temp, depth+1);
            temp=temp->next;
        }
        if(temp1){    
            printf("         Else_stmt_list:\n\n");

            while(temp1!=NULL){
                print_tree(temp1, depth+1);
                temp1=temp1->next;
            }
        }
    }
    else if(root->nodetype==5){
        printf("%s\n", root->name);
        ASTNode* temp=root->fornode->statement_list;
        while(temp!=NULL){
            print_tree(temp, depth+1);
            temp=temp->next;
        }

    }
    else if(root->nodetype==6){
        printf("%s[]\n", root->name);
    }
    else if(root->nodetype==7){
        printf("%s\n", root->name);
        printf("         Statement_list:\n\n");
        ASTNode* temp = root->dowhilenode->statement_list;
        while(temp!=NULL){
            print_tree(temp, depth+1);
            temp=temp->next;
        }
        
    }
    // Recursively print children
    print_tree(root->left, depth + 1);
    print_tree(root->right, depth + 1);
}

ASTNode* update_forest(ASTNode* node,ASTNode* forest){
    node->next = forest;
    forest = node;
    return forest;
}

void print_forest(ASTNode* forest){
    if(forest==NULL) return;
    // ASTNode* node = forest;
    // while(node!=NULL){
    //     print_tree(node);
    //     printf("\n");
    //     node = node->next;
    // }
    print_tree(forest,0);
    printf("\n");


    print_forest(forest->next);
    return 0;
}

SymbolTable* addSymbol(char* name,int value,int offset,SymbolTable* root){
    SymbolTable* temp = root;
    if(temp == NULL){ 
        root = (SymbolTable*)malloc(sizeof(SymbolTable));
        root->name = strdup(name);
        root->value = value;
        root->index= start;
        root->offset=offset;
        root->next = NULL;
        start++;
        // printf("symbol\n");
        return root;
    }
    while(temp!=NULL){
        if((strcmp(temp->name , name) == 0) && (temp->offset == offset)) {
            printf("already %s exists in symbol table\n",name);
            return NULL;
        }
        temp = temp->next;
    }
    SymbolTable* newNode = (SymbolTable*)malloc(sizeof(SymbolTable));
    
    
    newNode->name = strdup(name);
    newNode->value = value;
    newNode->index= start;
    newNode->next = NULL;
    newNode->offset=offset;
    start++;
    temp = root;
    while(temp->next!=NULL){
        temp= temp->next;
    }
    temp->next = newNode;
    // printf("symbol\n");
    return root;
}

int updateSymbol(char* name,int value,int offset,SymbolTable* root){
    SymbolTable* temp = root;
    while(temp!=NULL){
        if((strcmp(temp->name , name) == 0) && (temp->offset == offset)){
            temp->value = value;
            return 0;
        }
        temp=temp->next;
    }
    return -1;
}
SymbolTable* updateArray(char* name,int value,int dimension,int* offset,SymbolTable* root){
    SymbolTable* temp = root;
    while(temp!=NULL){
        if(strcmp(temp->name , name) == 0){
            if(temp->offset == -1){
                temp->offset = offset;
                return root;
            }
            
        }
        temp=temp->next;
    }
    return NULL;
}

int lookupSymbol(char* name,int offset,SymbolTable* root){
    SymbolTable* temp = root;
    // if(root==NULL) return INT_MIN;
    while(temp!=NULL){
        if((strcmp(temp->name , name) == 0) && (temp->offset == offset)){
            return temp->value;
        }
        temp=temp->next;
    }
    return INT_MIN;
}
void print_symbolTable(SymbolTable* root){
    if(root == NULL){
        return;
    }
    SymbolTable* temp = root;
    printf("\n\n");
    printf("------------------------------------\n");

    printf("SYMBOL TABLE\n");
    printf("\n");

    printf("Index Variable   Offset   Value\n");

    while(temp != NULL){
        printf("%d     ",temp->index);
        printf("%s        ",temp->name);
        printf("%d        ",temp->offset);

        printf("%d\n",temp->value);
        temp = temp->next;
    }
    return;
}

IFNode* createIFNode(ASTNode* cond,ASTNode* if_stmt_list,ASTNode* else_stmt_list){
    IFNode* new_node = (IFNode*)malloc(sizeof(IFNode));
    new_node->cond = cond;
    new_node->if_stmt_list = if_stmt_list;
    new_node->else_stmt_list = else_stmt_list;
    return new_node;
}

FORNode* createFORNode(ASTNode* assign_stmt1,ASTNode* cond_stmt,ASTNode* assign_stmt2,ASTNode* statement_list){
    FORNode* new_node = (FORNode*)malloc(sizeof(FORNode));
    new_node->assign_stmt1 = assign_stmt1;
    new_node->cond_stmt = cond_stmt;
    new_node->assign_stmt2 = assign_stmt2;
    new_node->statement_list = statement_list;
    return new_node;
}
DOWHILENode* createDOWHILENode(ASTNode* cond_stmt,ASTNode* statement_list){
    DOWHILENode* new_node = (DOWHILENode*)malloc(sizeof(FORNode));
    // new_node->assign_stmt1 = assign_stmt1;
    new_node->cond_stmt = cond_stmt;
    // new_node->assign_stmt2 = assign_stmt2;
    new_node->statement_list = statement_list;
    return new_node;
}

int evaluate_ST(ASTNode* forest,SymbolTable* root){
    if(forest == NULL){
        return 0;
    }

    if(forest->nodetype==1 && !strcmp(forest->name, "ASSIGN_STMT")){
        int value = eval_expr(forest->right, root);
        if(forest->left->nodetype==6){
            int offset = eval_expr(forest->left->left,root);
            updateSymbol(forest->left->name,value,offset,root);
        }
        else{
            updateSymbol(forest->left->name,value,-1,root);
        }
        
    }

    else if(forest->nodetype==4){
        int cond_val = eval_expr(forest->ifnode->cond,root);
        int break_value;
        if(cond_val){
            break_value = evaluate_ST(forest->ifnode->if_stmt_list,root);
        }
        else{
            break_value = evaluate_ST(forest->ifnode->else_stmt_list,root);
        }
        if(break_value==4){
            return 4;
        }
    }
    
    else if(forest->nodetype==5){
        // printf("]]]]]]]]]]]\n");
        evaluate_ST(forest->fornode->assign_stmt1,root);
        int cond_val1 = eval_expr(forest->fornode->cond_stmt,root);
        while(cond_val1){
            // printf("]]]]]]]]]]]]]]]]\n");
            int break_value = evaluate_ST(forest->fornode->statement_list,root);
            if(break_value==4){ break;}
            evaluate_ST(forest->fornode->assign_stmt2,root);
            cond_val1 = eval_expr(forest->fornode->cond_stmt,root);
        }
    }

    else if(forest->nodetype==7){
        evaluate_ST(forest->dowhilenode->statement_list,root);
        int cond_val = eval_expr(forest->dowhilenode->cond_stmt,root);
        while(cond_val){
            int break_value = evaluate_ST(forest->dowhilenode->statement_list,root);
            if(break_value==4){ break;}
            cond_val = eval_expr(forest->dowhilenode->cond_stmt,root);

        }
    }
    else if (forest->nodetype==1 && !strcmp(forest->name,"FUNC_CALL")){
        if(!strcmp(forest->left->name,"WRITE")){
            int value = eval_expr(forest->right,root);
            printf("Write output : %d",value);
        }
    }
    if(forest->nodetype==1 && !strcmp(forest->name, "BREAK")){
        return 4;
    }
    

    return evaluate_ST(forest->next,root);
}

int eval_expr(ASTNode* expr,SymbolTable* root){
    if (expr == NULL) return 0;

    if(expr->nodetype==0){
        return lookupSymbol(expr->name,expr->offset,root);
    }
    else if(expr->nodetype==2){
        return expr->value;
    }
    else if(expr->nodetype==1){
        int left_val = eval_expr(expr->left,root);
        int right_val = eval_expr(expr->right,root);
        if(!strcmp(expr->name,"ADD")){
            return left_val+right_val;
        }
        else if(!strcmp(expr->name,"SUB")){
            return left_val-right_val;
        }
        else if(!strcmp(expr->name,"MUL")){
            return left_val*right_val;
        }
        else if(!strcmp(expr->name,"DIV")){
            if(right_val!=0){
                return left_val/right_val;
            }
            else{
                printf("Error: Division by zero\n");    
                exit(1);
            }
        }
        else if(!strcmp(expr->name,"REM")){
            if(right_val!=0){
                return left_val%right_val;
            }
            else{
                printf("Error: Division by zero\n");
                exit(1);
            }
        }
        else if(!strcmp(expr->name,"LESSTHAN")){
            return left_val<right_val;
        }
        else if(!strcmp(expr->name,"GREATERTHAN")){
            return left_val>right_val;
        }
        else if(!strcmp(expr->name,"EQUALEQUAL")){
            return left_val==right_val;
        }
        else if(!strcmp(expr->name,"NOTEQUAL")){
            return left_val!=right_val;
        }
        else if(!strcmp(expr->name,"LESSTHANOREQUAL")){
            return left_val<=right_val;
        }
        else if(!strcmp(expr->name,"GREATERTHANOREQUAL")){
            return left_val>=right_val;
        }
        else if(!strcmp(expr->name,"LOGICAL_AND")){
            return left_val&&right_val;
        }
        else if(!strcmp(expr->name,"LOGICAL_OR")){
            return left_val||right_val;
        }
        else if(!strcmp(expr->name,"LOGICAL_NOT")){
            return !left_val;
        }
        else if(!strcmp(expr->name,"TRUE")){
            return 1;
        }
        else if(!strcmp(expr->name,"FALSE")){
            return 0;
        }
        else{
            printf("Invalid expression type\n");
        }
    }
    else if(expr->nodetype==6){
        int offset = eval_expr(expr->left,root);
        return lookupSymbol(expr->name,offset,root);
    }
    return 0;
}
//struct for symbol table


