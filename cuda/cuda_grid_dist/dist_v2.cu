#include <math.h> //Include standard math library containing sqrt.
#include <chrono>
#include <iostream>
#include <stdio.h>
#include <sstream>
using namespace std::chrono;

// Convenience function to format human friendly elapsed time
#include <iomanip>
#include <optional>
#include <ostream>
using namespace std;

__device__ float scale(int i, int n)
{
	return ((float)i)/(n - 1);
}
__device__ float distance(float x1, float x2)
{
	return sqrt((x2 - x1)*(x2 - x1));
}
__global__ void distanceKernel(float *device_out, float ref, int len)
{
	const int i = blockIdx.x*blockDim.x + threadIdx.x;
	const float x = scale(i, len);
	device_out[i] = distance(x, ref);
	printf("i = %2d: dist from %f to %f is %f.\n", i, ref, x, device_out[i]);
}

int main(int argc, char* argv[])
{   
    int N = atoi(argv[1]);
    int	TPB = N;
    	const float ref = 0.5f;
	// Declare a pointer for an array of floats
	float *d_out = 0;
	// Allocate device memory to store the output array
	cudaMalloc(&d_out, N*sizeof(float));
	// Launch kernel to compute and store distance values
	distanceKernel<<<N/TPB, TPB>>>(d_out, ref, N);

	float* host_out = (float*) malloc(N*sizeof(float));	
  	cudaMemcpy(host_out, d_out, N*sizeof(float), cudaMemcpyDeviceToHost);

	std::cout << host_out[N-1] << std::endl;

	cudaFree(d_out); // Free the memory
	return 0;
}