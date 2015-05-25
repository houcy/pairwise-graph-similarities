#include <omp.h>
#include "pairwise-similarity.hpp"
#include "graph-loader.hpp"
#include "spgk.hpp"

#include <cassert>
#include <fstream>

/// [Phase 3] Distribute using MPI, load balance distributed computations
void SimilarityMatrix::evaluate() {
  for (int i = 0; i < labels_1.size(); i++) {
    #pragma omp parallel for schedule(dynamic)
    for (int j = 0; j < labels_2.size(); j++) {
      std::cout << "Pair "<< i<<"-" << j << " is being computed on Thread "<<omp_get_thread_num() <<std::endl;
      similarity_matrix[i][j] = SPGK(getCFG(cg_1, labels_1[i]), getCFG(cg_2, labels_2[j]));
    }
  }
}

void SimilarityMatrix::loadFeatureNames(const std::string & feature_name_file) {
  // TODO Replace dummy code. Read file: one instruction name per line and store in feature_dictionary
  std::string line;
  std::ifstream file;
  size_t cnt = 0;
  file.open(feature_name_file.c_str());
  while(!file.eof()) {
    std::getline(file, line);
    feature_dictionary.insert(std::pair<std::string, size_t>(line, cnt++));
  }
  file.close();
}

void SimilarityMatrix::dump(std::ostream & out) const {
  // TODO
}

void SimilarityMatrix::printHTML(std::ostream & out) const {
  // TODO
}

size_t SimilarityMatrix::getFeatureIdx(const std::string & feature_name) const {
  std::map<std::string, size_t>::const_iterator it = feature_dictionary.find(feature_name);
  assert(it != feature_dictionary.end());
  return it->second;
}

size_t SimilarityMatrix::getIndex_1(const std::string & lbl) const {
  std::map<std::string, size_t>::const_iterator it = map_lbl_1.find(lbl);
  assert(it != map_lbl_1.end());
  return it->second;
}

void SimilarityMatrix::sort_1() {
  for (size_t i = 0; i < labels_1.size(); i++)
    map_lbl_1.insert(std::pair<std::string, size_t>(labels_1[i], i));
}

size_t SimilarityMatrix::getIndex_2(const std::string & lbl) const {
  std::map<std::string, size_t>::const_iterator it = map_lbl_2.find(lbl);
  assert(it != map_lbl_2.end());
  return it->second;
}

void SimilarityMatrix::sort_2() {
  for (size_t i = 0; i < labels_1.size(); i++)
    map_lbl_1.insert(std::pair<std::string, size_t>(labels_1[i], i));
}

spgk_input_t * SimilarityMatrix::getCFG(const std::string & cg, const std::string & routine) {
  std::string tag = cg + "-" + routine;
  std::map<std::string, spgk_input_t *>::iterator it = routines_map.find(tag);
  if (it == routines_map.end()) {
    spgk_input_t * graph = loadCFG(path + "/" + cg +  + "/" + tag + ".json", feature_dictionary);
    it = routines_map.insert(std::pair<std::string, spgk_input_t *>(tag, graph)).first;
  }
  return it->second;
}

void SimilarityMatrix::freeCFG(const std::string & cg, const std::string & routine) {
  std::string tag = cg + "-" + routine;
  std::map<std::string, spgk_input_t *>::iterator it = routines_map.find(tag);
  if (it != routines_map.end()) {
    delete it->second;
    routines_map.erase(it);
  }
}

SimilarityMatrix::SimilarityMatrix(const std::string & cg_1_, const std::string & cg_2_, const std::string & feature_file, const std::string & path_) :
  path(path_),
  cg_1(cg_1_), labels_1(),
  cg_2(cg_2_), labels_2(),
  similarity_matrix(NULL),
  map_lbl_1(), map_lbl_2(),
  feature_dictionary(),
  routines_map()
{
  loadCG(path + "/" + cg_1 +  + "/" + cg_1 + "-no-block.json", labels_1);
  sort_1();

  loadCG(path + "/" + cg_2 +  + "/" + cg_2 + "-no-block.json", labels_2);
  sort_2();

  loadFeatureNames(feature_file);

  float * data = new float[labels_1.size() * labels_2.size()]();
  similarity_matrix = new float*[labels_1.size()]();


  for (size_t i = 0; i < labels_1.size(); i++)
    similarity_matrix[i] = &(data[i * labels_2.size()]);
}

SimilarityMatrix::~SimilarityMatrix() {
  std::map<std::string, spgk_input_t *>::iterator it_rtn;
  for (it_rtn = routines_map.begin(); it_rtn != routines_map.end(); it_rtn++)
    delete it_rtn->second;

  if (similarity_matrix != NULL) {
    delete [] similarity_matrix[0];
    delete [] similarity_matrix;
  }
}

const std::vector<std::string> & SimilarityMatrix::getLabelsCG_1() const { return labels_1; }
const std::vector<std::string> & SimilarityMatrix::getLabelsCG_2() const { return labels_2; }
float ** const SimilarityMatrix::getSimilarities() const { return similarity_matrix; }
const float SimilarityMatrix::getSimilarity(const std::string & label_1, const std::string & label_2) const { return similarity_matrix[getIndex_1(label_1)][getIndex_2(label_2)]; }
