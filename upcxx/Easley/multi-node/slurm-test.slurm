#!/bin/bash -l
# Run this file with: sbatch slurm-test.slurm
# This script demonstrates a multi-node UPC++ hello-world build and run.

# Slurm resources for a two-node UPC++ example.
#SBATCH --job-name=test-upcxx
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err
#SBATCH --time=00:05:00
#SBATCH --mem=8G
#SBATCH --partition=debug
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=2

# fail fast on errors, unset variables, or failed pipeline commands.
set -euo pipefail
# locate this example directory when submitted from common paths.
cd "${SLURM_SUBMIT_DIR:-$PWD}"
if [[ -f upcxx/multi-node/slurm-test.slurm ]]; then
    cd upcxx/multi-node
elif [[ -f ../multi-node/slurm-test.slurm ]]; then
    cd ../multi-node
fi

# load the UPC++ module appropriate for the current cluster.
case "$(hostname -s)" in
    hopper*)
        module load upcxx/2022.3.0-yrwd
        ;;
    *)
        module load openmpi/4.1.7-e7k3 upcxx/2023.9.0-27k4
        ;;
esac

# remove stale build products.
make clean
# build the UPC++ hello program.
make

# launch one UPC++ process per Slurm task.
# /usr/bin/time -v records resource use in the job log.
/usr/bin/time -v srun -n "${SLURM_NTASKS}" ./hello
