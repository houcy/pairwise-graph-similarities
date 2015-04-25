
#include "spgk.hpp"
#include "vector-kernels.hpp"

#include <cassert>

spgk_input_t::spgk_input_t(size_t num_nodes_, size_t data_size_) :
  num_nodes(num_nodes_),
  data_size(data_size_),
  features(NULL),
  adjacency(NULL),
  shorted(false)
{
  // TODO alloc
}

spgk_input_t::~spgk_input_t() {
  // TODO free
}

void spgk_input_t::floyd_warshall() {
  if (!shorted) {
    // TODO Floyd-Warshall

    shorted = true;
  }
}

// Naive implementation of the Shortest Path Graph Kernel
template <float (*vector_kernel)(float * n_1, float * n_2, size_t n), const float edge_kernel_param = 3.0>
float SPGK(spgk_input_t * in_1, spgk_input_t * in_2) {
  assert(in_1->features_size == in_2->features_size);
  const size_t features_size = in_1->features_size;

  apply_shortest_path(in_1);
  apply_shortest_path(in_2);

  float res = 0;

  for (i_1 = 0; i_1 < in_1->num_nodes; i_1++) {
    for (j_1 = 0; j_1 < in_1->num_nodes; j_1++) {
      if ((i_1 == j_1) || (in_1->adjacency[i_1][j_1] != std::numeric_limits<float>::infinity())) continue;
      for (i_2 = 0; i_2 < in_2->num_nodes; i_2++) {
        for (j_2 = 0; j_2 < in_2->num_nodes; j_2++) {
          if ((i_2 == j_2) || (in_2->adjacency[i_2][j_2] != std::numeric_limits<float>::infinity())) continue;

          float similarity_edge = fmax(0.0, edge_kernel_param - fabs(in_1->adjacency[i_1][j_1] - in_2->adjacency[i_2][j_2]));
          if (similarity_edge != 0) {
            float similarity_source = vector_kernel(in_1->features[i_1], in_2->features[i_2], features_size);
            float similarity_sink   = vector_kernel(in_1->features[j_1], in_2->features[j_2], features_size);
            res += similarity_source * similarity_edge * similarity_sink;
          }
        }
      }
    }
  }

  return res;
}

