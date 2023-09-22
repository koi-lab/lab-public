%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <math.h>
  #include "global.h"
  extern int token_value;
  extern void yyerror(char*);
  int yylex(void);
  
  void print_spaces(int count);
  void print_the_tree(struct Node* p, int level);



#define MAX_ARGS 3

struct Node {
  int type;
  int leaf_value;
  struct Node* args[MAX_ARGS];
};

struct Node* mkleaf(int type, int value) {
  struct Node* p = malloc(sizeof(struct Node));
  p->type = type;
  p->leaf_value = value;
  return p;
}

struct Node* mknode(int type, struct Node* a0, struct Node* a1, struct Node* a2) {
  struct Node* p = malloc(sizeof(struct Node));
  p->type = type;
  p->args[0] = a0;
  p->args[1] = a1;
  p->args[2] = a2;
  return p;
}
%}

%token <int_value> NUM ID
%token <p> DONE DIV MOD EQUAL QUESTIONMARK COLON PIPE AMPERSAND GREATERTHAN LESSTHAN PLUS MINUS STAR SLASH PERCENT CARET LPAREN RPAREN NEWLINE SEMICOLON
%left EQUAL
%left QUESTIONMARK COLON
%left PIPE AMPERSAND
%left GREATERTHAN LESSTHAN
%left PLUS MINUS
%left STAR SLASH DIV MOD PERCENT
%left CARET

%union value {
  struct Node* p;
  int int_value;
}

%type <p> expr;

%%

start: list DONE
       ;

list:  expr SEMICOLON { print_the_tree($1, 0); } list
        | /* empty */
        ;

expr: LPAREN expr RPAREN                    { $$ = $2; }
    | expr QUESTIONMARK expr COLON expr     { $$ = mknode(TERNARY, $1, $3, $5); }
    | expr AMPERSAND expr                   { $$ = mknode(AMPERSAND, $1, $3, NULL); }
    | expr PIPE expr                        { $$ = mknode(PIPE, $1, $3, NULL); }
    | expr GREATERTHAN expr                 { $$ = mknode(GREATERTHAN, $1, $3, NULL); }
    | expr LESSTHAN expr                    { $$ = mknode(LESSTHAN, $1, $3, NULL); }
    | expr PLUS expr                        { $$ = mknode(PLUS, $1, $3, NULL); }
    | expr MINUS expr                       { $$ = mknode(MINUS, $1, $3, NULL); }
    | expr STAR expr                        { $$ = mknode(STAR, $1, $3, NULL); }
    | expr SLASH expr                       { $$ = mknode(SLASH, $1, $3, NULL); }
    | expr DIV expr                         { $$ = mknode(DIV, $1, $3, NULL); }
    | expr MOD expr                         { $$ = mknode(MOD, $1, $3, NULL); }
    | expr PERCENT expr                     { $$ = mknode(PERCENT, $1, $3, NULL); }
    | expr CARET expr                       { $$ = mknode(CARET, $1, $3, NULL); }
    | expr EQUAL expr                       { $$ = mknode(EQUAL, $1, $3, NULL); }
    | NUM                                   { $$ = mkleaf(NUM, $1); }
    | ID                { if (symtable[$1].initialized || symtable[$1].theVariableThatIsGoingToBeAssignedAValue) 
                            { 
                              $$ = mkleaf(ID, $1);
                            }
                          else 
                            {
                              yyerror("Used an uninitialized variable, why did you do that?");
                            }
                        }
    ;
%%

// Function to print spaces for indentation
void print_spaces(int count) {
    for (int i = 0; i < count; i++) {
        printf(" ");
    }
}

void print_the_tree(struct Node* p, int level) {
    if (p == NULL) {
        return;
    }

    // Print spaces for indentation
    print_spaces(level * 2);

    // Print the node based on its type
    switch (p->type) {
        case DONE: printf("DONE\n"); break;
        case DIV: printf("DIV\n"); break;
        case MOD: printf("MOD\n"); break;
        case EQUAL: printf("=\n"); break;
        case QUESTIONMARK: printf("?\n"); break;
        case COLON: printf(":\n"); break;
        case PIPE: printf("|\n"); break;
        case AMPERSAND: printf("&\n"); break;
        case GREATERTHAN: printf(">\n"); break;
        case LESSTHAN: printf("<\n"); break;
        case PLUS: printf("+\n"); break;
        case MINUS: printf("-\n"); break;
        case STAR: printf("*\n"); break;
        case SLASH: printf("/\n"); break;
        case PERCENT: printf("%%\n"); break;
        case CARET: printf("^\n"); break;
        case LPAREN: printf("(\n"); break;
        case RPAREN: printf(")\n"); break;
        case NEWLINE: printf("\\n\n"); break;
        case SEMICOLON: printf(";\n"); break;
        default: printf("%d\n", p->leaf_value); break;
    }

    // Recursively print the children nodes
    for (int i = 0; i < MAX_ARGS; i++) {
        print_the_tree(p->args[i], level + 1);
    }
} 

void yyerror(char *s) {
    fprintf(stderr, "%s\n", s);
    exit(1);
}

void parse() {
  yyparse();
}