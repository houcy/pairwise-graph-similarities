
#include "spgk.hpp"

#include <iostream>

int main(int argc, char ** argv) {
  spgk_input_t * in_1 = new spgk_input_t(20, 10);
  in_1->randomize();
  in_1->print(std::cout);
  in_1->floyd_warshall();
  in_1->print(std::cout);

  spgk_input_t * in_2 = new spgk_input_t(25, 10);
  in_2->randomize();
  in_2->print(std::cout);
  in_2->floyd_warshall();
  in_2->print(std::cout);

  std::cout << "SPGK = " << SPGK(in_1, in_2) << std::endl;

  return 0;
}

