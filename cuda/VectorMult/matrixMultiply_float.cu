#include <cstdlib>
#include <cassert>
#include <iostream>
#include <chrono>

using namespace std;

__global__ void matrixMul(const float *a, const float *b, float *c, int N) {
  // Compute each thread's global row and column index
  int row = blockIdx.y * blockDim.y + threadIdx.y;
  int col = blockIdx.x * blockDim.x + threadIdx.x;

  // Iterate over row, and down column
  c[row * N + col] = 0;
  for (int k = 0; k < N; k++) {
    // Accumulate results for a single element
    c[row * N + col] += a[row * N + k] * b[k * N + col];
  }
}

void verify_result(float *a, float *b, float *c, int N){
  float temp;
  for(int i=0; i<N; i++){
    for(int j=0; j<N; j++){
      temp = 0;
      for(int k=0; k<N; k++){
        temp += a[i * N + k] * b[k * N + j];
      }
      assert(temp == c[i * N + j]);
    }
  }
}

//Initialize a square matrix
void init_matrix(float *m, int N){
  for(int i=0; i<N; i++){
    m[i] = rand() % 100 + 0.234;
  }
}

int main(){
  //Set square matrix dimension
  int N = 1 << 10; //1024
  size_t bytes = N * N * sizeof(float); //Declare size of matrix

  //Allocate memory for matrices
  float *a, *b, *c;
  cudaMallocManaged(&a, bytes);
  cudaMallocManaged(&b, bytes);
  cudaMallocManaged(&c, bytes);

  // Initialize matrix
  init_matrix(a, N);
  init_matrix(b, N);

  //Set CTA and Grid dimensions
  int threads = 32; //Will be squared -> 256
  int blocks = (N + threads - 1)/threads;

  //Kernel launch parameters
  dim3 THREADS(threads, threads);
  dim3 BLOCKS(blocks, blocks);

  //Launch Kernel
  std::chrono::steady_clock::time_point begin = std::chrono::steady_clock::now();
  matrixMul<<<BLOCKS, THREADS>>>(a, b, c, N);
  cudaDeviceSynchronize();
  std::chrono::steady_clock::time_point end = std::chrono::steady_clock::now();
  std::cout << "GPU time = " << std::chrono::duration_cast<std::chrono::milliseconds>(end - begin).count() << " milliseconds" << std::endl;
  //Verify results
  begin = std::chrono::steady_clock::now();
  verify_result(a, b, c, N);
  end = std::chrono::steady_clock::now();
  std::cout << "CPU time = " << std::chrono::duration_cast<std::chrono::milliseconds>(end - begin).count() << " milliseconds" << std::endl;
  cout << "SUCCESSFUL" << endl;
  return 0;
}