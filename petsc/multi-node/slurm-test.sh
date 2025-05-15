#!/bin/bash
#SBATCH --job-name=test-petsc
#SBATCH --output=output.txt
#SBATCH --error=error.txt
#SBATCH --time=00:05:00
#SBATCH --mem=2G
#SBATCH --partition=debug
#SBATCH --nodes=2
#SBATCH --ntasks=8

export I_MPI_PMI_LIBRARY=/usr/lib64/libpmi2.so

module load intel-oneapi-mpi/2021.15.0-6pwh petsc time

# Assumes ex19 was included in the module
$(which time)  -v srun -n 8 ./ex19 -snes_monitor
