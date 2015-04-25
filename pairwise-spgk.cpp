
#include "spgk.hpp"
#include "jsonxx.hpp"

spgk_input_t * loadCFG(const std::string & path, const std::string & cfg, const std::map<std::string, size_t> & instruction_dictionary) {
  // [Phase 1] Read JSON of CFG and return an input formated for the Shortest Path Graph Kernel
  //           Need to transforme the sequence of instruction into an array => requires dictionary of the instructions in all CFG of both CG !!!!
  return NULL;
}

void getNodesCG(const std::string & path, const std::string & cg, std::vector<std::string> & node_cg) {
  // [Phase 1] Read JSON representation of CG and fill the list of node (label of the CFG blocks)
}

float similarity(const std::string & path, const std::string & cfg_1_, const std::string & cfg_2_, const std::map<std::string, size_t> & instruction_dictionary) {
  spgk_input_t * cfg_1 = loadCFG(path, cfg_1_, instruction_dictionary);
  spgk_input_t * cfg_2 = loadCFG(path, cfg_2_, instruction_dictionary);
  return SPGK(cfg_1, cfg_2);
}

struct similarity_matrix_t {
  std::vector<std::string> labels_1;
  std::vector<std::string> labels_2;
  float ** similarities;

  similarity_matrix_t(const std::string & path, const std::string & cg_1, const std::string & cg_2) :
    labels_1(), labels_2(), similarities(NULL)
  {
    getNodesCG(path, cg_1, labels_1);
    getNodesCG(path, cg_2, labels_2);

    float * data = new float[labels_1.size() * labels_2.size()];
    similarities = new float*[labels_1.size()];
    for (size_t i = 0; i < labels_1.size(); i++)
      similarities[i] = &(data[i * labels_2.size()]);
  }

  ~similarity_matrix_t() {
    delete [] similarities[0];
    delete [] similarities;
  }
};

similarity_matrix_t * compare_CG(const std::string & path, const std::string & cg_1, const std::string & cg_2) {
  similarity_matrix_t * res = new similarity_matrix_t(path, cg_1, cg_2);

  // [Phase 2] Distribute using MPI
  // [Phase 3.a] Load balance distributed computations
  for (int i = 0; i < res->labels_1.size(); i++) {
    for (int j = 0; j < res->labels_2.size(); j++) {
      std::map<std::string, size_t> instruction_dictionary; // TODO Fill it!!! (Start with a global dictionnary containing all 745 instructions)
      res->similarities[i][j] = similarity(path, res->labels_1[i], res->labels_2[j], instruction_dictionary);
    }
  }

  return res;
}

int main(int argc, char ** argv) {

  // TODO

  return 0;
}


