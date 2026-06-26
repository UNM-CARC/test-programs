#!/bin/bash -l
# Run this file with: sbatch slurm-test.slurm
# This script demonstrates single-node multicore NAMD.

# Slurm resources for a one-node NAMD example.
#SBATCH --partition=debug
#SBATCH --job-name=test-namd
#SBATCH --time 00:05:00
#SBATCH --nodes 1
#SBATCH --ntasks 4
#SBATCH --mem 2G
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err

# fail fast on errors, unset variables, or failed pipeline commands.
set -euo pipefail
# locate this example directory when submitted from common paths.
cd "${SLURM_SUBMIT_DIR:-$PWD}"
if [[ -f namd/single-node/slurm-test.slurm ]]; then
    cd namd/single-node
elif [[ -f ../single-node/slurm-test.slurm ]]; then
    cd ../single-node
fi

# load multicore NAMD.
module load namd/3.0/multicore

# run NAMD with the number of worker threads requested as Slurm tasks.
# /usr/bin/time -v records resource use in the job log.
/usr/bin/time -v namd3 "+p${SLURM_NTASKS}" +setcpuaffinity ubq_ws_eq.conf
