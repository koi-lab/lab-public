%{
  #include "global.h"

  extern void yyerror(char*);
  int yylex(void);
  
  void print_spaces(int count);
  void print_the_tree(struct Node* p, int level);
  int execute(struct Node* p);

#define MAX_ARGS 3

struct Node {
  int type;
  int leaf_value;
  struct Node* args[MAX_ARGS];
};

struct Node* mkleaf(int type, int value) {
  struct Node* p = malloc(sizeof(struct Node));
  p->type = type;
  p->leaf_value = value;
  return p;
};

struct Node* mknode(int type, struct Node* a0, struct Node* a1, struct Node* a2) {
  struct Node* p = malloc(sizeof(struct Node));
  p->type = type;
  p->args[0] = a0;
  p->args[1] = a1;
  p->args[2] = a2;
  return p;
};

enum OperationType {
    push,         // Push a number
    rvalue,       // Push the contents of a variable
    lvalue,       // Push a reference to a variable
    pop,
    assign,
    copy,
    plus, minus, times, divide, modulo,
    eq, ne, lt, gt, le, ge, // ==, !=, <, >, <=, >=
    stackop_or, stackop_and, stackop_not, // |, &, !
    stackop_read, stackop_write,
    label,        // Realistically, this shouldn't really be an instruction
    jump,
    gofalse,
    gotrue,
    halt
};

struct Operation {
    enum OperationType type;
    const char* name;
    int hasArgument;
};

struct Operation operations[] = {
    { push, "push", 1 },
    { rvalue, "rvalue", 1 },
    { lvalue, "lvalue", 1 },
    { pop, "pop", 0 },
    { assign, "assign", 0 },
    { copy, "copy", 0 },
    { plus, "plus", 0 },
    { minus, "minus", 0 },
    { times, "times",  0 },
    { divide, "divide", 0 },
    { modulo, "modulo", 0 },
    { eq, "eq", 0 },
    { ne, "ne", 0 },
    { lt, "lt", 0 },
    { gt, "gt", 0 },
    { le, "le", 0 },
    { ge, "ge", 0 },
    { stackop_or, "or", 0 },
    { stackop_and, "and", 0 },
    { stackop_not, "not", 0 },
    { stackop_read, "read", 0 },
    { stackop_write, "write", 0 },
    { label, "label", 1 },
    { jump, "jump", 1 },
    { gofalse, "gofalse", 1 },
    { gotrue, "gotrue", 1 },
    { halt, "halt", 0 }
};

const struct Operation getOperation(enum OperationType type) {
    for (size_t i = 0; i < sizeof(operations) / sizeof(operations[0]); i++) {
        if (operations[i].type == type) {
            return operations[i];
        }
    }
  error("Operation not found.");
}

struct Instruction {
  struct Operation operation;
  int argument;
};

#define MAX_ARRAY_SIZE 200

struct Array {
  struct Instruction* data[MAX_ARRAY_SIZE];
  int lastIndex;
};

void initialize(struct Array* array) {
    array->lastIndex = -1;
}

void push_to_array(struct Array* array, struct Instruction* instruction) {
    if (array->lastIndex >= MAX_ARRAY_SIZE) {
        printf("Array overflow\n");
        return;
    }
    array->data[++array->lastIndex] = instruction;
}

void printArray(struct Array* array) {
    printf("#include <iostream>\n#include <vector>\n#include <map>\n#include <string>\n#include <sstream>\n#include \"StackMachine.h\"\n\nint main() {\n  StackMachine sm;\n\n  try {\n");

    for (int i = 0; i < array->lastIndex + 1; ++i) {
      if (array->data[i]->operation.hasArgument) {
        printf("    sm.append(Instruction(%s, %d));\n", array->data[i]->operation.name, array->data[i]->argument);
      }
      else {
        printf("    sm.append(Instruction(%s));\n", array->data[i]->operation.name); 
      }
    }

    printf("    sm.append(Instruction(halt));\n\n    sm.showstate();\n    sm.list_program();\n    sm.set_trace(1);\n    sm.run();\n    sm.showstate();\n  }\n  catch(Exception& e) {\n    std::cout << \"*** Exception caught: \" << e.message() << std::endl;\n    sm.showstate();\n    sm.list_program();\n}\n\n  return 0;\n}\n");
}

int label_num = 0;
struct Array* array;
%}

