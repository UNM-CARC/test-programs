#!/bin/bash -l
# Run this file with: sbatch slurm-test.slurm
# This script demonstrates a small parallel I/O test with IOR.

# Slurm resources for a small multi-node IOR run.
#SBATCH --job-name=test-ior
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
if [[ ! -f slurm-test.slurm && -f ior/multi-node/slurm-test.slurm ]]; then
    cd ior/multi-node
fi

# load MPI and IOR.
module load openmpi/4.1.7-e7k3 ior/3.3.0-6pri

# remove previous IOR test files before rerunning.
rm -f testfile*
# run IOR write/read test using one rank per Slurm task.
# /usr/bin/time -v records resource use in the job log.
/usr/bin/time -v srun -n "${SLURM_NTASKS}" \
    ior -w -r -b 4m -t 1m -o testfile
