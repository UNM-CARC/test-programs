MPI_COMPILE_FLAGS = $(mpiicc --showme:compile)
MPI_LINK_FLAGS = $(mpiicc --showme:link)

CC=mpiicc

$(info Using $(CC) compiler) 

sieve: mpihello.cpp
	$(CC) $(MPI_COMPILE_FLAGS) mpihello.cpp $(MPI_LINK_FLAGS) -lm -lstdc++ -o mpihello

clean:
	rm mpihello
