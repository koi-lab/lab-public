/* error.c */

#include <stdio.h>
#include <stdlib.h>

extern int lineno;

void error(char* message) /* generates all error messages  */
{
    fflush(stdout);
    fprintf(stderr, "[Error on line %d: %s]\n", lineno, message);
    exit(EXIT_FAILURE); /*  unsuccessful termination  */
}
