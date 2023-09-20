// /* parser.c -- without the optimizations */

// #include "global.h"

// int lookahead;
// Stack *stack;

// void match(int);
// void start(), list(), assignment(), expr(), moreterms(), term(), morefactors(),
//     factor(), highestfactor(), exprOrAssignment(), operatorExpr();

// void parse() /*  parses and translates expression list  */
// {
//     stack = malloc(sizeof(Stack));
//     initialize(stack);
//     lookahead = lexan();
//     start();
// }

// void start() {
//     /* Just one production for start, so we don't need to check lookahead */
//     list();
//     match(DONE);
// }

// void list() {
//     if (lookahead == ID) {
//         int id_numer = token_value;
//         match(ID);
//         exprOrAssignment(id_numer);
//         list();
//     } else if (lookahead == NUM) {
//         int num_value = token_value;
//         match(NUM);
//         emit(NUM, num_value);
//         operatorExpr();
//         list();
//     } else if (lookahead == '(') {
//         match('(');
//         expr();
//         match(')');
//         operatorExpr();
//         list();
//     }
//     else {
//         /* Empty */
//     }
// }

// void exprOrAssignment(int id_numer) {
//     if (lookahead == '=') {
//         symtable[id_numer].theVariableThatIsGoingToBeAssignedAValue = true;
//         emit(ID, id_numer);
//         assignment(id_numer);
//     } else {
//         emit(ID, id_numer);
//         operatorExpr();
//     }
// }

// void assignment(int id_numer) {
//     if (lookahead == '=') {
//         match('=');
//         expr();
//         emit('=', token_value);
//         symtable[id_numer].value = pop(stack);
//         symtable[id_numer].initialized = true;
//         symtable[id_numer].theVariableThatIsGoingToBeAssignedAValue = false;
//         printf("'%s' is now %d.\n", symtable[id_numer].lexeme,
//                symtable[id_numer].value);
//         match(';');
//     } else {
//         error("❗️ Syntax error");
//     }
// }

// void operatorExpr() {
//     if (lookahead == '+' || lookahead == '-' || lookahead == '*' ||
//         lookahead == '/' || lookahead == DIV || lookahead == MOD ||
//         lookahead == '^' || lookahead == EOF) {
//         moreterms();
//         morefactors();
//         highestfactor();
//         operatorExpr();
//     } else if (lookahead == ';') {
//         printf("The result of the expression is %d.\n", pop(stack));
//         match(';');
//     } else {
//         error("❗️ Syntax error");
//     }
// }

// void expr() {
//     /* Just one production for expr, so we don't need to check lookahead */
//     term();
//     moreterms();
// }

// void moreterms() {
//     if (lookahead == '+') {
//         match('+');
//         term();
//         emit('+', token_value);
//         moreterms();
//     } else if (lookahead == '-') {
//         match('-');
//         term();
//         emit('-', token_value);
//         moreterms();
//     } else {
//         /* Empty */
//     }
// }

// void term() {
//     /* Just one production for term, so we don't need to check lookahead */
//     factor();
//     highestfactor();
//     morefactors();
// }

// void morefactors() {
//     if (lookahead == '*') {
//         match('*');
//         factor();
//         highestfactor();
//         emit('*', token_value);
//         morefactors();
//     } else if (lookahead == '/') {
//         match('/');
//         factor();
//         highestfactor();
//         emit('/', token_value);
//         morefactors();
//     } else if (lookahead == DIV) {
//         match(DIV);
//         factor();
//         highestfactor();
//         emit(DIV, token_value);
//         morefactors();
//     } else if (lookahead == MOD) {
//         match(MOD);
//         factor();
//         highestfactor();
//         emit(MOD, token_value);
//         morefactors();
//     } else {
//         /* Empty */
//     }
// }

// void highestfactor() {
//     if (lookahead == '^') {
//         match('^');
//         factor();
//         emit('^', token_value);
//         highestfactor();
//     } else {
//         /* Empty */
//     }
// }

// void factor() {
//     if (lookahead == '(') {
//         match('(');
//         expr();
//         match(')');
//     } else if (lookahead == ID) {
//         int id_number = token_value;
//         match(ID);
//         emit(ID, id_number);
//     } else if (lookahead == NUM) {
//         int num_value = token_value;
//         match(NUM);
//         emit(NUM, num_value);
//     } else
//         error("syntax error in factor");
// }

// void match(int t) {
//     if (lookahead == t)
//         lookahead = lexan();
//     else
//         error("syntax error in match");
// }
