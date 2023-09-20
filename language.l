%{
  #include "language.tab.h" // Def. of token codes: LT, LE, ELSE etc.
  extern int yylval;
%}

delim	[\t\n]
ws	{delim}+
letter	[A-Za-z]
digit	[0-9]
id	{letter}({letter}|{digit})*

%%

{ws}	{ /* no action and no return */ }
{id}	{ yylval = install_id(yytext, yyleng);
          return ID; }
"="       { return EQUAL; }
"?"       { return QUESTIONMARK; }
":"       { return COLON; }
"&"       { return AMPERSAND; }
"|"       { return PIPE; }
">"       { return GREATERTHAN; }
"<"       { return LESSTHAN; }
"%"       { return PERCENT; }
"^"       { return CARET; }
"("       { return LPAREN; }
")"       { return RPAREN; }
"+"       { return PLUS; }
"-"       { return MINUS; }
"*"       { return STAR; }
"/"       { return SLASH; }
\n        { return NEWLINE; }
[0-9]+    { yylval = atoi(yytext); return NUM; }
.         { printf("Ignoring invalid character '%s'\n", yytext); }

%%

int install_id(char* s, int n) {
  printf("Inserting into symbol table: '%s'\n", s);
  // ...
}

int install_num(char* s, int n) {
  double d;
  sscanf(s, "%lf", &d);
  printf("Found a number: %f\n", d);
  // ...
}

int yywrap() {
  printf("Calling yywrap...\n");
  return 1;
}

int main() {
  while (1)
    yylex();
  return 0;
}