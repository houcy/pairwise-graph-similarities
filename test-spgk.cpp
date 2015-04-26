
#include "spgk.hpp"

#include <iostream>

int main(int argc, char ** argv) {
  size_t n1 = 100;
  size_t n2 = 100;
  size_t n  = 50;

  size_t prob_edges_over_1000 = 20;

  spgk_input_t * in_1 = new spgk_input_t(n1, n);
  std::cout << "IN[1]::randomize()" << std::endl;
  in_1->randomize(prob_edges_over_1000);
//in_1->print_features(std::cout);
  in_1->toDot("in_1_1.dot");
  std::cout << "IN[1]::floyd_warshall()" << std::endl;
  in_1->floyd_warshall();
  in_1->toDot("in_1_2.dot");
  std::cout << std::endl;

  spgk_input_t * in_2 = new spgk_input_t(n2, n);
  std::cout << "IN[2]::randomize()" << std::endl;
  in_2->randomize(prob_edges_over_1000);
//in_2->print_features(std::cout);
  in_2->toDot("in_2_1.dot");
  std::cout << "IN[2]::floyd_warshall()" << std::endl;
  in_2->floyd_warshall();
  in_2->toDot("in_2_2.dot");
  std::cout << std::endl;

  std::cout << "SPGK = " << SPGK(in_1, in_2) << std::endl;

  return 0;
}

