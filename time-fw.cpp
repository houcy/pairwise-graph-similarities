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

  my_timer_start(timer);
  cfg->floyd_warshall();
  std::ofstream hashfile ("hashed.txt", std::ofstream::out | std::ios::app);
  cfg->hashAdj(hashfile);
  my_timer_stop(timer);
  my_timer_delta(timer);

  std::cout << timer->delta << " ";

  return 0;
}
