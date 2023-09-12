#include "global.h"

void initialize(Stack* stack) {
    stack->top = -1;
}

void push(Stack* stack, int value) {
    if (stack->top >= MAX_STACK_SIZE) {
        printf("Stack overflow\n");
        return;
    }
    stack->data[++stack->top] = value;
}

int pop(Stack* stack) {
    if (stack->top < 0) {
        printf("Stack underflow\n");
        return -1;
    }
    return stack->data[stack->top--];
}

int peek(Stack* stack) {
    if (stack->top < 0) {
        printf("Stack is empty\n");
        return -1;
    }
    return stack->data[stack->top];
}

void printStack(Stack* stack) {
    if (stack->top < 0) {
        printf("Stack is empty.\n");
        return;
    }

    printf("Stack elements from top to bottom:\n");
    for (int i = stack->top; i >= 0; i--) {
        printf("%d\n", stack->data[i]);
    }
}

