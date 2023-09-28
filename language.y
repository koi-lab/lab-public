%{
  #include "array.h"
  #include "symbol.h"
  #include <stdlib.h>
  #include <stdbool.h>
  #include <stdio.h>
  #include "language.tab.h"
  #include "tree.h"

  extern void yyerror(char*);
  int yylex(void);
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

start: statements { } END {  array = malloc(sizeof(struct Array)); initialize(array); execute($1); printArray(array); } start DONE
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




void yyerror(char *s) {
    fprintf(stderr, "%s\n", s);
    exit(1);
}

void parse() {
  yyparse();
}
