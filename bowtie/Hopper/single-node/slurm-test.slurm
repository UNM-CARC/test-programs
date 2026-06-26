#!/bin/bash -l
# Run this file with: sbatch slurm-test.slurm
# This script builds a tiny Bowtie index and aligns test reads.

# Slurm resources for this short serial Bowtie example.
#SBATCH --job-name=test-bowtie
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err
#SBATCH --time=00:02:00
#SBATCH --mem=1G
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --partition=debug

# fail fast on errors, unset variables, or failed pipeline commands.
set -euo pipefail
# start from the submission directory and move into this example
# when the job was submitted from the repository root.
cd "${SLURM_SUBMIT_DIR:-$PWD}"
if [[ ! -f reads.fq && -f bowtie/single-node/reads.fq ]]; then
    cd bowtie/single-node
fi

# load Bowtie.
module load bowtie/1.3.1-pi6i

# remove previous index/alignment files before rerunning.
rm -f test_index.*.ebwt alignment.sam
# build a Bowtie index from the small reference FASTA.
srun bowtie-build test.fa test_index
# align FASTQ reads and write SAM output.
srun bowtie -q test_index reads.fq -S alignment.sam
