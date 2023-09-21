/* global.h */

#include <stdio.h>  /* include declarations for i/o routines */
#include <ctype.h>  /* ... and for character test routines */
#include <stdlib.h> /* ... and for some standard routines, such as exit */
#include <string.h> /* ... and for string routines */
#include <stdbool.h>
#include "language.tab.h"

#define MAX_ID_LENGTH  128  /* for the buffer size */

#define NONE   -1
#define EOS    '\0'

extern int token_value;   /*  value of token attribute */  
extern int lineno;

struct symentry {  /*  form of symbol table entry  */
    char *lexeme; 
    int  token_type;    
    int  value;
    bool  initialized;
    bool theVariableThatIsGoingToBeAssignedAValue;
};

extern struct symentry symtable[];  /* symbol table  */

extern void error(char* message);  /*  generates all error messages  */
extern void parse();  /*  parses and translates expression list  */
extern int insert(char *s, int token_type);    /*  returns position of entry for s */
extern int lookup(char *s);         /* returns position of entry for s, or -1 if not found */