%token <int_value> NUM ID
%token <p> STATEMENTS IF WHILE DONE DIV MOD EQUAL QUESTIONMARK COLON PIPE AMPERSAND GREATERTHAN LESSTHAN PLUS MINUS STAR SLASH PERCENT CARET LPAREN RPAREN NEWLINE SEMICOLON LCURLYBRACKET RCURLYBRACKET PRINT ELSE READ END
%left EQUAL
%left QUESTIONMARK COLON
%left PIPE AMPERSAND
%left GREATERTHAN LESSTHAN
%left PLUS MINUS
%left STAR SLASH DIV MOD PERCENT
%left CARET

%union value {
  struct Node* p;
  int int_value;
}

%type <p> expr;
%type <p> statements;
%type <p> else;

%%

start: statements { } END { array = malloc(sizeof(struct Array)); initialize(array); execute($1); printArray(array); } start DONE
       | /* empty */
       ;

statements:  expr SEMICOLON statements { $$ = mknode(STATEMENTS, $1, $3, NULL); }
        | /* empty */ { $$ = NULL; }
        ;

else:  ELSE LCURLYBRACKET statements RCURLYBRACKET { $$ = $3; }
        | /* empty */ { $$ = NULL; }

expr: LPAREN expr RPAREN                    { $$ = $2; }
    | WHILE LPAREN expr RPAREN LCURLYBRACKET statements RCURLYBRACKET { $$ = mknode(WHILE, $3, $6, NULL); }
    | IF LPAREN expr RPAREN LCURLYBRACKET statements RCURLYBRACKET else { $$ = mknode(IF, $3, $6, $8); }
    | expr QUESTIONMARK expr COLON expr     { $$ = mknode(TERNARY, $1, $3, $5); }
    | expr AMPERSAND expr                   { $$ = mknode(AMPERSAND, $1, $3, NULL); }
    | expr PIPE expr                        { $$ = mknode(PIPE, $1, $3, NULL); }
    | expr GREATERTHAN expr                 { $$ = mknode(GREATERTHAN, $1, $3, NULL); }
    | expr LESSTHAN expr                    { $$ = mknode(LESSTHAN, $1, $3, NULL); }
    | expr PLUS expr                        { $$ = mknode(PLUS, $1, $3, NULL); }
    | expr MINUS expr                       { $$ = mknode(MINUS, $1, $3, NULL); }
    | expr STAR expr                        { $$ = mknode(STAR, $1, $3, NULL); }
    | expr SLASH expr                       { $$ = mknode(SLASH, $1, $3, NULL); }
    | expr DIV expr                         { $$ = mknode(DIV, $1, $3, NULL); }
    | expr MOD expr                         { $$ = mknode(MOD, $1, $3, NULL); }
    | expr PERCENT expr                     { $$ = mknode(PERCENT, $1, $3, NULL); }
    | expr CARET expr                       { $$ = mknode(CARET, $1, $3, NULL); }
    | expr EQUAL expr                       { $$ = mknode(EQUAL, $1, $3, NULL); }
    | NUM                                   { $$ = mkleaf(NUM, $1); }
    | ID                                    { $$ = mkleaf(ID, $1); }
    | PRINT LPAREN ID RPAREN                { $$ = mknode(PRINT, mkleaf(ID, $3), NULL, NULL); }
    | READ LPAREN ID RPAREN                 { $$ = mknode(READ, mkleaf(ID, $3), NULL, NULL); }
    ;
%%

// Function to print spaces for indentation
void print_spaces(int count) {
    for (int i = 0; i < count; i++) {
        printf(" ");
    }
}

