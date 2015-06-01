#include "spgk.hpp"
#include "graph-loader.hpp"
#include "timer.h"
#include <iostream>
#include <fstream>
#include <cstdlib>
#include <cassert>

int main(int argc, char ** argv) {
  assert(argc == 3);
  std::map<std::string, size_t> instruction_dictionary;

  std::string line;
  std::ifstream file;
  size_t cnt = 0;
  file.open("instructions.lst");
  while(!file.eof()) {
    std::getline(file, line);
    instruction_dictionary.insert(std::pair<std::string, size_t>(line, cnt++));
  }
  file.close();

  my_timer_t timer = my_timer_build();
  spgk_input_t * cfg_0;
  spgk_input_t * cfg_1;

  size_t stats[6];
  //
  {
    cfg_0 = loadCFG(argv[1], instruction_dictionary);
    std::cout << cfg_0->num_nodes << std::endl;
    stats[0] = cfg_0->num_nodes;
    std::cout << cfg_0->getNumEdges() << std::endl;

    stats[1] = cfg_0->getNumEdges();
    cfg_0->floyd_warshall();
    std::cout << cfg_0->getNumEdges() << std::endl;

    stats[2] = cfg_0->getNumEdges();
  }

  {
    cfg_1 = loadCFG(argv[2], instruction_dictionary);
    stats[3] = cfg_1->num_nodes;
    std::cout << cfg_1->num_nodes << std::endl;

    stats[4] = cfg_1->getNumEdges();
    std::cout << cfg_1->getNumEdges() << std::endl;

    cfg_1->floyd_warshall();
    std::cout << cfg_1->getNumEdges() << std::endl;

    stats[5] = cfg_1->getNumEdges();
  }

  for (size_t i = 0; i < 6; i++)
    std::cout << stats[i] << ",";

  my_timer_start(timer);
  float spgk = SPGK(cfg_0, cfg_1);
  my_timer_stop(timer);
  my_timer_delta(timer);

  std::cout << spgk << ",";

  std::cout << timer->delta << std::endl;

  return 0;
}
