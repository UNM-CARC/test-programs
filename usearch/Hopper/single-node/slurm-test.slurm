#!/bin/bash -l
# Run this file with: sbatch slurm-test.slurm
# This script filters a tiny FASTQ file with USEARCH.

# Slurm resources for this short threaded USEARCH example.
#SBATCH --job-name=test-usearch
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err
#SBATCH --time=00:05:00
#SBATCH --mem=2G
#SBATCH --partition=debug
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2

# fail fast on errors, unset variables, or failed pipeline commands.
set -euo pipefail
# start from the submission directory and move into this example
# when the job was submitted from the repository root.
cd "${SLURM_SUBMIT_DIR:-$PWD}"
if [[ ! -f reads.fq && -f usearch/single-node/reads.fq ]]; then
    cd usearch/single-node
fi

# load USEARCH.
module load usearch/11.0.667-xgso

# remove prior FASTA output before rerunning.
rm -f out.fa
# filter FASTQ reads and write FASTA output using the Slurm CPU count.
# /usr/bin/time -v records resource use in the job log.
/usr/bin/time -v srun --cpus-per-task="${SLURM_CPUS_PER_TASK}" \
    usearch -fastq_filter reads.fq -fastaout out.fa -threads "${SLURM_CPUS_PER_TASK}"
