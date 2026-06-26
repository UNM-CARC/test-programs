#!/bin/bash -l
# Run this file with: sbatch slurm-test.slurm
# This script runs FastQC on a tiny FASTQ file.

# Slurm resources for this short threaded FastQC example.
#SBATCH --job-name=test-fastqc
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
if [[ ! -f reads.fq && -f fastqc/single-node/reads.fq ]]; then
    cd fastqc/single-node
fi

# load FastQC.
module load fastqc/0.12.1-yy7t

# remove prior FastQC output before rerunning.
rm -f reads_fastqc.html reads_fastqc.zip
# run FastQC using the thread count requested from Slurm.
# /usr/bin/time -v records resource use in the job log.
/usr/bin/time -v srun --cpus-per-task="${SLURM_CPUS_PER_TASK}" \
    fastqc --threads "${SLURM_CPUS_PER_TASK}" reads.fq
