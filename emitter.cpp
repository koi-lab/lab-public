/* emitter.c */

#include "global.h"

Stack *stack;

int power(int x, int y) {
    int result = 1;

    for (int i = 0; i < y; ++i) {
        result *= x;
    }

    return result;
}

void emit(int token_type, int token_value) /*  generates output  */
{
    // printStack(stack);
    switch (token_type) {
        case '+':
            push(stack, pop(stack) + pop(stack));
            printf("%c\n", token_type);
            break;
        case '-': ;
            int a2 = pop(stack);
            int a1 = pop(stack);
            push(stack, a1 - a2);
            printf("%c\n", token_type);
            break;
        case '*':
            push(stack, pop(stack) * pop(stack));
            printf("%c\n", token_type);
            break;
        case '/': ;
            int b2 = pop(stack);
            int b1 = pop(stack);
            push(stack, b1/b2);
            printf("%c\n", token_type);
            break;
        case '^': ;
            int e2 = pop(stack);
            int e1 = pop(stack);
            push(stack, power(e1, e2));
            printf("%c\n", token_type);
            break;
        case '=':
            printf("%c\n", token_type);
            break;
        case DIV: ;
            int c2 = pop(stack);
            int c1 = pop(stack);
            push(stack, c1/c2);
            printf("DIV\n");
            break;
        case MOD: ;
            int d2 = pop(stack);
            int d1 = pop(stack);
            push(stack, d1%d2);
            printf("MOD\n");
            break;
        case NUM:
            push(stack, token_value);
            printf("%d\n", token_value);
            break;
        case ID:
            if (symtable[token_value].theVariableThatIsGoingToBeAssignedAValue) {
                // do nothing.
            }
            else {
                if (symtable[token_value].initialized) {
                    push(stack, symtable[token_value].value);
                }
                else {
                    error("️❗️ooeeue Used uninitialized variable.");
                }
            }
            printf("%s\n", symtable[token_value].lexeme);
            break;
        default:
            printf("[Unknown token %d, with value %d]\n", token_type,
                   token_value);
    }
}
