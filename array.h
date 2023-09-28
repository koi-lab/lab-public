#include "instruction.h"

#define MAX_ARRAY_SIZE 200

struct Array {
  struct Instruction* data[MAX_ARRAY_SIZE];
  int lastIndex;
};

void initialize(struct Array* array);
void push_to_array(struct Array* array, struct Instruction* instruction);
void printArray(struct Array* array);