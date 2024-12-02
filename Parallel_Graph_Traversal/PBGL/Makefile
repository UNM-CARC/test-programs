MPI_COMPILE_FLAGS = $(mpiCC --showme:compile)
MPI_LINK_FLAGS = $(mpiCC --showme:link)

INCLUDE_PATH=$(BOOST_INC)
LIB_PATH=$(BOOST_LIB)
LIBS=-lboost_mpi -lboost_graph_parallel -lboost_serialization
WARNING_FLAGS=no-deprecated

CC=mpiCC

$(info Using $(CC) compiler) 

all:	driver family erdos dirtree graphviz bfs_erdos_serial bfs_erdos_parallel bfs_example 

driver: driver.cpp
	$(CC) $(MPI_COMPILE_FLAGS) driver.cpp $(MPI_LINK_FLAGS) -L$(LIB_PATH) -I$(INCLUDE_PATH) -W$(WARNING_FLAGS)  -o driver $(LIBS)

family:
	$(CC) $(MPI_COMPILE_FLAGS) family.cpp $(MPI_LINK_FLAGS) -L$(LIB_PATH) -I$(INCLUDE_PATH) -W$(WARNING_FLAGS)  -o family $(LIBS)	

erdos:
	$(CC) $(MPI_COMPILE_FLAGS) erdos.cpp $(MPI_LINK_FLAGS) -L$(LIB_PATH) -I$(INCLUDE_PATH) -W$(WARNING_FLAGS)  -o erdos $(LIBS)

dirtree:
	$(CC) $(MPI_COMPILE_FLAGS) dirtree.cpp $(MPI_LINK_FLAGS) -L$(LIB_PATH) -I$(INCLUDE_PATH) -W$(WARNING_FLAGS)  -o dirtree $(LIBS)

graphviz:
	$(CC) $(MPI_COMPILE_FLAGS) graphviz.cpp $(MPI_LINK_FLAGS) -L$(LIB_PATH) -I$(INCLUDE_PATH) -W$(WARNING_FLAGS)  -o graphviz $(LIBS)

bfs_erdos_serial: bfs_erdos_serial.cpp
	$(CC) $(MPI_COMPILE_FLAGS) bfs_erdos_serial.cpp $(MPI_LINK_FLAGS) -L$(LIB_PATH) -I$(INCLUDE_PATH) -W$(WARNING_FLAGS)  -o bfs_erdos_serial $(LIBS)

bfs_erdos_parallel: bfs_erdos_parallel.cpp
	$(CC) $(MPI_COMPILE_FLAGS) bfs_erdos_parallel.cpp $(MPI_LINK_FLAGS) -L$(LIB_PATH) -I$(INCLUDE_PATH) -W$(WARNING_FLAGS)  -o bfs_erdos_parallel $(LIBS)

bfs_example:
	$(CC) $(MPI_COMPILE_FLAGS) bfs_example.cpp $(MPI_LINK_FLAGS) -L$(LIB_PATH) -I$(INCLUDE_PATH) -W$(WARNING_FLAGS) -o bfs_example $(LIBS)

bfs_parallel:
	$(CC) $(MPI_COMPILE_FLAGS) bfs_parallel.cpp $(MPI_LINK_FLAGS) -L$(LIB_PATH) -I$(INCLUDE_PATH) -W$(WARNING_FLAGS) -o bfs_parallel $(LIBS)


clean:
	rm driver dirtree graphviz erdos bfs_example bfs_erdos_serial bfs_erdos_parallel bfs_erdos family bfs_parallel
