MPI_COMPILE_FLAGS = $(shell mpicxx --showme:compile)
MPI_LINK_FLAGS = $(shell mpicxx --showme:link)

CC=mpicxx

$(info Using $(CC) compiler) 

sieve: sieve.cpp
	$(CC) $(MPI_COMPILE_FLAGS) sieve.cpp $(MPI_LINK_FLAGS) -lm -lstdc++ -o ../sieve

clean:
	rm ../sieve
