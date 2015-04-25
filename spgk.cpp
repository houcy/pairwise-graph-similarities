
#include "spgk.hpp"
#include "vector-kernels.hpp"

#include <limits>

#include <cmath>

#include <cassert>

spgk_input_t::spgk_input_t(size_t num_nodes_, size_t features_size_) :
  num_nodes(num_nodes_),
  features_size(features_size_),
  features(NULL),
  adjacency(NULL),
  shorted(false)
{
  features = new float*[num_nodes];
  adjacency = new float*[num_nodes];
  float * features_data  = new float[num_nodes * features_size];
  float * adjacency_data = new float[num_nodes * num_nodes];
  for (size_t i = 0; i < num_nodes; i++) {
    features[i] = &(features_data[i * features_size]);
    adjacency[i] = &(adjacency_data[i * num_nodes]);
  }
}

spgk_input_t::~spgk_input_t() {
  delete [] features[0];
  delete [] features;
  delete [] adjacency[0];
  delete [] adjacency;
}

void spgk_input_t::floyd_warshall() {
  if (!shorted) {
    // TODO Floyd-Warshall

    shorted = true;
  }
}

void spgk_input_t::randomize() {
  // TODO
}

void spgk_input_t::print(std::ostream & out) {
  // TODO
}

// Naive implementation of the Shortest Path Graph Kernel
float SPGK(spgk_input_t * in_1, spgk_input_t * in_2, const float edge_kernel_param) {
  assert(in_1->features_size == in_2->features_size);
  const size_t features_size = in_1->features_size;

  in_1->floyd_warshall();
  in_2->floyd_warshall();

  float res = 0;
  size_t i_1, j_1, i_2, j_2;

  for (i_1 = 0; i_1 < in_1->num_nodes; i_1++) {
    for (j_1 = 0; j_1 < in_1->num_nodes; j_1++) {

      if ((i_1 == j_1) || (in_1->adjacency[i_1][j_1] == std::numeric_limits<float>::infinity())) continue;

      for (i_2 = 0; i_2 < in_2->num_nodes; i_2++) {
        for (j_2 = 0; j_2 < in_2->num_nodes; j_2++) {

          if ((i_2 == j_2) || (in_2->adjacency[i_2][j_2] == std::numeric_limits<float>::infinity())) continue;

          float similarity_edge = fmax(0.0, edge_kernel_param - fabs(in_1->adjacency[i_1][j_1] - in_2->adjacency[i_2][j_2]));

          if (similarity_edge == 0) continue;

          float similarity_source = SPKG_VECTOR_KERNEL(in_1->features[i_1], in_2->features[i_2], features_size);
          float similarity_sink   = SPKG_VECTOR_KERNEL(in_1->features[j_1], in_2->features[j_2], features_size);
          res += similarity_source * similarity_edge * similarity_sink;
        }
      }
    }
  }

  return res;
}

