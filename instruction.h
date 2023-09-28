#ifndef INSTRUCTION_H
#define INSTRUCTION_H

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

struct Instruction {
  struct Operation operation;
  int argument;
};

const struct Operation getOperation(enum OperationType type);

#endif