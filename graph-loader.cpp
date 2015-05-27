
#include "graph-loader.hpp"
#include "spgk.hpp"
#include "jsonxx.hpp"
#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <limits>
#include <algorithm>
using namespace jsonxx;

// [Phase 0] Read JSON of CFG and return an input formated for the Shortest Path Graph Kernel
//           Need to transforme the sequence of instruction into an array => requires dictionary of the instructions in all CFG of both CG !!!!
spgk_input_t * loadCFG(const std::string & cfg_file, const std::map<std::string, size_t> & instruction_dictionary) {
    //std::cout << "LOADING CFG " << cfg_file << std::endl;

    std::ifstream t(cfg_file.c_str());
    std::stringstream buffer;
    buffer << t.rdbuf();
    // std::cout << "BUFFER: " << buffer.str() << std::endl;

    Object o;
    o.parse(buffer.str());

    Array blocks = o.get<Array>("blocks");
    int numBlocks = blocks.size();
    int featureSize = instruction_dictionary.size();

    spgk_input_t * res = new spgk_input_t(numBlocks, featureSize);
    float ** features = new float*[numBlocks];
    float ** adjacency = new float*[numBlocks];
    std::map<std::string, int> blockMap;


    //populate features array
    for(size_t i = 0; i<numBlocks;i++)
    {
        features[i] = new float[featureSize]();
        Array instructs = blocks.get<Object>(i).get<Array>("instructions");
        std::string tag = blocks.get<Object>(i).get<String>("tag");
        blockMap[tag] = i;


        for(size_t j = 0; j<instructs.size();j++)
        {

            std::string instruct = instructs.get<Object>(j).get<String>("str");

            if(instruct.find(" ") == std::string::npos);
            else instruct = instruct.substr(0,instruct.find(" "));

            int featureIndex = instruction_dictionary.find(instruct)->second;
            features[i][featureIndex]++;
        }
        float inf = std::numeric_limits<float>::infinity();
        float * newFloatArray = new float[numBlocks];
        std::fill(newFloatArray, newFloatArray + numBlocks, inf);
        adjacency[i] = newFloatArray;


    }
    //populate adjacency matrix
    for(size_t n = 0; n < numBlocks; n++)
    {
      adjacency[n][n] = 0;
      std::string outTrue = blocks.get<Object>(n).get<String>("out_true");
      if(outTrue != ""){
        int m = blockMap[outTrue];
        adjacency[n][m] = 1;
      }
      std::string outFalse = blocks.get<Object>(n).get<String>("out_false");
      if(outFalse != ""){
        int m = blockMap[outFalse];
        adjacency[n][m] = 1;
      }
    }
    res->features = features;
    res->adjacency = adjacency;
  //  for(size_t i = 0;i < res->num_nodes;i++){
  //    std::cout << "features at i = " << i << std::endl;
  //      for(size_t j = 0;j< featureSize;j++){
  //        if (features[i][j] != 0){
  //        std::cout << features[i][j] << std::endl;
  //      }
  //    }
  //  }
  return res;
}

// [Phase 0] Read JSON representation of CG and fill the list of node (label of the CFG blocks)
void loadCG(const std::string & cg_file, std::vector<std::string> & labels) {
  // TODO Replace- dummy code
  //std::cout << "LOADING CG " << cg_file << std::endl;
  std::ifstream t(cg_file.c_str());
  // std::cout << "IFSTREAM " << std::endl;
  std::stringstream buffer;
  buffer << t.rdbuf();
  // std::cout << "BUFFER: " << buffer.str() << std::endl;

  Object o;
  o.parse(buffer.str());
  // std::cout << "PARSED JSON: " << o.json() << std::endl;

  Array routines = o.get<Array>("routines");
  int numRtns = routines.size();

  // std::cout << "GOT ROUTINES" << std::endl;

  for(size_t i = 0; i < numRtns; i++){

    std::string type = routines.get<Object>(i).get<String>("type");
    if(type != "library" && type != "indirect"){
      std::string label = routines.get<Object>(i).get<String>("label");
      // std::cout << label << std::endl;

      labels.push_back(label);
    }
  }
}
