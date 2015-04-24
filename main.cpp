
#include "spgk.hpp"
#include "jsonxx.hpp"

spgk_input_t * loadCFG(const std::string & path, const std::string & cfg) {
  // TODO Read JSON of CFG and return an input formated for the Shortest Path Graph Kernel
  return NULL;
}

void getNodesCG(const std::string & path, const std::string & cg, std::vector<std::string> & node_cg) {
  // TODO Read JSON representation of CG and fill the list of node (label of the CFG blocks)
}

float similarity(const std::string & path, const std::string & cfg_1_, const std::string & cfg_2_) {
  spgk_input_t * cfg_1 = loadCFG(path, cfg_1_);
  spgk_input_t * cfg_2 = loadCFG(path, cfg_2_);
  return SPGK(cfg_1, cfg_2);
}

struct similarity_matrix_t {
  std::vector<std::string> labels_1;
  std::vector<std::string> labels_2;
  float ** similarities;

  similarity_matrix_t(const std::string & path, const std::string & cg_1, const std::string & cg_2) :
    labels_1(), labels_2(), results(NULL)
  {
    getNodesCG(path, cg_1, labels_1);
    getNodesCG(path, cg_2, labels_2);

    float * data = new float[labels_1.size() * labels_2.size()];
    similarities = new (float*)[labels_1.size()];
    for (i = 0; i < labels_1.size(); i++)
      similarities[i] = &(data[i * labels_2.size()]);
  }
};

similarity_matrix_t * compare_CG(const std::string & path, const std::string & cg_1, const std::string & cg_2) {
  similarity_matrix_t * res = new similarity_matrix_t(path, cg_1, cg_2);

  // TODO Distribute using MPI  
  for (int i = 0; i < res->labels_1.size(); i++) {
    for (int j = 0; j < res->labels_2.size(); j++) {
      res->results[i][j] = similarity(path, labels_1[i], labels_2[j]);
    }
  }

  return res;
}

int main(int argc, char ** argv) {

  // TODO

  return 0;
}


