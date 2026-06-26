#!/bin/bash -l
# Run this file with: sbatch slurm-test.slurm
# This script builds a tiny Bowtie2 index and aligns test reads with threads.

# Slurm resources for this short threaded Bowtie2 example.
#SBATCH --job-name=test-bowtie2
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err
#SBATCH --time=00:05:00
#SBATCH --mem=2G
#SBATCH --partition=debug
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4

# fail fast on errors, unset variables, or failed pipeline commands.
set -euo pipefail
# start from the submission directory and move into this example
# when the job was submitted from the repository root.
cd "${SLURM_SUBMIT_DIR:-$PWD}"
if [[ ! -f reads.fq && -f bowtie2/single-node/reads.fq ]]; then
    cd bowtie2/single-node
fi

# load Bowtie2 and its compiler runtime dependency.
module load gcc/14.2.0-a75l bowtie2/2.5.2-hfjx

# remove previous index/alignment files before rerunning.
rm -f test_index.*.bt2 alignment.sam

# build a Bowtie2 index from the small reference FASTA.
bowtie2-build test.fa test_index
# align reads with the same thread count requested from Slurm.
# /usr/bin/time -v records resource use in the job log.
/usr/bin/time -v srun --cpus-per-task="${SLURM_CPUS_PER_TASK}" \
    bowtie2 -x test_index -U reads.fq -p "${SLURM_CPUS_PER_TASK}" -S alignment.sam
