#!/bin/bash -l
# Run this file with: sbatch slurm-test.slurm
# This script runs a tiny hifiasm assembly smoke test.

# Slurm resources for this short threaded hifiasm example.
#SBATCH --job-name=test-hifiasm
#SBATCH --output=output.txt
#SBATCH --error=error.txt
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
if [[ ! -f reads.fq && -f hifiasm/single-node/reads.fq ]]; then
    cd hifiasm/single-node
fi

# load hifiasm.
module load hifiasm/0.25.0

# remove old hifiasm outputs before rerunning.
rm -f hifiasm-test*

# print the hifiasm version in the job log.
hifiasm --version
# run hifiasm using the CPU count requested from Slurm.
# /usr/bin/time -v records resource use in the job log.
/usr/bin/time -v hifiasm -f0 --hg-size 4k -t "${SLURM_CPUS_PER_TASK}" -o hifiasm-test reads.fq
# list generated files so users can see what hifiasm produced.
ls -lh hifiasm-test*
