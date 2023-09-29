#include <stdio.h>
#include <stdlib.h>
#include "array.h"

void initialize(struct Array* array) { 
    array->lastIndex = -1;
}

void addElement(struct Array* array, struct Instruction* instruction) {
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

    printf("    sm.append(Instruction(halt));\n\n    sm.showstate();\n    sm.list_program();\n    sm.set_trace(1);\n    sm.run();\n    sm.showstate();\n  }\n  catch(Exception& e) {\n    std::cout << \"*** Exception caught: \" << e.message() << std::endl;\n    sm.showstate();\n    sm.list_program();\n  }\n\n  return 0;\n}\n");
}
