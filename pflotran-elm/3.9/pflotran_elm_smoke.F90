program pflotran_elm_smoke
#include "petsc/finclude/petscsys.h"
  use petscsys
  use clm_pflotran_interface_data, only : clm_pflotran_idata_type

  implicit none

  type(clm_pflotran_idata_type) :: idata
  PetscErrorCode :: ierr
  PetscMPIInt :: rank

  call PetscInitialize(PETSC_NULL_CHARACTER, ierr)
  CHKERRQ(ierr)

  call MPI_Comm_rank(PETSC_COMM_WORLD, rank, ierr)
  CHKERRQ(ierr)

  idata%nzclm_mapped = 1
  idata%nxclm_mapped = 1
  idata%nyclm_mapped = 1
  idata%nlclm_sub = 1
  idata%ngclm_sub = 1

  if (rank == 0) then
    write(*,'(a)') 'PFLOTRAN-ELM smoke test linked and initialized PETSc.'
    write(*,'(a,i0,a,i0,a,i0)') 'Minimal CLM mapped grid: ', &
      idata%nxclm_mapped, ' x ', idata%nyclm_mapped, ' x ', &
      idata%nzclm_mapped
  end if

  call PetscFinalize(ierr)
  CHKERRQ(ierr)
end program pflotran_elm_smoke
