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

list: assignment ';' { printf("\n'thetuhethut' is now \n\n"); } list
        | expr ';' { printf("\nThe result of the expression is %d.\n\n", $1); } list
        | /* empty */
        ;

assignment: {
   symbol_index = token_value;
   symtable[symbol_index].theVariableThatIsGoingToBeAssignedAValue = true;
    } ID { printf("%s", symtable[symbol_index].lexeme); } '=' expr { printf("="); } {  }

expr: '(' expr ')'      { $$ = $2; }
    | expr '+' expr     { $$ = $1 + $3; printf("+ "); }
    | expr '-' expr     { $$ = $1 - $3; printf("- "); }
    | expr '*' expr     { $$ = $1 * $3; printf("* "); }
    | expr '/' expr     { $$ = $1 / $3; printf("/ "); }
    | expr DIV expr     { $$ = $1 / $3; printf("DIV "); }
    | expr MOD expr     { $$ = $1 % $3; printf("MOD "); }
    | expr '^' expr     { $$ = pow($1, $3); printf("^ "); }
    | NUM               { $$ = token_value; { printf("%d ", token_value); } }
    | ID  {
      if (symtable[symbol_index].theVariableThatIsGoingToBeAssignedAValue || symtable[symbol_index].initialized) {
        printf("%s ", symtable[token_value].lexeme);
      }
      else {
        yyerror("❗️ Used uninitialized variable.");
      }
    }
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
