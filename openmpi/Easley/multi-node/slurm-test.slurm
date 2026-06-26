#!/bin/bash -l
# Run this file with: sbatch slurm-test.slurm
# This script builds and runs an MPI prime-sieve example with OpenMPI.

# Slurm resources for a two-node OpenMPI example.
#SBATCH --job-name=test-openmpi
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=2
#SBATCH --mem=1G
#SBATCH --time=00:05:00
#SBATCH --partition=debug

# fail fast on errors, unset variables, or failed pipeline commands.
set -euo pipefail
# locate this example directory when submitted from the repo root.
script_dir="${SLURM_SUBMIT_DIR:-$PWD}"
repo_root="$(cd "$script_dir/../../.." && pwd)"
cd "$repo_root/openmpi"

# load OpenMPI.
module load openmpi/4.1.7-3ilj

# build the sieve executable only if needed.
if [[ ! -x ./sieve ]]; then
    # compile the MPI source.
    make -C sieve_src
fi

# launch the MPI executable with one rank per Slurm task.
# /usr/bin/time -v records resource use in the job log.
/usr/bin/time -v srun -n "${SLURM_NTASKS}" ./sieve 10000000
