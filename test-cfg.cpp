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

  {
    cfg_0 = loadCFG(argv[1], instruction_dictionary);
    std::cout << "CFG[0]::Stats[0] = ";
    cfg_0->getStats(std::cout);
    std::cout <<  std::endl;

    my_timer_start(timer);
    cfg_0->floyd_warshall();
    my_timer_stop(timer);
    my_timer_delta(timer);

    std::cout << "CFG[0]::floyd_warshall() (in " << timer->delta << "ms)" << std::endl;
    std::cout << "CFG[0]::Stats[1] = ";
    cfg_0->getStats(std::cout);
    std::cout << std::endl;
  }

  {
    cfg_1 = loadCFG(argv[2], instruction_dictionary);
    std::cout << "CFG[1]::Stats[0] = ";
    cfg_1->getStats(std::cout);
    std::cout << std::endl;

    my_timer_start(timer);
    cfg_1->floyd_warshall();
    my_timer_stop(timer);
    my_timer_delta(timer);

    std::cout << "CFG[1]::floyd_warshall() (in " << timer->delta << "ms)" << std::endl;
    std::cout << "CFG[1]::Stats[1] = ";
    cfg_1->getStats(std::cout);
    std::cout << std::endl;
  }

  my_timer_start(timer);
  float spgk = SPGK(cfg_0, cfg_1);
  my_timer_stop(timer);
  my_timer_delta(timer);

  std::cout << "SPGK(CFG[0], CFG[1]) = " << spgk << " (in " << timer->delta << "ms)" << std::endl;

  return 0;
}
