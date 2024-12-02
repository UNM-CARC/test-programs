MPI_COMPILE_FLAGS = $(mpiicc --showme:compile)
MPI_LINK_FLAGS = $(mpiicc --showme:link)

CC=mpiicc

$(info Using $(CC) compiler) 

sieve: mpi_bfs.cpp
	$(CC) $(MPI_COMPILE_FLAGS) mpi_bfs.cpp $(MPI_LINK_FLAGS) -lm -lstdc++ -o ../mpi_bfs

clean:
	rm ../mpi_bfs
