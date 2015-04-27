
#include "graph-loader.hpp"
#include "spgk.hpp"
#include "jsonxx.hpp"

// [Phase 0] Read JSON of CFG and return an input formated for the Shortest Path Graph Kernel
//           Need to transforme the sequence of instruction into an array => requires dictionary of the instructions in all CFG of both CG !!!!
spgk_input_t * loadCFG(const std::string & cfg_file, const std::map<std::string, size_t> & instruction_dictionary) {
  // TODO Replace dummy code
  spgk_input_t * res = new spgk_input_t(10, instruction_dictionary.size());
  return res;
}

// [Phase 0] Read JSON representation of CG and fill the list of node (label of the CFG blocks)
void loadCG(const std::string & cg_file, std::vector<std::string> & labels) {
  // TODO Replace dummy code
  labels.push_back("l1");
  labels.push_back("l2");
  labels.push_back("l3");
}

