%{
  #include <stdio.h>
  #include <math.h>
  #include "global.h"
  extern int token_value;
  extern void yyerror(char*);

  int symbol_index;
%}

%token DONE ID NUM DIV MOD
%left '='
%left '+' '-'
%left '*' '/' DIV MOD
%left '^'

%%

start: list DONE
       ;

list: assignment ';' { printf("\n is now %d.\n\n", $1); } list
        | expr ';' { printf("\nThe result of the expression is %d.\n\n", $1); } list
        | /* empty */
        ;

assignment: ID '=' expr { printf("="); } { $$ = $3;}

expr: '(' expr ')'      { $$ = $2; }
    | expr '+' expr     { $$ = $1 + $3; printf("+ "); }
    | expr '-' expr     { $$ = $1 - $3; printf("- "); }
    | expr '*' expr     { $$ = $1 * $3; printf("* "); }
    | expr '/' expr     { $$ = $1 / $3; printf("/ "); }
    | expr DIV expr     { $$ = $1 / $3; printf("DIV "); }
    | expr MOD expr     { $$ = $1 % $3; printf("MOD "); }
    | expr '^' expr     { $$ = pow($1, $3); printf("^ "); }
    | NUM               { $$ = token_value; { printf("%d ", token_value); } }
    | ID  
    ;
%%

void yyerror(char *s) {
    fprintf(stderr, "%s\n", s);
}

int yylex(void) {
  return lexan();
}

void parse() {
  yyparse();
}
