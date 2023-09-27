

#include <iostream>
#include <vector>
#include <map>
#include <string>
#include <sstream>
#include "StackMachine.h"

int main() {
  StackMachine sm;

  try {
    sm.append(Instruction(lvalue, 0));
    sm.append(Instruction(push, 1));
    sm.append(Instruction(assign));
    sm.append(Instruction(lvalue, 1));
    sm.append(Instruction(rvalue, 0));
    sm.append(Instruction(push, 2));
    sm.append(Instruction(plus));
    sm.append(Instruction(assign));

    sm.showstate();
    sm.list_program();
    sm.set_trace(1);
    sm.run();
    sm.showstate();
  }
  catch(Exception& e) {
    std::cout << "*** Exception caught: " << e.message() << std::endl;
    sm.showstate();
    sm.list_program();
}

  return 0;
}
