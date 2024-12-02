#include "mpi.h"
#include "stdio.h"

int main(int argc, char *argv[]) 
{
  int pid=-1, np=-1;
  MPI_Init(&argc, &argv);
  MPI_Comm_rank(MPI_COMM_WORLD, &pid);
  MPI_Comm_size(MPI_COMM_WORLD, &np);

  // This process id
  int rank = -1;
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);

  // First figure out how many other MPI processes are running on this node  
  MPI_Comm intranode_comm;
  int local_rank = -1;
  
  MPI_Comm_split_type( MPI_COMM_WORLD, MPI_COMM_TYPE_SHARED, rank, MPI_INFO_NULL, &intranode_comm);
  MPI_Comm_rank(intranode_comm, &local_rank);

  int n_procs_on_host;
  MPI_Comm_size( intranode_comm, &n_procs_on_host );
  
  char name[MPI_MAX_PROCESSOR_NAME];
  unsigned int len = -1;
  MPI_Get_processor_name(name, &len);

  printf("ComputeNode (%d): There are %d MPI proceses on %s.\n", rank, n_procs_on_host, name);
  fflush(stdout);
  
  return 0;
}
