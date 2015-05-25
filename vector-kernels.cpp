
#include "vector-kernels.hpp"
#include <omp.h>

#include <cmath>

float gaussian_kernel(float * n_1, float * n_2, size_t n, float param) {
  float res = 0;
  for (size_t i = 0; i < n; i++) {
    float diff = n_1[i] - n_2[i];
    res += (diff * diff);
  }
  return expf(-res/param);
}

float intersect_kernel(float * n_1, float * n_2, size_t n, float param) {
  float res = 0;
  for (size_t i = 0; i < n; i++)
    res += fmin(n_1[i], n_2[i]);
  return res;
}

