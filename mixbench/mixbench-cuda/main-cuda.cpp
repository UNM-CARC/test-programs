/**
 * main-cuda.cpp: This file is part of the mixbench GPU micro-benchmark suite.
 *
 * Contact: Elias Konstantinidis <ekondis@gmail.com>
 **/

#include <stdio.h>
#include <stdlib.h>
#include <cuda.h>
#include <cuda_runtime.h>
#include <string.h>
#include "lcutil.h"
#include "mix_kernels_cuda.h"
#include "version_info.h"

#ifdef READONLY
#define VECTOR_SIZE (32*1024*1024)
#else
#define VECTOR_SIZE (8*1024*1024)
#endif

int main(int argc, char* argv[]) {
#ifdef READONLY
	printf("mixbench/read-only (%s)\n", VERSION_INFO);
#else
	printf("mixbench/alternating (%s)\n", VERSION_INFO);
#endif

	unsigned int datasize = VECTOR_SIZE*sizeof(double);

	cudaSetDevice(0);
	StoreDeviceInfo(stdout);

	size_t freeCUDAMem, totalCUDAMem;
	cudaMemGetInfo(&freeCUDAMem, &totalCUDAMem);
	printf("Total GPU memory %lu, free %lu\n", totalCUDAMem, freeCUDAMem);
	printf("Buffer size:          %dMB\n", datasize/(1024*1024));
	
	double *c;
	c = (double*)malloc(datasize);

	mixbenchGPU(c, VECTOR_SIZE);

	free(c);

	return 0;
}
