#!/bin/bash -l
# Run this file with: sbatch slurm-test.slurm
# This script demonstrates an embarrassingly parallel workload with GNU Parallel.

# Give the job a recognizable scheduler name; all suite jobs begin with test-.
#SBATCH --job-name=test-calc-pi-parallel
# Write standard output to a file named with the job name and Slurm job ID.
#SBATCH --output=%x-%j.out
# Write standard error to a matching file; this helps diagnose failed jobs.
#SBATCH --error=%x-%j.err
# Use the debug partition because this is an instructional/regression test.
#SBATCH --partition=debug
# Keep the example short; increase this for real production calculations.
#SBATCH --time=00:05:00
# Request one node. GNU Parallel below will use cores on this single node.
#SBATCH --nodes=1
# Request one Slurm task because GNU Parallel, not Slurm MPI, launches the work.
#SBATCH --ntasks=1
# Reserve eight CPU cores for the independent Python calculations.
#SBATCH --cpus-per-task=8
# Reserve a small amount of memory for this lightweight CPU example.
#SBATCH --mem=2G

# fail fast on errors, unset variables, or failed pipeline commands.
set -euo pipefail
# run from the directory where sbatch was submitted.
# ${SLURM_SUBMIT_DIR:-$PWD} means "use SLURM_SUBMIT_DIR, or PWD if unset."
cd "${SLURM_SUBMIT_DIR:-$PWD}"

# load GNU Parallel so the parallel command is available.
module load parallel

# run one Python calculation for each value in data/step_sizes.txt.
# --jobs uses the CPU count requested from Slurm, and --joblog records each task.
parallel --jobs "${SLURM_CPUS_PER_TASK}" --joblog test-calc-pi-parallel.joblog \
    "python3 code/calcPiSerial.py {}" :::: data/step_sizes.txt