void print_the_tree(struct Node* p, int level) {
    if (p == NULL) {
        return;
    }

    // Print spaces for indentation
    print_spaces(level * 2);

    // Print the node based on its type
    switch (p->type) {
        case ID: printf("%s\n", symtable[p->leaf_value].lexeme); break;
        case DONE: printf("DONE\n"); break;
        case DIV: printf("DIV\n"); break;
        case MOD: printf("MOD\n"); break;
        case EQUAL: printf("=\n"); break;
        case QUESTIONMARK: printf("?\n"); break;
        case COLON: printf(":\n"); break;
        case PIPE: printf("|\n"); break;
        case AMPERSAND: printf("&\n"); break;
        case GREATERTHAN: printf(">\n"); break;
        case LESSTHAN: printf("<\n"); break;
        case PLUS: printf("+\n"); break;
        case MINUS: printf("-\n"); break;
        case STAR: printf("*\n"); break;
        case SLASH: printf("/\n"); break;
        case PERCENT: printf("%%\n"); break;
        case CARET: printf("^\n"); break;
        case LPAREN: printf("(\n"); break;
        case RPAREN: printf(")\n"); break;
        case NEWLINE: printf("\\n\n"); break;
        case SEMICOLON: printf(";\n"); break;
        case STATEMENTS: printf("statements\n"); break;
        case WHILE: printf("while\n"); break;
        case IF: printf("if\n"); break;
        case TERNARY: printf("?:\n"); break;
        case PRINT: printf("print\n"); break;
        case READ: printf("read\n"); break;
        default: printf("%d\n", p->leaf_value); break;
    }

    // Recursively print the children nodes
    for (int i = 0; i < MAX_ARGS; i++) {
        print_the_tree(p->args[i], level + 1);
    }
}

void yyerror(char *s) {
    fprintf(stderr, "%s\n", s);
    exit(1);
}

void parse() {
  yyparse();
}































