#include "tree.h"

#include <stdio.h>
#include <stdlib.h>

#include "array.h"
#include "error.h"
#include "instruction.h"
#include "language.tab.h"
#include "symbol.h"

int label_num = 0;
struct Array* array;

struct Node* makeLeaf(int type, int value) {
    struct Node* p = malloc(sizeof(struct Node));
    p->type = type;
    p->leaf_value = value;
    return p;
};

struct Node* makeNode(int type, struct Node* a0, struct Node* a1,
                    struct Node* a2) {
    struct Node* p = malloc(sizeof(struct Node));
    p->type = type;
    p->args[0] = a0;
    p->args[1] = a1;
    p->args[2] = a2;
    return p;
};

void printSpaces(int count) {
    for (int i = 0; i < count; i++) {
        printf(" ");
    }
}

void printTree(struct Node* p, int level) {
    if (p == NULL) {
        return;
    }

    printSpaces(level * 2);

    switch (p->type) {
        case ID: ;
            printf("%s\n", symtable[p->leaf_value].lexeme);
            break;
        case DONE: ;
            printf("DONE\n");
            break;
        case DIV: ;
            printf("DIV\n");
            break;
        case MOD: ;
            printf("MOD\n");
            break;
        case EQUAL: ;
            printf("=\n");
            break;
        case QUESTIONMARK: ;
            printf("?\n");
            break;
        case COLON: ;
            printf(": ;\n");
            break;
        case PIPE: ;
            printf("|\n");
            break;
        case AMPERSAND: ;
            printf("&\n");
            break;
        case GREATERTHAN: ;
            printf(">\n");
            break;
        case LESSTHAN: ;
            printf("<\n");
            break;
        case PLUS: ;
            printf("+\n");
            break;
        case MINUS: ;
            printf("-\n");
            break;
        case STAR: ;
            printf("*\n");
            break;
        case SLASH: ;
            printf("/\n");
            break;
        case PERCENT: ;
            printf("%%\n");
            break;
        case CARET: ;
            printf("^\n");
            break;
        case LPAREN: ;
            printf("(\n");
            break;
        case RPAREN: ;
            printf(")\n");
            break;
        case NEWLINE: ;
            printf("\\n\n");
            break;
        case SEMICOLON: ;
            printf(";\n");
            break;
        case STATEMENTS: ;
            printf("statements\n");
            break;
        case WHILE: ;
            printf("while\n");
            break;
        case IF: ;
            printf("if\n");
            break;
        case TERNARY: ;
            printf("?: ;\n");
            break;
        case PRINT: ;
            printf("print\n");
            break;
        case READ: ;
            printf("read\n");
            break;
        default: ;
            printf("%d\n", p->leaf_value);
            break;
    }

    for (int i = 0; i < MAX_ARGS; i++) {
        printTree(p->args[i], level + 1);
    }
}

