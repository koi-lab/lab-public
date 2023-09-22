%{
  #include "global.h"
  #include "language.tab.h"
  union value install_id(char* s, int n);
  extern union value yylval;
  int  token_value = NONE;
  int  lineno = 1;
%}

delim	[\t\n]
ws	{delim}+
letter	[A-Za-z]
digit	[0-9]
id	{letter}({letter}|{digit})*

%%

{ws}	{ /* no action and no return */ }
"print"    { return PRINT; }
"read"     { return READ; }
"mod"      { return MOD; }
"div"      { return DIV; }
"while"    { return WHILE; }
"if"       { return IF; }
"else"     { return ELSE; }
"end"      { return END; }
"{"        { return LCURLYBRACKET; }
"}"        { return RCURLYBRACKET; }
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
";"       { return SEMICOLON; }
\n        { return NEWLINE; }
[0-9]+    { yylval = (union value) atoi(yytext); return NUM; }
.        

%%

union value install_id(char* s, int n) {
    int id_number = lookup(s);
    if (id_number == -1)
        id_number = insert(s, ID);
    token_value = id_number;

    return (union value) id_number;
}

int yywrap() {
  return 1;
}