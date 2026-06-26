#!/bin/bash
# Run this file with: sbatch slurm-test.slurm
# This script demonstrates running the AlphaFold 3 Apptainer container on a GPU.

# Give the job a recognizable scheduler name; all suite jobs begin with test-.
#SBATCH --job-name=test-alphafold3
# Write standard output to a file named with the job name and Slurm job ID.
#SBATCH --output=%x-%j.out
# Write standard error to a matching file; this helps diagnose failed jobs.
#SBATCH --error=%x-%j.err
# Use the debug partition because this is an instructional/regression test.
#SBATCH --partition=debug
# Request one Slurm task; the container test runs as a single process.
#SBATCH --ntasks=1
# Reserve CPU cores for container-side preprocessing/test work.
#SBATCH --cpus-per-task=8
# Reserve memory for AlphaFold 3 model/database access.
#SBATCH --mem=32G
# Request one GPU and expose it to Apptainer with --nv below.
#SBATCH --gpus=1
# Allow enough time for the AlphaFold 3 self-test.
#SBATCH --time=00:20:00

# fail fast on errors, unset variables, or failed pipeline commands.
set -euo pipefail

# Load Apptainer with the same toolchain used by the workshop examples.
# --ignore-cache avoids stale Lmod cache entries on shared filesystems.
module --ignore-cache load gcc/14.2.0-cuda-jeua apptainer

# locate this example directory when submitted from the repo root
# or from inside alphafold3/cuda.
script_dir="${SLURM_SUBMIT_DIR:-$PWD}"
if [[ -f "$script_dir/alphafold3/Hopper/gpu/slurm-test.slurm" ]]; then
    script_dir="$script_dir/alphafold3/Hopper/gpu"
fi
if [[ -f "$script_dir/alphafold3/Hopper/gpu/slurm-test.slurm" ]]; then
  script_dir="$script_dir/alphafold3/Hopper/gpu"
fi

# per-job directory for AlphaFold 3 input/output files.
RUN_DIR="$script_dir/outputs/${SLURM_JOB_NAME}-${SLURM_JOB_ID}"
# directory mounted into the container for JSON input.
AF_INPUT="$RUN_DIR/af_input"
# directory reserved for AlphaFold 3 output files.
AF_OUTPUT="$RUN_DIR/af_output"
# shared AlphaFold 3 model parameters mounted read-only into container.
MODEL_DIR="/carc/scratch/shared/alphafold/alphafold3/model"
# shared AlphaFold 3 databases mounted read-only into container.
DATABASES_DIR="/carc/scratch/shared/alphafold/alphafold3/db"
# Apptainer image containing AlphaFold 3 and dependencies.
SIF_IMAGE="/projects/shared/apptainer/alphafold3.sif"

# create input and output directories for this job.
mkdir -p "$AF_INPUT" "$AF_OUTPUT"
# copy the small JSON test input into the container input mount.
cp "$script_dir/test.json" "$AF_INPUT/test.json"

# Run the same AlphaFold 3 container self-test used in the workshop examples.
# --nv passes the allocated GPU into the Apptainer container.
# --bind maps model and database directories to paths expected by
# AlphaFold 3 inside the container.
apptainer exec --nv \
    --bind "${MODEL_DIR}:/root/models" \
    --bind "${DATABASES_DIR}:/root/public_databases" \
    "${SIF_IMAGE}" env HOME=/root python /app/alphafold/run_alphafold_test.py \
    --model_dir=/root/models \
    --db_dir=/root/public_databases
