#!/bin/bash -l
# Run this file with: sbatch slurm-test.slurm
# This script demonstrates a small multi-node run with TAU loaded.

# Slurm resources for a two-node TAU example.
#SBATCH --job-name=test-tau
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
if [[ -f tau/multi-node/slurm-test.slurm ]]; then
    cd tau/multi-node
elif [[ -f ../multi-node/slurm-test.slurm ]]; then
    cd ../multi-node
fi

# load GCC, TAU, and the time utility module.
module load gcc/14.2.0-a75l tau/2.34-4iyx time
# compile the tiny hello program.
gcc -O2 -o hello hello.c

# launch one hello process per Slurm task.
# $(which time) uses the module-provided time command for resource logging.
$(which time) -v srun -n "${SLURM_NTASKS}" ./hello
