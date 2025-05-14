MPI_COMPILE_FLAGS = $(mpiicc --showme:compile)
MPI_LINK_FLAGS = $(mpiicc --showme:link)

CC=mpiicc

$(info Using $(CC) compiler) 

sieve: sieve.cpp
	$(CC) $(MPI_COMPILE_FLAGS) sieve.cpp $(MPI_LINK_FLAGS) -lm -lstdc++ -o ../sieve

clean:
	rm ../sieve
