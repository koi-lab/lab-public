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
%left '?' ':'
%left '|' '&'
%left '>' '<'
%left '+' '-'
%left '*' '/' DIV MOD '%'
%left '^'

%%

start: list DONE
       ;

list: assignment ';' list
        | expr ';' { printf("\nThe result of the expression is %d.\n\n", $1); } list
        | /* empty */
        ;

assignment: ID { symtable[$1].theVariableThatIsGoingToBeAssignedAValue = true; printf("%s ", symtable[$1].lexeme); } '=' expr {  
            symtable[$1].value = $4; 
            symtable[$1].initialized = true;
            symtable[$1].theVariableThatIsGoingToBeAssignedAValue = false;
            printf("= \n'%s' is now %d.\n\n", symtable[$1].lexeme, $4); }
          ;

expr: '(' expr ')'      { $$ = $2; }
    | expr '?' expr ':' expr     { $$ = $1 ? $3 : $5; printf("?: "); }
    | expr '&' expr     { $$ = $1 & $3; printf("& "); }
    | expr '|' expr     { $$ = $1 | $3; printf("| "); }
    | expr '>' expr     { $$ = $1 > $3; printf("> "); }
    | expr '<' expr     { $$ = $1 < $3; printf("< "); }
    | expr '+' expr     { $$ = $1 + $3; printf("+ "); }
    | expr '-' expr     { $$ = $1 - $3; printf("- "); }
    | expr '*' expr     { $$ = $1 * $3; printf("* "); }
    | expr '/' expr     { $$ = $1 / $3; printf("/ "); }
    | expr DIV expr     { $$ = $1 / $3; printf("DIV "); }
    | expr MOD expr     { $$ = $1 % $3; printf("MOD "); }
    | expr '%' expr     { $$ = $1 % $3; printf("%% "); }
    | expr '^' expr     { $$ = pow($1, $3); printf("^ "); }
    | NUM               { printf("%d ", $1); }
    | ID                { if (symtable[$1].initialized || symtable[$1].theVariableThatIsGoingToBeAssignedAValue) 
                            { 
                              $$ = symtable[$1].value; 
                              printf("%s ", symtable[$1].lexeme); 
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
    exit(1);
}

int yylex(void) {
  int tokentype = lexan();
  yylval = token_value;
  return tokentype;
}

void parse() {
  yyparse();
}