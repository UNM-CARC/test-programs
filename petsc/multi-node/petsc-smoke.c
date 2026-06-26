#include <petscsys.h>

int main(int argc, char **argv)
{
  PetscErrorCode ierr;
  PetscMPIInt rank;
  PetscMPIInt size;

  ierr = PetscInitialize(&argc, &argv, NULL, NULL);
  if (ierr) return (int)ierr;
  MPI_Comm_rank(PETSC_COMM_WORLD, &rank);
  MPI_Comm_size(PETSC_COMM_WORLD, &size);
  ierr = PetscSynchronizedPrintf(PETSC_COMM_WORLD,
                                 "PETSc rank %d of %d\n", rank, size);
  if (ierr) return (int)ierr;
  ierr = PetscSynchronizedFlush(PETSC_COMM_WORLD, PETSC_STDOUT);
  if (ierr) return (int)ierr;
  ierr = PetscFinalize();
  if (ierr) return (int)ierr;
  return 0;
}
