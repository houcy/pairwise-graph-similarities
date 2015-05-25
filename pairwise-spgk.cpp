
#include "pairwise-similarity.hpp"
#include "graph-loader.hpp"
#include "timer.h"
#include <iostream>
#include <cstdlib>

#include <cassert>

int main(int argc, char ** argv) {
  assert(argc > 2);

  std::string cg_1 = argv[1];
  std::string cg_2 = argv[2];
  std::string path = argc > 3 ? argv[3] : ".";
  std::string feature_file = argc > 4 ? argv[4] : "./instructions.lst";

  SimilarityMatrix similarity_matrix(cg_1, cg_2, feature_file, path);

  my_timer_t timer = my_timer_build();

  my_timer_start(timer);
  similarity_matrix.evaluate();
  my_timer_stop(timer);
  my_timer_delta(timer);
  std::cout << timer->delta << std::endl;
  similarity_matrix.printHTML(std::cout);

  return 0;
}
