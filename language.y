%{
  #include <stdio.h>
  #include "global.h"
  extern int token_value;
  extern void yyerror(char*);
%}

%token DONE ID NUM DIV MOD

%%

start: list DONE
        ;

list: expr ';' list
        | /* empty */
        ;

expr: expr '+' term { printf("+"); }
       | term
       ;

term: term '*' factor { printf("*"); }
       | term MOD factor { printf("MOD"); }
       | factor
       ;

factor: '(' expr ')'
       | ID { printf("%s", symtable[token_value].lexeme); }
       | NUM { printf("%d", token_value); }
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
