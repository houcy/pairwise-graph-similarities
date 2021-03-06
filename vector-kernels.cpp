#include <iostream>
#include "vector-kernels.hpp"
#include <omp.h>

#include <cmath>

#if !defined(GAUSSIAN_EXP)
float gaussian_kernel(float * n_1, float * n_2, size_t n, float param) {
  float res = 0;
  for (size_t i = 0; i < n; i++) {
    float diff = n_1[i] - n_2[i];
    res += (diff * diff);
  }
  return expf(-res/param);
}
#elif GAUSSIAN_EXP==0
float gaussian_kernel(float * n_1, float * n_2, size_t n, float param) {
  float res = 0;
  for (size_t i = 0; i < n; i++) {
    float g1 = n_1[i];
    float g2 = n_2[i];
    if((g1==0) && (g2==0)){
       // std::cout << g1 << " " <<g2 << std::endl;
        continue;
    }
    //std::cout << g1 << " " <<g2 << std::endl;
     float diff = g1 - g2;
     res += (diff * diff);
  }
  return expf(-res/param);
}
#else
#error "not a gaussian version"
#endif

float intersect_kernel(float * n_1, float * n_2, size_t n, float param) {
  float res = 0;
  for (size_t i = 0; i < n; i++)
    res += fmin(n_1[i], n_2[i]);
  return res;
}

