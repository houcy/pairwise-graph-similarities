Pairwise Graph Similarities using Shortest Path Graph Kernel
=============================================================

In this project, we want to compare the node of two nested graphs.
These graphs are Call Graph (CG): Vertices are Routines and Edges represent calls from one Routine to another.
In these CG, the Routines are Control Flow Graph: Vertices are (unbreakable) sequences of instructions (called blocks)
and the Edges represents the flow from on block to another (including jump instructions).
Given two CGs, we want to compare the Routines that composed ldtuihem.
The goal is to find the most similar routines between two CG.

The Shortest Path Graph Kernel (SPGK) is an algorithm used to measure similarities between graphs.
Given two graphs, SPGK returns a positive real number measuring the "distance" between two graphs.
The smallest the results of SPGK, the most similar are the graphs.
SPGK has two phases: (1) it computes all the shortest paths in both graph (we use Floyd-Warshall Algorithm)
and (2) it compares these shortest paths pairwise and sums the results.

## Provided Codes

We provide a sequential (naive) implementation of SPGK and the skeleton of the pairwise comparaison.
 - vector-kernels.hpp and vector-kernels.cpp contain kernels used to measure the similarities between vectors
 - spkg.hpp and spkg.cpp contain the naive implementation of Shortest Path Graph Kernel
 - test-spgk.cpp builds two random graphs and applies SPGK on them.
 - pairwise-spgk.cpp is a skeletons of the application that will load two CGs and compares their CFGs pairwise
 - jsonxx.hpp and jsonxx.cpp are a library to read/write JSON representations. See [https://github.com/hjiang/jsonxx](https://github.com/hjiang/jsonxx).

## The phases of the project

This project will have four steps:
 * (0) Building the inputs for SPGK from the JSON representation of the CG
 * (1) Evaluate the performance of SPGK on these graphs
 * (2) Optimizing the implementation of SPGK and Parallelizing it using intranode techniques (OpenMP, OpenCL, CUDA, OpenACC)
 * (3) Distribute the pairwise comparaisons on a cluster using MPI, including load-balancing and fine management of I/O and communications 

### Phase 0 : Applying SPGK to CFGs

In this preliminary phase, you will become familiar with the data-structures we are using for the CG/CFG (JSON format).
The general layout of the code is provided.
You need to implement the functions reading the JSON files to produce SPGK's data-structures.

### Phase 1 : Performance Evaluation

This first phase will get you acquainted with the performances of SPGK on the data you are provided.
First, you will characterize the dataset (number of Vertices and Edges).
Then you will evaluate both Floyd-Warshall and Similarity Computation depending on the characteristics of the graphs.

This work will be useful for the second phase. However it will be essential for the third phase (load-balancing and I/O management)

### Phase 2 : SPGK Optimization

This second phase looks at improving the performance of the comparaison of two CFGs.
You will use your choice of intranode parallelization techniques to improve the performaces of this code.
Depending on your choice of target (CPU, GPU, ...), you will have to change the layout of the data-structures.

There is two parts to this phase:
 - (1) optimizing Floyd-Warshall (might want to try other algorithm too)
 - (2) optimizing the Similarity Computation

### Phase 3 : Distributing Workload

Finally, once SPGK is optimized for intranode performances, you will have to distribute the computation in a cluster using MPI.
Given two CGs, many pair of CFG have to be compared.
Distributing these computations accross a cluster will pose interresting challenges:
 - size of the CFGs vary wildly: load-balancing
 - CFGs are stored in separated files:
   - Do you load the files in the master process then send the data? OR load them in the worker?
 - comparing that many CFGs might require to unload/reload them as memory get filled....

## More on the SPGK Test

The file test-spgk.cpp builds two graphs of 1000 nodes where each node contain a vector of length 50.
The graph are random: there is a probability of 0.02 to have an edge between two nodes.
The vectors for each nodes are filled with random values between -50 and 50.
Both graphs (without node content) are saved in GraphViz format before and after applying the Shortest Path Algorithm (Floyd-Warshall).

To test:
```bash
make check
```
Or:
```bash
make
./test-spkg
```
To render the graphs (graph 1 and 2, before and after applying Shortest Path):
```bash
for f in 1_before 1_after 2_before 2_after; do dot -Tsvg in_$f.dot -o in_$f.svg; done
```

