
#include "spgk.hpp"

#include "timer.h"

#include <iostream>

#include <cstdlib>

int main(int argc, char ** argv) {
  size_t n1 = argc > 1 ? atoi(argv[1]) : 100;
  size_t n2 = argc > 2 ? atoi(argv[2]) : 100;
  size_t n  = argc > 3 ? atoi(argv[3]) :  50;

  size_t prob_edges_over_1000 = argc > 4 ? atoi(argv[4]) : 20;

  my_timer_t timer = my_timer_build();

  spgk_input_t * in_1 = new spgk_input_t(n1, n);

  std::cout << "IN[1]::randomize()" << std::endl;
  in_1->randomize(prob_edges_over_1000);
  std::cout << "IN[1]::save(\"in_1_before.dot\")" << std::endl;
  in_1->toDot("in_1_before.dot");

  my_timer_start(timer);
  in_1->floyd_warshall();
  my_timer_stop(timer);
  my_timer_delta(timer);
  std::cout << "IN[1]::floyd_warshall() (in " << timer->delta << "ms)" << std::endl;
  std::cout << "IN[1]::save(\"in_1_after.dot\")" << std::endl;
  in_1->toDot("in_1_after.dot");

//in_1->print_features(std::cout);
  std::cout << std::endl;

  spgk_input_t * in_2 = new spgk_input_t(n2, n);

  std::cout << "IN[2]::randomize()" << std::endl;
  in_2->randomize(prob_edges_over_1000);
  std::cout << "IN[2]::save(\"in_2_before.dot\")" << std::endl;
  in_2->toDot("in_2_before.dot");

  my_timer_start(timer);
  in_2->floyd_warshall();
  my_timer_stop(timer);
  my_timer_delta(timer);
  std::cout << "IN[2]::floyd_warshall() (in " << timer->delta << "ms)" << std::endl;
  std::cout << "IN[2]::save(\"in_2_after.dot\")" << std::endl;
  in_2->toDot("in_2_after.dot");

//in_2->print_features(std::cout);
  std::cout << std::endl;

  my_timer_start(timer);
  float spgk = SPGK(in_1, in_2);
  my_timer_stop(timer);
  my_timer_delta(timer);
  
  std::cout << "SPGK(IN[1], IN[2]) = " << spgk << " (in " << timer->delta << "ms)" << std::endl;

  return 0;
}

