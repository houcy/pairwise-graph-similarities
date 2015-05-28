#include "spgk.hpp"
#include "graph-loader.hpp"
#include "timer.h"
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
  spgk_input_t * cfg1;
  spgk_input_t * cfg2;

  cfg1 = loadCFG(argv[1], instruction_dictionary);
  cfg2 = loadCFG(argv[2], instruction_dictionary);

  my_timer_start(timer);
  float spgk = SPGK(cfg1,cfg2);
  my_timer_stop(timer);
  my_timer_delta(timer);

  std::cout << timer->delta << " ";

  return 0;
}
