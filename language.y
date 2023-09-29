%{
  #include "array.h"
  #include "symbol.h"
  #include "tree.h"
  #include "language.tab.h"

  #include <stdlib.h>
  #include <stdbool.h>
  #include <stdio.h>

  extern void yyerror(char*);
  int yylex(void);
%}

%token <int_value> NUM ID
%token <p> STATEMENTS IF WHILE DONE DIV MOD ASSIGN QUESTIONMARK COLON PIPE AMPERSAND GREATERTHAN LESSTHAN PLUS MINUS STAR SLASH PERCENT CARET LPAREN RPAREN NEWLINE SEMICOLON LCURLYBRACKET RCURLYBRACKET PRINT ELSE READ END EQUALTO NOTEQUALTO GREATERTHANOREQUALTO LESSTHANOREQUALTO NOT
%left ASSIGN
%left QUESTIONMARK COLON
%left PIPE AMPERSAND
%left EQUALTO NOTEQUALTO
%left GREATERTHAN LESSTHAN GREATERTHANOREQUALTO LESSTHANOREQUALTO
%left PLUS MINUS
%left STAR SLASH DIV MOD PERCENT
%left CARET

%union value {
  struct Node* p;
  int int_value;
}

%type <p> expr statements else;

%%

start: statements { } END { array = malloc(sizeof(struct Array)); initialize(array); printf("\n\n🎉 Original tree:\n"); printTree($1, 0); execute(&$1); printf("\n🎉 Optimized tree:\n"); printTree($1, 0); } start DONE
       | /* empty */
       ;
 
statements:  expr SEMICOLON statements { $$ = makeNode(STATEMENTS, $1, $3, NULL); }
        | /* empty */ { $$ = NULL; }
        ;

else:  ELSE LCURLYBRACKET statements RCURLYBRACKET { $$ = $3; }
        | /* empty */ { $$ = NULL; }

expr: LPAREN expr RPAREN                    { $$ = $2; }
    | WHILE LPAREN expr RPAREN LCURLYBRACKET statements RCURLYBRACKET { $$ = makeNode(WHILE, $3, $6, NULL); }
    | IF LPAREN expr RPAREN LCURLYBRACKET statements RCURLYBRACKET else { $$ = makeNode(IF, $3, $6, $8); }
    | expr QUESTIONMARK expr COLON expr     { $$ = makeNode(TERNARY, $1, $3, $5); }
    | expr AMPERSAND expr                   { $$ = makeNode(AMPERSAND, $1, $3, NULL); }
    | expr PIPE expr                        { $$ = makeNode(PIPE, $1, $3, NULL); }
    | expr GREATERTHAN expr                 { $$ = makeNode(GREATERTHAN, $1, $3, NULL); }
    | expr LESSTHAN expr                    { $$ = makeNode(LESSTHAN, $1, $3, NULL); }
    | expr PLUS expr                        { $$ = makeNode(PLUS, $1, $3, NULL); }
    | expr MINUS expr                       { $$ = makeNode(MINUS, $1, $3, NULL); }
    | expr STAR expr                        { $$ = makeNode(STAR, $1, $3, NULL); }
    | expr SLASH expr                       { $$ = makeNode(SLASH, $1, $3, NULL); }
    | expr DIV expr                         { $$ = makeNode(DIV, $1, $3, NULL); }
    | expr MOD expr                         { $$ = makeNode(MOD, $1, $3, NULL); }
    | expr PERCENT expr                     { $$ = makeNode(PERCENT, $1, $3, NULL); }
    | expr CARET expr                       { $$ = makeNode(CARET, $1, $3, NULL); }
        | expr EQUALTO expr                     { $$ = makeNode(EQUALTO, $1, $3, NULL); }
     | expr NOTEQUALTO expr                  { $$ = makeNode(NOTEQUALTO, $1, $3, NULL); }
     | expr GREATERTHANOREQUALTO expr        { $$ = makeNode(GREATERTHANOREQUALTO, $1, $3, NULL); }
     | expr LESSTHANOREQUALTO expr            { $$ = makeNode(LESSTHANOREQUALTO, $1, $3, NULL); }
     | NOT expr                              { $$ = makeNode(NOT, $1, NULL, NULL); }
     | expr ASSIGN expr                      { $$ = makeNode(ASSIGN, $1, $3, NULL); }
    | expr ASSIGN expr                       { $$ = makeNode(ASSIGN, $1, $3, NULL); }
    | NUM                                   { $$ = makeLeaf(NUM, $1); }
    | ID                                    { $$ = makeLeaf(ID, $1); }
    | PRINT LPAREN ID RPAREN                { $$ = makeNode(PRINT, makeLeaf(ID, $3), NULL, NULL); }
    | READ LPAREN ID RPAREN                 { $$ = makeNode(READ, makeLeaf(ID, $3), NULL, NULL); }
    ;
%%




void yyerror(char *s) {
    fprintf(stderr, "%s\n", s);
    exit(1);
}

void parse() {
  yyparse();
}
