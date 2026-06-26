#!/bin/bash -l
# Run this file with: sbatch slurm-test.slurm
# This script compiles and runs a tiny PETSc MPI program.

# Slurm resources for a two-node PETSc example.
#SBATCH --job-name=test-petsc
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err
#SBATCH --time=00:05:00
#SBATCH --mem=2G
#SBATCH --partition=debug
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=2

# fail fast on errors, unset variables, or failed pipeline commands.
set -euo pipefail
# locate this example directory when submitted from common paths.
cd "${SLURM_SUBMIT_DIR:-$PWD}"
if [[ -f petsc/multi-node/slurm-test.slurm ]]; then
    cd petsc/multi-node
elif [[ -f ../multi-node/slurm-test.slurm ]]; then
    cd ../multi-node
fi

# point Intel MPI at Slurm's PMI library when needed by this stack.
export I_MPI_PMI_LIBRARY=/usr/lib64/libpmi2.so

# load PETSc and the time utility module.
module load petsc/3.9.4 time

# build the PETSc smoke executable only if needed.
if [[ ! -x ./petsc-smoke ]]; then
    # compile and link against PETSc using pkg-config.
    mpicc petsc-smoke.c $(pkg-config --cflags --libs PETSc) -o petsc-smoke
fi

# launch one PETSc MPI rank per Slurm task.
# $(which time) uses the module-provided time command for resource logging.
$(which time) -v srun -n "${SLURM_NTASKS}" ./petsc-smoke
