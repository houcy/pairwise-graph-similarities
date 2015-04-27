
#ifndef __GRAPH_LOADER_HPP__
#define __GRAPH_LOADER_HPP__

#include <vector>
#include <map>
#include <string>

#include <cstddef>

struct spgk_input_t;

spgk_input_t * loadCFG(const std::string & cfg_file, const std::map<std::string, size_t> & instruction_dictionary);

void loadCG(const std::string & cg_file, std::vector<std::string> & labels);

#endif /* __GRAPH_LOADER_HPP__ */

