%{
  #include <stdio.h>
  #include <math.h>
  #include "global.h"
  extern int token_value;
  extern void yyerror(char*);
  int yylex(void);

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

list: assignment ';' { printf("is now %d.\n\n", $1); } list
        | expr ';' { printf("\nThe result of the expression is %d.\n\n", $1); } list
        | /* empty */
        ;

assignment: ID { symtable[$1].theVariableThatIsGoingToBeAssignedAValue = true; } '=' expr { 
            printf("= \n%s ", symtable[$1].lexeme); 
            symtable[$1].theVariableThatIsGoingToBeAssignedAValue = false;
            symtable[$1].initialized = true;
            symtable[$1].value = $3; 
            $$ = $3;
            printf("%d", $3); }
          ;

expr: '(' expr ')'      { $$ = $2; }
    | expr '+' expr     { $$ = $1 + $3; printf("+ "); }
    | expr '-' expr     { $$ = $1 - $3; printf("- "); }
    | expr '*' expr     { $$ = $1 * $3; printf("* "); }
    | expr '/' expr     { $$ = $1 / $3; printf("/ "); }
    | expr DIV expr     { $$ = $1 / $3; printf("DIV "); }
    | expr MOD expr     { $$ = $1 % $3; printf("MOD "); }
    | expr '^' expr     { $$ = pow($1, $3); printf("^ "); }
    | NUM               { $$ = token_value; { printf("%d ", $1); } }
    | ID                { if (symtable[$1].initialized || symtable[$1].theVariableThatIsGoingToBeAssignedAValue) 
                            { 
                              $$ = symtable[$1].value; 
                              printf("%d ", symtable[$1].value); 
                            } 
                          else 
                            {
                              yyerror("Used an uninitialized variable, why did you do that?");
                            }
                        }
    ;
%%

void yyerror(char *s) {
    fprintf(stderr, "%s\n", s);
}

int yylex(void) {
  int tokentype = lexan();
  yylval = token_value;
  return tokentype;
}

void parse() {
  yyparse();
}
