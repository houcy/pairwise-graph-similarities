
#ifndef __VECTOR_KERNELS_HPP__
#define __VECTOR_KERNELS_HPP__

#include <cstddef>

float  gaussian_kernel(float * n_1, float * n_2, size_t n, float param = 10000);
float intersect_kernel(float * n_1, float * n_2, size_t n, float param = 0);

#endif /* __VECTOR_KERNELS_HPP__ */

