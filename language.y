%{
  #include <stdio.h>
  #include <math.h>
  #include "global.h"
  extern int token_value;
  extern void yyerror(char*);
  int yylex(void);
%}

%token DONE ID NUM DIV MOD EQUAL QUESTIONMARK COLON PIPE AMPERSAND GREATERTHAN LESSTHAN PLUS MINUS STAR SLASH PERCENT CARET LPAREN RPAREN NEWLINE SEMICOLON
%left EQUAL
%left QUESTIONMARK COLON
%left PIPE AMPERSAND
%left GREATERTHAN LESSTHAN
%left PLUS MINUS
%left STAR SLASH DIV MOD PERCENT
%left CARET

%%

start: list DONE
       ;

list: assignment SEMICOLON list
        | expr SEMICOLON { printf("\nThe result of the expression is %d.\n\n", $1); } list
        | /* empty */
        ;

assignment: ID { symtable[$1].theVariableThatIsGoingToBeAssignedAValue = true; printf("%s ", symtable[$1].lexeme); } EQUAL expr {  
            symtable[$1].value = $4; 
            symtable[$1].initialized = true;
            symtable[$1].theVariableThatIsGoingToBeAssignedAValue = false;
            printf("= \n'%s' is now %d.\n\n", symtable[$1].lexeme, $4); }
          ;

expr: LPAREN expr RPAREN                    { $$ = $2; }
    | expr QUESTIONMARK expr COLON expr     { $$ = $1 ? $3 : $5; printf("?: "); }
    | expr AMPERSAND expr                   { $$ = $1 & $3; printf("& "); }
    | expr PIPE expr                        { $$ = $1 | $3; printf("| "); }
    | expr GREATERTHAN expr                 { $$ = $1 > $3; printf("> "); }
    | expr LESSTHAN expr                    { $$ = $1 < $3; printf("< "); }
    | expr PLUS expr                        { $$ = $1 + $3; printf("+ "); }
    | expr MINUS expr                       { $$ = $1 - $3; printf("- "); }
    | expr STAR expr                        { $$ = $1 * $3; printf("* "); }
    | expr SLASH expr                       { $$ = $1 / $3; printf("/ "); }
    | expr DIV expr                         { $$ = $1 / $3; printf("DIV "); }
    | expr MOD expr                         { $$ = $1 % $3; printf("MOD "); }
    | expr PERCENT expr                     { $$ = $1 % $3; printf("%% "); }
    | expr CARET expr                       { $$ = pow($1, $3); printf("^ "); }
    | NUM                                   { printf("%d ", $1); }
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

void parse() {
  yyparse();
}