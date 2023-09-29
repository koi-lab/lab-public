#include "instruction.h"

#include <stdio.h>
#include <stdlib.h>

#include "error.h"

struct Operation operations[] = {{push, "push", 1},
                                 {rvalue, "rvalue", 1},
                                 {lvalue, "lvalue", 1},
                                 {pop, "pop", 0},
                                 {assign, "assign", 0},
                                 {copy, "copy", 0},
                                 {plus, "plus", 0},
                                 {minus, "minus", 0},
                                 {times, "times", 0},
                                 {divide, "divide", 0},
                                 {modulo, "modulo", 0},
                                 {eq, "eq", 0},
                                 {ne, "ne", 0},
                                 {lt, "lt", 0},
                                 {gt, "gt", 0},
                                 {le, "le", 0},
                                 {ge, "ge", 0},
                                 {stackop_or, "stackop_or", 0},
                                 {stackop_and, "stackop_and", 0},
                                 {stackop_not, "stackop_not", 0},
                                 {stackop_read, "stackop_read", 0},
                                 {stackop_write, "stackop_write", 0},
                                 {label, "label", 1},
                                 {jump, "jump", 1},
                                 {gofalse, "gofalse", 1},
                                 {gotrue, "gotrue", 1},
                                 {halt, "halt", 0}};

const struct Operation getOperation(enum OperationType type) {
    for (size_t i = 0; i < sizeof(operations) / sizeof(operations[0]); i++) {
        if (operations[i].type == type) {
            return operations[i];
        }
    }
    error("Operation not found.");
    exit(1);
}
