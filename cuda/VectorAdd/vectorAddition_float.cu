#include <cstdlib>
#include <cassert>
#include <iostream>
#include <chrono>

using namespace std;

__global__ void vectorAdd(float *a, float *b, float *c, int N){
    //Calculate thread ID
    int tid = blockIdx.x * blockDim.x + threadIdx.x;

    //Range check
    if(tid < N) c[tid] = a[tid] + b[tid];

}

void init_array(float *a, int N){
    for(int i=0; i<N; i++){
        a[i] = rand() % 100 + 0.234;
    }
}

void verifyArray(float *a, float *b, float *c, float N){
    for(int i=0; i<N; i++){
        assert(a[i] + b[i] == c[i]);
    }
}

int main(){
    int N = 1 << 25;
    size_t bytes = N * sizeof(bytes);

    float *a, *b, *c;

    //Allocate memory for arrays
    cudaMallocManaged(&a, bytes);
    cudaMallocManaged(&b, bytes);
    cudaMallocManaged(&c, bytes);

    //Initialize Data
    init_array(a, N);
    init_array(b, N);

    //CTA and Grid dimensions
    int THREADS = 1024;
    int BLOCKS = (int) (N + THREADS - 1)/THREADS;

    //Call Kernel
    std::chrono::steady_clock::time_point begin, end;
    begin = std::chrono::steady_clock::now();
    vectorAdd<<<BLOCKS, THREADS>>>(a, b, c, N);
    cudaDeviceSynchronize();
    end = std::chrono::steady_clock::now();
    std::cout << "GPU time = " << std::chrono::duration_cast<std::chrono::milliseconds>(end - begin).count() << " milliseconds" << std::endl;
    //Verify solution
    begin = std::chrono::steady_clock::now();
    verifyArray(a, b, c, N);
    end = std::chrono::steady_clock::now();
    std::cout << "CPU time = " << std::chrono::duration_cast<std::chrono::milliseconds>(end - begin).count() << " milliseconds" << std::endl;
    cout << "SUCCESSFUL" << endl;    

    return 0;
}