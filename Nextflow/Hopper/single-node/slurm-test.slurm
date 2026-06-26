#!/bin/bash -l
# Run this file with: sbatch slurm-test.slurm
# This script demonstrates launching a Nextflow workflow inside a Slurm job.

# Give the job a recognizable scheduler name; all suite jobs begin with test-.
#SBATCH --job-name=test-nextflow
# Write standard output to a Slurm job-ID-specific file.
#SBATCH --output slurm-%j.out
# Write standard error to a Slurm job-ID-specific file.
#SBATCH --error slurm-%j.error
# Allow enough time for the workflow smoke test.
#SBATCH --time 00:20:00
# Use the debug partition because this is an instructional/regression test.
#SBATCH --partition=debug
# Request one scheduler task; Nextflow coordinates work from this process.
#SBATCH --ntasks=1
# Reserve a small number of CPU cores that the local workflow can use.
#SBATCH --cpus-per-task=4
# Reserve memory for the workflow and its local tasks.
#SBATCH --mem=32G

# fail fast on errors, unset variables, or failed pipeline commands.
set -euo pipefail
# start from the directory where sbatch was submitted.
cd "${SLURM_SUBMIT_DIR:-$PWD}"
# locate the Nextflow example if submitted from the repo root or
# from inside the Nextflow directory.
if [[ -f ../Nextflow/slurm-test.slurm ]]; then
    cd ../Nextflow
elif [[ -f Nextflow/slurm-test.slurm ]]; then
    cd Nextflow
fi

# load Java and Nextflow; GCC is included for toolchain compatibility.
module load gcc openjdk nextflow/24.10.5-iysd

# run the workflow with its local configuration and write outputs
# under results so users can inspect what the workflow produced.
nextflow run main.nf -c ./nextflow.config --outdir results
