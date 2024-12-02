#include <stdio.h>
#include "mpi.h"
#include <unistd.h>

int main(int argc, char *argv[]) {
  int n, myid, numprocs, rc, i, j, k;
  double start_time, now, diff; 
  char hostname[256];
  size_t len = 255;
  rc = MPI_Init( &argc, &argv );
  start_time = MPI_Wtime();
  rc = MPI_Comm_size( MPI_COMM_WORLD, &numprocs );
  rc = MPI_Comm_rank( MPI_COMM_WORLD, &myid );
  rc = gethostname( hostname, len );
  now = MPI_Wtime();
  diff = now - start_time;
  printf( "BB: Process: %d on Host: %s at %f\n", myid, hostname, diff);
  rc = MPI_Barrier(MPI_COMM_WORLD);
  now = MPI_Wtime();
  diff = now - start_time;
  printf( "AB: Process: %d on Host: %s at %f\n", myid, hostname, diff);
  rc = MPI_Finalize();
}

