%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <math.h>
  #include "global.h"
  extern int token_value;
  extern void yyerror(char*);
  int yylex(void);

#define MAX_ARGS 3

typedef struct Node {
  int type;
  int leaf_value;
  struct Node* args[MAX_ARGS];
} Node;

Node* mkleaf(int type, int value) {
  Node* p = malloc(sizeof(Node));
  p->type = type;
  p->leaf_value = value;
  return p;
}

Node* mknode(int type, Node* a0, Node* a1, Node* a2) {
  Node* p = malloc(sizeof(Node));
  p->type = type;
  p->args[0] = a0;
  p->args[1] = a1;
  p->args[2] = a2;
  return p;
}
%}

%token DONE ID NUM DIV MOD EQUAL QUESTIONMARK COLON PIPE AMPERSAND GREATERTHAN LESSTHAN PLUS MINUS STAR SLASH PERCENT CARET LPAREN RPAREN NEWLINE SEMICOLON
%left EQUAL
%left QUESTIONMARK COLON
%left PIPE AMPERSAND
%left GREATERTHAN LESSTHAN
%left PLUS MINUS
%left STAR SLASH DIV MOD PERCENT
%left CARET

%union {
  Node* p;
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
    | NUM                                   { $$ = mkleaf(NUM, yylval); }
    | ID                { if (symtable[yylval].initialized || symtable[yylval].theVariableThatIsGoingToBeAssignedAValue) 
                            { 
                              $$ = mkleaf(ID, yylval);
                            }
                          else 
                            {
                              yyerror("Used an uninitialized variable, why did you do that?");
                            }
                        }
    ;
%%

void print_the_tree(Node* p, int level) {
  if (p == 0)
    ;
  else if (p->type == ID) {
    printf("%*s", 2*level, "");
    printf("%s\n", symtable[p->leaf_value].lexptr);
  }
  else if (p->type == NUM) {
    printf("%*s", 2*level, "");
    printf("%d\n", p->leaf_value);
  }
  else if (p->type == PLUS) {
    printf("%*s", 2*level, "");
    printf("+\n");
    print_the_tree(p->args[0], level + 1);
    print_the_tree(p->args[1], level + 1);
  }
  else if (p->type == SEMICOLON) {
    printf("%*s", 2*level, "");
    print_the_tree(p->args[0], level + 1);
    printf("%*s", 2*level, "");
    printf(";\n");
    print_the_tree(p->args[1], level);
  }
} 

void yyerror(char *s) {
    fprintf(stderr, "%s\n", s);
    exit(1);
}

void parse() {
  yyparse();
}