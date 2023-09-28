#ifndef SYMBOL_H
#define SYMBOL_H

#include <stdbool.h>

#define MAX_SYMBOLS 100 /* size of symbol table */


struct symentry { /*  form of symbol table entry  */
    char *lexeme;
    int token_type;
    int value;
    bool initialized;
    bool theVariableThatIsGoingToBeAssignedAValue;
};

extern struct symentry symtable[MAX_SYMBOLS];

int lookup(char *s); /* returns position of entry for s, or -1 if not found */
int insert(char *s, int token_type); /*  returns position of entry for s */

#endif