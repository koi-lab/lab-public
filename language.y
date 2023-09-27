%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <math.h>
  #include "global.h"

  #define GARBAGE 0

  extern int token_value;
  extern void yyerror(char*);
  int yylex(void);
  
  void print_spaces(int count);
  void print_the_tree(struct Node* p, int level);
  int execute(struct Node* p);



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
%token <p> STATEMENTS IF WHILE DONE DIV MOD EQUAL QUESTIONMARK COLON PIPE AMPERSAND GREATERTHAN LESSTHAN PLUS MINUS STAR SLASH PERCENT CARET LPAREN RPAREN NEWLINE SEMICOLON LCURLYBRACKET RCURLYBRACKET PRINT ELSE READ END
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
%type <p> statements;
%type <p> else;

%%

start: statements { printf("\n"); print_the_tree($1, 0); printf("\n"); } END { execute($1); printf("\n\n"); } start DONE
       | /* empty */
       ;

statements:  expr SEMICOLON statements { $$ = mknode(STATEMENTS, $1, $3, NULL); }
        | /* empty */ { $$ = NULL; }
        ;

else:  ELSE LCURLYBRACKET statements RCURLYBRACKET { $$ = $3; }
        | /* empty */ { $$ = NULL; }

expr: LPAREN expr RPAREN                    { $$ = $2; }
    | WHILE LPAREN expr RPAREN LCURLYBRACKET statements RCURLYBRACKET { $$ = mknode(WHILE, $3, $6, NULL); }
    | IF LPAREN expr RPAREN LCURLYBRACKET statements RCURLYBRACKET else { $$ = mknode(IF, $3, $6, $8); }
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
    | ID                                    { $$ = mkleaf(ID, $1); }
    | PRINT LPAREN ID RPAREN                { $$ = mknode(PRINT, mkleaf(ID, $3), NULL, NULL); }
    | READ LPAREN ID RPAREN                 { $$ = mknode(READ, mkleaf(ID, $3), NULL, NULL); }
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
        case ID: printf("%s\n", symtable[p->leaf_value].lexeme); break;
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
        case STATEMENTS: printf("statements\n"); break;
        case WHILE: printf("while\n"); break;
        case IF: printf("if\n"); break;
        case TERNARY: printf("?:\n"); break;
        case PRINT: printf("print\n"); break;
        case READ: printf("read\n"); break;
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

int execute(struct Node* p) {
    if (p == NULL) {
      return GARBAGE;
    }

    switch (p->type) {
        case ID:
          if (symtable[p->leaf_value].initialized) {
            return symtable[p->leaf_value].value;
          }
          error("❗️ You use an uninitialized variable.\n");

        case NUM:
          return p->leaf_value;

        case DIV: 
          return execute(p->args[0]) / execute(p->args[1]);

        case MOD: 
          return execute(p->args[0]) % execute(p->args[1]);

        case EQUAL:
          if (p->args[0]->type != ID) {
            error("❗️ Invalid assignment.\n");
          }

          symtable[p->args[0]->leaf_value].value = execute(p->args[1]);
          return GARBAGE;

        case TERNARY:
          return execute(p->args[0]) ? execute(p->args[1]) : execute(p->args[2]);

        case PIPE:
          return execute(p->args[0]) | execute(p->args[1]);

        case AMPERSAND:
          return execute(p->args[0]) & execute(p->args[1]);

        case GREATERTHAN:
          return execute(p->args[0]) > execute(p->args[1]);

        case LESSTHAN:
          return execute(p->args[0]) < execute(p->args[1]);

        case PLUS:
          return execute(p->args[0]) + execute(p->args[1]);

        case MINUS:
          return execute(p->args[0]) - execute(p->args[1]);

        case STAR:
          return execute(p->args[0]) * execute(p->args[1]);
          
        case SLASH:
          return execute(p->args[0]) / execute(p->args[1]);
          
        case PERCENT:
          return execute(p->args[0]) % execute(p->args[1]);

        case CARET:
          return pow(execute(p->args[0]), execute(p->args[1]));

        case STATEMENTS:
          execute(p->args[0]);
          execute(p->args[1]);
          return GARBAGE;

        case WHILE:
          while (execute(p->args[0])) {
            execute(p->args[1]);
          }
          return GARBAGE;

        case IF:
          execute(p->args[0]) ? execute(p->args[1]) : execute(p->args[2]);
          return GARBAGE;

        case PRINT:
          printf("%d\n", symtable[p->args[0]->leaf_value].value);
          break;

        case READ:
          int temp;
          printf("Enter an integer: ");
          scanf(" %d", &temp);
          symtable[p->args[0]->leaf_value].value = temp;
          break;
    }
}