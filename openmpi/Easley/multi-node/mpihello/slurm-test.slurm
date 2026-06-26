#!/bin/bash -l
# Run this file with: sbatch slurm-test.slurm
# This script compiles and runs a tiny OpenMPI hello-world program.

# Slurm resources for a two-node MPI example.
#SBATCH --job-name=test-openmpi-hello
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err
#SBATCH --partition=debug
#SBATCH --time=00:05:00
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=2
#SBATCH --mem=1G

# fail fast on errors, unset variables, or failed pipeline commands.
set -euo pipefail
# run from the directory where sbatch was submitted.
cd "${SLURM_SUBMIT_DIR:-$PWD}"

# load OpenMPI compiler wrappers and runtime.
module load openmpi/4.1.7-3ilj

# compile the MPI C++ example.
mpicxx mpihello.cpp -o mpihello
# launch one MPI rank per Slurm task.
srun -n "${SLURM_NTASKS}" ./mpihello
