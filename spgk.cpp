
#include "spgk.hpp"
#include "vector-kernels.hpp"

#include <limits>
#include <iomanip>
#include <fstream>

#include <cmath>
#include <cstdlib>

#include <cassert>

void spgk_input_t::floyd_warshall() {
  if (!shorted) {
    // [Phase 2.b] Parallelize using intranode parallelism: OpenMP, OpenACC, CUDA, OpenCL, ....
    for (size_t k = 0; k < num_nodes; k++)
      for (size_t i = 0; i < num_nodes; i++)
        for (size_t j = 0; j < num_nodes; j++)
          if (adjacency[i][j] > adjacency[i][k] + adjacency[k][j])
            adjacency[i][j] = adjacency[i][k] + adjacency[k][j];

    shorted = true;
  }
}

// Naive implementation of the Shortest Path Graph Kernel
float SPGK(spgk_input_t * in_1, spgk_input_t * in_2, const float edge_kernel_param) {
  assert(in_1->features_size == in_2->features_size);
  const size_t features_size = in_1->features_size;

  in_1->floyd_warshall();
  in_2->floyd_warshall();

  float res = 0;
  size_t i_1, j_1, i_2, j_2;

  // [Phase 2.a] Parallelize using intranode parallelism: OpenMP, OpenACC, CUDA, OpenCL, ....
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

//        std::cout << i_1 << " -> " << j_1 << " & " << i_2 << " -> " << j_2 << " = "
//                  << similarity_source << " * " << similarity_edge << " * " << similarity_sink << " = "
//                  << similarity_source * similarity_edge * similarity_sink << std::endl;
        }
      }
    }
  }

  return res;
}

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

void spgk_input_t::randomize(size_t prob_edges_over_1000) {
  for (size_t i = 0; i < num_nodes; i++) {
    for (size_t j = 0; j < features_size; j++)
      features[i][j] = (rand() % 101) - 50;
    for (size_t j = 0; j < num_nodes; j++)
      if (i == j)
        adjacency[i][j] = 0;
      else if (rand() % 1000 < prob_edges_over_1000)
        adjacency[i][j] = 1;
      else
        adjacency[i][j] = std::numeric_limits<float>::infinity();
  }
}

void spgk_input_t::print(std::ostream & out) {
  print_features(out);
  print_adjacency(out);
}

void spgk_input_t::print_features(std::ostream & out) {
  for (size_t i = 0; i < num_nodes; i++) {
    out << "features[" << std::setw(2) << i << "] : ";
    for (size_t j = 0; j < features_size; j++)
      out << "|" << std::setw(3) << features[i][j];
    out << "|" << std::endl;
  }
}

void spgk_input_t::print_adjacency(std::ostream & out) {
  for (size_t i = 0; i < num_nodes; i++) {
    out << "adjacency[" << std::setw(2) << i << "] : ";
    for (size_t j = 0; j < num_nodes; j++)
      std::cout << "|" << std::setw(3) << adjacency[i][j];
    out << "|" << std::endl; 
  }
}

void spgk_input_t::toDot(char * file) {
  std::ofstream out;
  out.open(file);
  toDot(out);
  out.close();
}

void spgk_input_t::toDot(std::ostream & out) {
  out << "digraph g {" << std::endl;
  for (size_t i = 0; i < num_nodes; i++)
    for (size_t j = 0; j < num_nodes; j++)
      if (adjacency[i][j] != 0 && adjacency[i][j] != std::numeric_limits<float>::infinity())
        out << "  " << i << " -> " << j << " [label=\"" << adjacency[i][j] << "\"];" << std::endl;
  out << "}" << std::endl; 
}

