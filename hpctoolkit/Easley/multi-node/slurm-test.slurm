#!/bin/bash -l
# Run this file with: sbatch slurm-test.slurm
# This script demonstrates a simple multi-node executable with HPCToolkit loaded.

# Slurm resources for a small multi-node MPI-style example.
#SBATCH --job-name=test-hpctoolkit
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
if [[ -f hpctoolkit/multi-node/slurm-test.slurm ]]; then
    cd hpctoolkit/multi-node
elif [[ -f ../multi-node/slurm-test.slurm ]]; then
    cd ../multi-node
fi

# load MPI and HPCToolkit.
module load intel-oneapi-mpi/2021.15.0-6pwh hpctoolkit/2024.01.1-y3f2

# compile the tiny hello program only if needed.
if [[ ! -x ./hello ]]; then
    # build the example executable.
    gcc -O2 -o hello hello.c
fi

# launch one hello process per Slurm task.
# /usr/bin/time -v records resource use in the job log.
/usr/bin/time -v srun -n "${SLURM_NTASKS}" ./hello
