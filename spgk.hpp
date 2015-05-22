
#ifndef __SPKG_HPP__
#define __SPKG_HPP__

#ifndef SPKG_VECTOR_KERNEL
#  define SPKG_VECTOR_KERNEL gaussian_kernel
#endif

#include <iostream>
#include <cstddef>

// Input for the Shortest Path Graph Kernel 
struct spgk_input_t {
  size_t num_nodes;     /// Number of nodes in the graph
  size_t features_size; /// Size of the feature vectors in this graph

  float ** features;    /// Feature vectors for each node (num_nodes x features_size)
  float ** adjacency;   /// Adjacency matrix of the graph (num_nodes x num_nodes).
                        /// Initialized for Floyd-Warshall Algorithm:
                        ///   Given i and j the indexes of two nodes:
                        ///     adjacency[i][j] =
                        ///       |  INFINITY        if there is no edges between Node[i] and Node[j]
                        ///       |  0               if i == j
                        ///       |  distance(i,j)   else
                        ///   Where:
                        ///      - distance(i,j) is the distance between Node[i] and Node[j] (or the weigth of the edge, or 1 if edges are not labeled)

  bool shorted;         /// True if Floyd-Warshall Algorithm has been applied

  spgk_input_t(size_t num_nodes_, size_t features_size_);
  ~spgk_input_t();

  void floyd_warshall();

  void randomize(size_t prob_edges_over_1000);

  void print(std::ostream & out);
  void print_features(std::ostream & out);
  void print_adjacency(std::ostream & out);

  void toDot(char * file);
  void toDot(std::ostream & out);
  void getStats(std::ostream & out);
  size_t getNumEdges();
};

// Shortest Path Graph Kernel: sequential version of this code will be provided
float SPGK(spgk_input_t * in_1, spgk_input_t * in_2, const float edge_kernel_param = 3.0);

#endif /* __SPKG_HPP__ */

