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

enum StackOp {
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

struct Instruction {
  enum StackOp op;
  int argument;
};

#define MAX_STACK_SIZE 200

struct Stack {
  struct Instruction* data[MAX_STACK_SIZE];
  int top;
};

void initialize(struct Stack* stack) {
    stack->top = -1;
}

void push_to_stack(struct Stack* stack, struct Instruction* instruction) {
    if (stack->top >= MAX_STACK_SIZE) {
        printf("Stack overflow\n");
        return;
    }
    stack->data[++stack->top] = instruction;
}

// Function to return a literal string for a given enum value
const char* stackOpToString(enum StackOp op) {
    switch (op) {
        case push:
            return "push";
        case rvalue:
            return "rvalue";
        case lvalue:
            return "lvalue";
        case pop:
            return "pop";
        case assign:
            return "assign";
        case copy:
            return "copy";
        case plus:
            return "plus";
        case minus:
            return "minus";
        case times:
            return "times";
        case divide:
            return "divide";
        case modulo:
            return "modulo";
        case eq:
            return "eq";
        case ne:
            return "ne";
        case lt:
            return "lt";
        case gt:
            return "gt";
        case le:
            return "le";
        case ge:
            return "ge";
        case stackop_or:
            return "stackop_or";
        case stackop_and:
            return "stackop_and";
        case stackop_not:
            return "stackop_not";
        case stackop_read:
            return "stackop_read";
        case stackop_write:
            return "stackop_write";
        case label:
            return "label";
        case jump:
            return "jump";
        case gofalse:
            return "gofalse";
        case gotrue:
            return "gotrue";
        case halt:
            return "halt";
        default:
            return "unknown";
    }
}

void printStack(struct Stack* stack) {
    printf("Stack elements:\n");
    for (int i = 0; i < stack->top + 1; ++i) {
        printf("sm.append(Instruction(%s, %d));\n", stackOpToString(stack->data[i]->op), stack->data[i]->argument);
    }
    printf("\n");
}










int label_num = 0;
struct Stack* stack;
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

start: statements { printf("\n"); print_the_tree($1, 0); printf("\n"); } END { stack = malloc(sizeof(struct Stack)); initialize(stack); execute($1); printf("\n\n"); printStack(stack); } start DONE
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
        case ELSE: printf("else\n"); break;
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
                i->op = rvalue;
                i->argument = symtable[p->leaf_value].value;
                push_to_stack(stack, i);

                break;
            }
            error("❗️ You use an uninitialized variable.\n");

        case NUM:
            struct Instruction* i2 = malloc(sizeof(struct Instruction));
            i2->op = push;
            i2->argument = p->leaf_value;
            push_to_stack(stack, i2);

            break;

        case DIV:
            execute(p->args[0]);
            execute(p->args[1]);

            struct Instruction* i5 = malloc(sizeof(struct Instruction));
            i5->op = divide;
            push_to_stack(stack, i5);

            break;

        case MOD:
            execute(p->args[0]);
            execute(p->args[1]);

            struct Instruction* i6 = malloc(sizeof(struct Instruction));
            i6->op = modulo;
            push_to_stack(stack, i6);

            break;

        case EQUAL:
            printf("🎉");

            struct Instruction* i7 = malloc(sizeof(struct Instruction));
            i7->op = lvalue;
            i7->argument = p->args[0]->leaf_value;
            push_to_stack(stack, i7);

            execute(p->args[1]);

            struct Instruction* i8 = malloc(sizeof(struct Instruction));
            i8->op = assign;
            push_to_stack(stack, i8);


            break;

            // case PIPE:
            //     return execute(p->args[0]) | execute(p->args[1]);

            // case AMPERSAND:
            //     return execute(p->args[0]) & execute(p->args[1]);

        case GREATERTHAN:
            execute(p->args[0]);
            execute(p->args[1]);

            struct Instruction* i9 = malloc(sizeof(struct Instruction));
            i9->op = gt;
            push_to_stack(stack, i9);

            break;

        case LESSTHAN:
            execute(p->args[0]);
            execute(p->args[1]);

            struct Instruction* i10 = malloc(sizeof(struct Instruction));
            i10->op = lt;
            push_to_stack(stack, i10);

            break;

        case PLUS:
            execute(p->args[0]);
            execute(p->args[1]);

            struct Instruction* i3 = malloc(sizeof(struct Instruction));
            i3->op = plus;
            push_to_stack(stack, i3);

            break;

        case MINUS:
            execute(p->args[0]);
            execute(p->args[1]);

            struct Instruction* i11 = malloc(sizeof(struct Instruction));
            i11->op = minus;
            push_to_stack(stack, i11);

            break;

        case STAR:
            execute(p->args[0]);
            execute(p->args[1]);

            struct Instruction* i4 = malloc(sizeof(struct Instruction));
            i4->op = times;
            push_to_stack(stack, i4);

            break;

        case SLASH:
            execute(p->args[0]);
            execute(p->args[1]);

            struct Instruction* i12 = malloc(sizeof(struct Instruction));
            i12->op = divide;
            push_to_stack(stack, i12);

            break;

        case PERCENT:
            execute(p->args[0]);
            execute(p->args[1]);

            struct Instruction* i13 = malloc(sizeof(struct Instruction));
            i13->op = modulo;
            push_to_stack(stack, i13);

            break;

            // case CARET:
            //     return pow(execute(p->args[0]), execute(p->args[1]));

        case STATEMENTS:
            execute(p->args[0]);
            execute(p->args[1]);

            break;

        case IF:
            execute(p->args[0]);

            struct Instruction* i20 = malloc(sizeof(struct Instruction));
            i20->op = gofalse;
            i20->argument = label_num++;
            push_to_stack(stack, i20);

            execute(p->args[1]);

            struct Instruction* i21 = malloc(sizeof(struct Instruction));
            i21->op = jump;
            i21->argument = label_num++;
            push_to_stack(stack, i21);

            struct Instruction* i22 = malloc(sizeof(struct Instruction));
            i22->op = label;
            i22->argument = i20->argument;
            push_to_stack(stack, i22);

            execute(p->args[2]);

            struct Instruction* i23 = malloc(sizeof(struct Instruction));
            i23->op = label;
            i23->argument = i21->argument;
            push_to_stack(stack, i23);

            break;

        // case TERNARY:
        //     execute(p->args[0]);

        //     struct Instruction* i20 = malloc(sizeof(struct Instruction));
        //     i20->op = gofalse;
        //     i20->argument = label_num++;
        //     push_to_stack(stack, i20);

        //     execute(p->args[1]);

        //     struct Instruction* i21 = malloc(sizeof(struct Instruction));
        //     i21->op = jump;
        //     i21->argument = label_num++;
        //     push_to_stack(stack, i21);

        //     struct Instruction* i22 = malloc(sizeof(struct Instruction));
        //     i22->op = label;
        //     i22->argument = i20->argument;
        //     push_to_stack(stack, i22);

        //     execute(p->args[2]);

        //     struct Instruction* i23 = malloc(sizeof(struct Instruction));
        //     i23->op = label;
        //     i23->argument = i21->argument;
        //     push_to_stack(stack, i23);

        //     break;

        case WHILE:
            while (execute(p->args[0])) {
                execute(p->args[1]);
            }
            return GARBAGE;

            // case PRINT:
            //     printf("%d\n", symtable[p->args[0]->leaf_value].value);
            //     break;

            // case READ:
            //     int temp;
            //     printf("Enter an integer: ");
            //     scanf(" %d", &temp);
            //     symtable[p->args[0]->leaf_value].value = temp;
            //     break;
    }
}