MPI_COMPILE_FLAGS = $(mpic++ --showme:compile)
MPI_LINK_FLAGS = $(mpic++ --showme:link)
 
sieve: sieve.cpp
	$(CC) $(MPI_COMPILE_FLAGS) sieve.cpp $(MPI_LINK_FLAGS) -lm -lstdc++ -o ../sieve

clean:
	rm ../sieve
