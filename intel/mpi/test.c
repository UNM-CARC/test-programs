#include "mpi.h"

int main(argc, argv)
     int argc;
     char **argv;
{
  int rank, size, n, to, from, tagno;
  MPI_Status status;
  n = -1;
  MPI_Init(&argc,&argv);
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &size);
  to = rank + 1;
  if (rank == size -1) to = 0;
  from = rank - 1;
  tagno = 201;
  printf("Process  %d of %d is alive\n",rank,size);
  if (rank == 0){
    from = size - 1;
    printf("Please enter a positive integer\n");
    scanf("%d",&n);
    printf("n = %d\n",n);
    MPI_Send(&n,1,MPI_INT,to,tagno,MPI_COMM_WORLD);
  }
  while (1){
    from = MPI_ANY_SOURCE;
    MPI_Recv(&n,1,MPI_INT,from,tagno,MPI_COMM_WORLD, &status); 
    printf ("Rank %d received %d\n",rank, n);
    if (rank == 0) {n--;tagno++;}
    MPI_Send(&n,1,MPI_INT,to,tagno,MPI_COMM_WORLD);
    if (rank != 0) {n--;tagno++;}
    if (n<0){
      MPI_Finalize();
      return 0;
    }
  }
}
