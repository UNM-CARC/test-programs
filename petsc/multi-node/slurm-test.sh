#!/bin/bash
#SBATCH --job-name=test-petsc
#SBATCH --output=output.txt
#SBATCH --error=error.txt
#SBATCH --time=00:05:00
#SBATCH --mem=2G
#SBATCH --partition=debug
#SBATCH --nodes=2
#SBATCH --ntasks=8

# To make this work - ex19.c from examples directory under src/snes/tutorials directory was compiled
# The executable was then placed into the same directory as this script
# We also updated this script to add an export of the correct MPI_PMI_LIBRARY



export I_MPI_PMI_LIBRARY=/usr/lib64/libpmi2.so

module load intel-oneapi-mpi/2021.15.0-6pwh petsc time

# Assumes ex19 was included in the module
$(which time)  -v srun -n 8 ./ex19 -snes_monitor
