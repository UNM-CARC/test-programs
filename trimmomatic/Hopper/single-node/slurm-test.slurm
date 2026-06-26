#!/bin/bash -l
# Run this file with: sbatch slurm-test.slurm
# This script runs Trimmomatic on a tiny single-end FASTQ file.

# Slurm resources for this short threaded Trimmomatic example.
#SBATCH --job-name=test-trimmomatic
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
if [[ ! -f reads.fq && -f trimmomatic/single-node/reads.fq ]]; then
    cd trimmomatic/single-node
fi

# load Trimmomatic and the time utility module.
module load trimmomatic/0.39-66mw time

# remove prior trimmed output before rerunning.
rm -f trimmed.fq
# run single-end trimming with the Slurm CPU count as thread count.
# $(which time) finds the module-provided time command for resource logging.
$(which time) -v srun --cpus-per-task="${SLURM_CPUS_PER_TASK}" \
    trimmomatic SE -threads "${SLURM_CPUS_PER_TASK}" reads.fq trimmed.fq SLIDINGWINDOW:4:15 MINLEN:1
