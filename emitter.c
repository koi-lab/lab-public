/* emitter.c */

#include "global.h"

void emit(int token_type, int token_value) /*  generates output  */
{
    switch (token_type) {
        case '+':
            push(stack, pop(stack) + pop(stack));
            printf("%c\n", token_type);
            break;
        case '-':
            push(stack, pop(stack) - pop(stack));
            printf("%c\n", token_type);
            break;
        case '*':
            push(stack, pop(stack) * pop(stack));
            printf("%c\n", token_type);
            break;
        case '/':
            push(stack, pop(stack) / pop(stack));
            printf("%c\n", token_type);
            break;
        case '=':
            printf("%c\n", token_type);
            break;
        case DIV:
            push(stack, pop(stack) / pop(stack));
            printf("DIV\n");
            break;
        case MOD:
            push(stack, pop(stack) % pop(stack));
            printf("MOD\n");
            break;
        case NUM:
            push(stack, token_value);
            printf("%d\n", token_value);
            break;
        case ID:
            if (symtable[token_value].assignee) {
                // do nothing.
            }
            else {
                if (symtable[token_value].initialized) {
                    push(stack, symtable[token_value].value);
                }
                else {
                    error("️❗️ Used uninitialized variable.");
                }
            }
            printf("%s\n", symtable[token_value].lexeme);
            break;
        default:
            printf("[Unknown token %d, with value %d]\n", token_type,
                   token_value);
    }
}
