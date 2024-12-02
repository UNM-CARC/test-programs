gpu_mpi:
	nvcc -arch sm_35 -c vecadd_gpu.cu -o vecadd_gpu.o
	mpic++ -c vecadd_mpi.c -o vecadd_mpi.o
	mpic++ vecadd_mpi.o vecadd_gpu.o -lcudart -o vecadd_mpi_gpu

clean:
	rm vecadd_mpi_gpu vecadd_mpi.o vecadd_gpu.o 