int execute(struct Node* p) {
    if (p == NULL) {
        return GARBAGE;
    }

    switch (p->type) {
        case ID:
            if (symtable[p->leaf_value].initialized) {
            
            struct Instruction* i = malloc(sizeof(struct Instruction));
            i->operation = getOperation(rvalue);
            i->argument = p->leaf_value;
            push_to_array(array, i);

            return symtable[p->leaf_value].value;
          }
          error("❗️ You use an uninitialized variable.\n");

        case NUM:
            struct Instruction* i2 = malloc(sizeof(struct Instruction));
            i2->operation = getOperation(push);
            i2->argument = p->leaf_value;
            push_to_array(array, i2);

            return p->leaf_value;

        case DIV:
            int result1 = execute(p->args[0]) / execute(p->args[1]);

            struct Instruction* i5 = malloc(sizeof(struct Instruction));
            i5->operation = getOperation(divide);
            push_to_array(array, i5);

            return result1;

        case MOD:
            int result2 = execute(p->args[0]) % execute(p->args[1]);

            struct Instruction* i6 = malloc(sizeof(struct Instruction));
            i6->operation = getOperation(modulo);
            push_to_array(array, i6);

            return result2;

        case EQUAL:
            struct Instruction* i7 = malloc(sizeof(struct Instruction));
            i7->operation = getOperation(lvalue);
            i7->argument = p->args[0]->leaf_value;
            push_to_array(array, i7);

            symtable[p->args[0]->leaf_value].value = execute(p->args[1]);
            symtable[p->args[0]->leaf_value].initialized = true;

            struct Instruction* i8 = malloc(sizeof(struct Instruction));
            i8->operation = getOperation(assign);
            push_to_array(array, i8);

            return GARBAGE;

        case GREATERTHAN:
            int result3 = execute(p->args[0]) > execute(p->args[1]);

            struct Instruction* i9 = malloc(sizeof(struct Instruction));
            i9->operation = getOperation(gt);
            push_to_array(array, i9);

            return result3;

        case LESSTHAN:
            int result4 = execute(p->args[0]) < execute(p->args[1]);

            struct Instruction* i10 = malloc(sizeof(struct Instruction));
            i10->operation = getOperation(lt);
            push_to_array(array, i10);

            return result4;

        case PLUS:
            int result5 = execute(p->args[0]) + execute(p->args[1]);

            struct Instruction* i3 = malloc(sizeof(struct Instruction));
            i3->operation = getOperation(plus);
            push_to_array(array, i3);

            return result5;

        case MINUS:
            int result6 = execute(p->args[0]) - execute(p->args[1]);

            struct Instruction* i11 = malloc(sizeof(struct Instruction));
            i11->operation = getOperation(minus);
            push_to_array(array, i11);

            return result6;

        case STAR:
            int result7 = execute(p->args[0]) * execute(p->args[1]);

            struct Instruction* i4 = malloc(sizeof(struct Instruction));
            i4->operation = getOperation(times);
            push_to_array(array, i4);

            return result7;

        case SLASH:
            int result8 = execute(p->args[0]) / execute(p->args[1]);

            struct Instruction* i12 = malloc(sizeof(struct Instruction));
            i12->operation = getOperation(divide);
            push_to_array(array, i12);

            return result8;

        case PERCENT:
            int result9 = execute(p->args[0]) % execute(p->args[1]);

            struct Instruction* i13 = malloc(sizeof(struct Instruction));
            i13->operation = getOperation(modulo);
            push_to_array(array, i13);

            return result9;

        case STATEMENTS:
            execute(p->args[0]);
            execute(p->args[1]);

            return GARBAGE;

        case IF:
            execute(p->args[0]);

            struct Instruction* i20 = malloc(sizeof(struct Instruction));
            i20->operation = getOperation(gofalse);
            i20->argument = label_num++;
            push_to_array(array, i20);

            execute(p->args[1]);

            struct Instruction* i21 = malloc(sizeof(struct Instruction));
            i21->operation = getOperation(jump);
            i21->argument = label_num++;
            push_to_array(array, i21);

            struct Instruction* i22 = malloc(sizeof(struct Instruction));
            i22->operation = getOperation(label);
            i22->argument = i20->argument;
            push_to_array(array, i22);

            execute(p->args[2]);

            struct Instruction* i23 = malloc(sizeof(struct Instruction));
            i23->operation = getOperation(label);
            i23->argument = i21->argument;
            push_to_array(array, i23);

            return GARBAGE;

        case TERNARY:
            execute(p->args[0]);

            struct Instruction* i24 = malloc(sizeof(struct Instruction));
            i24->operation = getOperation(gofalse);
            i24->argument = label_num++;
            push_to_array(array, i24);

            execute(p->args[1]);

            struct Instruction* i25 = malloc(sizeof(struct Instruction));
            i25->operation = getOperation(jump);
            i25->argument = label_num++;
            push_to_array(array, i25);

            struct Instruction* i26 = malloc(sizeof(struct Instruction));
            i26->operation = getOperation(label);
            i26->argument = i24->argument;
            push_to_array(array, i26);

            execute(p->args[2]);

            struct Instruction* i27 = malloc(sizeof(struct Instruction));
            i27->operation = getOperation(label);
            i27->argument = i25->argument;
            push_to_array(array, i27);

            break;

        case WHILE:
            struct Instruction* i28 = malloc(sizeof(struct Instruction));
            i28->operation = getOperation(label);
            i28->argument = label_num++;
            push_to_array(array, i28);

            execute(p->args[0]);

            struct Instruction* i29 = malloc(sizeof(struct Instruction));
            i29->operation = getOperation(gofalse);
            i29->argument = label_num++;
            push_to_array(array, i29);

            execute(p->args[1]);

            struct Instruction* i30 = malloc(sizeof(struct Instruction));
            i30->operation = getOperation(jump);
            i30->argument = i28->argument;
            push_to_array(array, i30);

            struct Instruction* i31 = malloc(sizeof(struct Instruction));
            i31->operation = getOperation(label);
            i31->argument = i29->argument;
            push_to_array(array, i31);

            break;
    }

    return GARBAGE;
}