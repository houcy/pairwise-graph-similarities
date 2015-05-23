
#include "pairwise-similarity.hpp"
#include "graph-loader.hpp"

#include <cassert>

int main(int argc, char ** argv) {
  assert(argc > 2);

  std::string cg_1 = argv[1];
  std::string cg_2 = argv[2];
  std::string path = argc > 3 ? argv[3] : ".";
  std::string feature_file = argc > 4 ? argv[4] : "./instructions.lst";

  SimilarityMatrix similarity_matrix(cg_1, cg_2, feature_file, path);

  similarity_matrix.evaluate();

  similarity_matrix.printHTML(std::cout);

  return 0;
}
