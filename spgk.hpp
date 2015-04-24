
// Input for the Shortest Path Graph Kernel 
struct spgk_input_t {
  size_t num_nodes;
  size_t data_size
  float ** node_data;
  int ** adjacency;

  spgk_input_t(size_t num_nodes, size_t data_size);
  ~spgk_input_t();
};

// Shortest Path Graph Kernel: sequential version of this code will be provided
float SPGK(spgk_input_t * in_1, spgk_input_t * in_2);