int execute(struct Node* p) {
    if (p == NULL) {
        return GARBAGE;
    }

    switch (p->type) {
        case ID: ;
            if (symtable[p->leaf_value].initialized) {
                struct Instruction* i = malloc(sizeof(struct Instruction));
                i->operation = getOperation(rvalue);
                i->argument = p->leaf_value;
                addElement(array, i);

                return symtable[p->leaf_value].value;
            }
            error("❗️ You use an uninitialized variable.\n");

        case NUM: ;
            struct Instruction* i2 = malloc(sizeof(struct Instruction));
            i2->operation = getOperation(push);
            i2->argument = p->leaf_value;
            addElement(array, i2);

            return p->leaf_value;

        case DIV: ;
            int result1 = execute(p->args[0]) / execute(p->args[1]);

            struct Instruction* i5 = malloc(sizeof(struct Instruction));
            i5->operation = getOperation(divide);
            addElement(array, i5);

            return result1;

        case MOD: ;
            int result2 = execute(p->args[0]) % execute(p->args[1]);

            struct Instruction* i6 = malloc(sizeof(struct Instruction));
            i6->operation = getOperation(modulo);
            addElement(array, i6);

            return result2;

        case EQUAL: ;
            struct Instruction* i7 = malloc(sizeof(struct Instruction));
            i7->operation = getOperation(lvalue);
            i7->argument = p->args[0]->leaf_value;
            addElement(array, i7);

            symtable[p->args[0]->leaf_value].value = execute(p->args[1]);
            symtable[p->args[0]->leaf_value].initialized = true;

            struct Instruction* i8 = malloc(sizeof(struct Instruction));
            i8->operation = getOperation(assign);
            addElement(array, i8);

            return GARBAGE;

        case GREATERTHAN: ;
            int result3 = execute(p->args[0]) > execute(p->args[1]);

            struct Instruction* i9 = malloc(sizeof(struct Instruction));
            i9->operation = getOperation(gt);
            addElement(array, i9);

            return result3;

        case LESSTHAN: ;
            int result4 = execute(p->args[0]) < execute(p->args[1]);

            struct Instruction* i10 = malloc(sizeof(struct Instruction));
            i10->operation = getOperation(lt);
            addElement(array, i10);

            return result4;

        case PLUS: ;
            int result5 = execute(p->args[0]) + execute(p->args[1]);

            struct Instruction* i3 = malloc(sizeof(struct Instruction));
            i3->operation = getOperation(plus);
            addElement(array, i3);

            return result5;

        case MINUS: ;
            int result6 = execute(p->args[0]) - execute(p->args[1]);

            struct Instruction* i11 = malloc(sizeof(struct Instruction));
            i11->operation = getOperation(minus);
            addElement(array, i11);

            return result6;

        case STAR: ;
            int result7 = execute(p->args[0]) * execute(p->args[1]);

            struct Instruction* i4 = malloc(sizeof(struct Instruction));
            i4->operation = getOperation(times);
            addElement(array, i4);

            return result7;

        case SLASH: ;
            int result8 = execute(p->args[0]) / execute(p->args[1]);

            struct Instruction* i12 = malloc(sizeof(struct Instruction));
            i12->operation = getOperation(divide);
            addElement(array, i12);

            return result8;

        case PERCENT: ;
            int result9 = execute(p->args[0]) % execute(p->args[1]);

            struct Instruction* i13 = malloc(sizeof(struct Instruction));
            i13->operation = getOperation(modulo);
            addElement(array, i13);

            return result9;

        case STATEMENTS: ;
            execute(p->args[0]);
            execute(p->args[1]);

            return GARBAGE;

        case IF: ;
            execute(p->args[0]);

            struct Instruction* i20 = malloc(sizeof(struct Instruction));
            i20->operation = getOperation(gofalse);
            i20->argument = label_num++;
            addElement(array, i20);

            execute(p->args[1]);

            struct Instruction* i21 = malloc(sizeof(struct Instruction));
            i21->operation = getOperation(jump);
            i21->argument = label_num++;
            addElement(array, i21);

            struct Instruction* i22 = malloc(sizeof(struct Instruction));
            i22->operation = getOperation(label);
            i22->argument = i20->argument;
            addElement(array, i22);

            execute(p->args[2]);

            struct Instruction* i23 = malloc(sizeof(struct Instruction));
            i23->operation = getOperation(label);
            i23->argument = i21->argument;
            addElement(array, i23);

            return GARBAGE;

        case TERNARY: ;
            execute(p->args[0]);

            struct Instruction* i24 = malloc(sizeof(struct Instruction));
            i24->operation = getOperation(gofalse);
            i24->argument = label_num++;
            addElement(array, i24);

            execute(p->args[1]);

            struct Instruction* i25 = malloc(sizeof(struct Instruction));
            i25->operation = getOperation(jump);
            i25->argument = label_num++;
            addElement(array, i25);

            struct Instruction* i26 = malloc(sizeof(struct Instruction));
            i26->operation = getOperation(label);
            i26->argument = i24->argument;
            addElement(array, i26);

            execute(p->args[2]);

            struct Instruction* i27 = malloc(sizeof(struct Instruction));
            i27->operation = getOperation(label);
            i27->argument = i25->argument;
            addElement(array, i27);

            break;

        case WHILE: ;
            struct Instruction* i28 = malloc(sizeof(struct Instruction));
            i28->operation = getOperation(label);
            i28->argument = label_num++;
            addElement(array, i28);

            execute(p->args[0]);

            struct Instruction* i29 = malloc(sizeof(struct Instruction));
            i29->operation = getOperation(gofalse);
            i29->argument = label_num++;
            addElement(array, i29);

            execute(p->args[1]);

            struct Instruction* i30 = malloc(sizeof(struct Instruction));
            i30->operation = getOperation(jump);
            i30->argument = i28->argument;
            addElement(array, i30);

            struct Instruction* i31 = malloc(sizeof(struct Instruction));
            i31->operation = getOperation(label);
            i31->argument = i29->argument;
            addElement(array, i31);

            break;
    }

    return GARBAGE;
}
