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
  spgk_input_t * cfg;

  cfg = loadCFG(argv[1], instruction_dictionary);
  std::cout << "CFG::Stats[0]= ";
  cfg->getStats(std::cout);
  std::cout << std::endl;

  my_timer_start(timer);
  cfg->floyd_warshall();
  my_timer_stop(timer);
  my_timer_delta(timer);

  std::cout << "CFG::Stats[1]= ";
  cfg_1->getStats(std::cout);
  std::cout << std::endl;
  std::cout << "CFG::floyd_warshall() " << timer->delta << std::endl;

  return 0;
}
