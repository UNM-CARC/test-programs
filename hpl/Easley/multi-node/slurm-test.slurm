#!/bin/bash -l
# Run this file with: sbatch slurm-test.slurm
# This script demonstrates a small HPL run across two nodes.

# Slurm resources for a small multi-node HPL benchmark.
#SBATCH --job-name=test-hpl
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err
#SBATCH --time=00:05:00
#SBATCH --mem=2G
#SBATCH --partition=debug
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=2

# fail fast on errors, unset variables, or failed pipeline commands.
set -euo pipefail
# locate this example directory when submitted from the repo root.
cd "${SLURM_SUBMIT_DIR:-$PWD}"
if [[ ! -f HPL.dat && -f hpl/multi-node/HPL.dat ]]; then
    cd hpl/multi-node
fi

# load MPI and HPL.
module load intel-oneapi-mpi/2021.15.0-6pwh hpl/2.3-4ijf
# launch HPL with one rank per Slurm task.
# /usr/bin/time -v records resource use in the job log.
/usr/bin/time -v srun -n "${SLURM_NTASKS}" xhpl
