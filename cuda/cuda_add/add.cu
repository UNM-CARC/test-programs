#include <iostream>
#include <math.h>
#include <cuda.h>

// CUDA Kernel function to add the elements of two arrays on the GPU
__global__
void add(int n, float *x, float *y)
{
  for (int i = 0; i < n; i++)
    y[i] = x[i] + y[i];
}


// CPU version is the same - function to add the elements of two arrays
//void add(int n, float *x, float *y)
//{
//  for (int i = 0; i < n; i++)
//    y[i] = x[i] + y[i];
//}

int main(void)
{
  int N = 1<<20; // 1M elements

  // Allocate Unified Memory -- accessible from CPU or GPU
  float *x, *y;
  cudaMallocManaged(&x, N*sizeof(float));
  cudaMallocManaged(&y, N*sizeof(float));


  // Previous CPU Code
  //float *x = new float[N];
  //float *y = new float[N];

  // initialize x and y arrays on the host
  for (int i = 0; i < N; i++) {
    x[i] = 1.0f;
    y[i] = 2.0f;
  }

  // Run kernel on 1M elements on the GPU
  add<<<1, 1>>>(N, x, y);

  // Previous CPU code - Run kernel on 1M elements on the CPU
  //add(N, x, y);

  // Check for errors (all values should be 3.0f)
  float maxError = 0.0f;
  for (int i = 0; i < N; i++)
    maxError = fmax(maxError, fabs(y[i]-3.0f));
  std::cout << "Max error: " << maxError << std::endl;

  // Free memory
  cudaFree(x);
  cudaFree(y);

  // Previous CPU Free memory
  // delete [] x;
  // delete [] y;

  return 0;
}
