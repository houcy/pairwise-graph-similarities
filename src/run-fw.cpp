#include "spgk.hpp"
#include "graph-loader.hpp"
#include "timer.h"
#include <iostream>
#include <fstream>
#include <cstdlib>
#include <cassert>

int main(int argc, char ** argv) {
  assert(argc == 2);

  std::map<std::string, size_t> instruction_dictionary;
  initInstructionDictionary(instruction_dictionary);

  my_timer_t timer = my_timer_build();
  spgk_input_t * cfg;

  size_t stats[3];

  cfg = loadCFG(argv[1], instruction_dictionary);

  stats[0] = cfg->num_nodes;
  stats[1] = cfg->getNumEdges();

  my_timer_start(timer);
  cfg->floyd_warshall();
  my_timer_stop(timer);
  my_timer_delta(timer);

  stats[2] = cfg->getNumEdges();

  for (size_t i = 0; i < 3; i++)
    std::cout << stats[i] << ",";
  std::cout << timer->delta << std::endl;

  return 0;
}
