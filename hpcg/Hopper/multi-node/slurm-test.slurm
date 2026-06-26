#!/bin/bash -l
# Run this file with: sbatch slurm-test.slurm
# This script demonstrates running HPCG across two nodes.

# Slurm resources for a small multi-node HPCG benchmark.
#SBATCH --job-name=test-hpcg
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
if [[ ! -f hpcg.dat && -f hpcg/multi-node/hpcg.dat ]]; then
    cd hpcg/multi-node
fi

# load MPI and HPCG.
module load openmpi/4.1.7-3ilj hpcg/3.1-hchi
# launch one HPCG rank per Slurm task.
# /usr/bin/time -v records resource use in the job log.
/usr/bin/time -v srun -n "${SLURM_NTASKS}" xhpcg
