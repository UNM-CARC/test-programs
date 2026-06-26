#!/bin/bash -l
# Run this file with: sbatch slurm-test.slurm
# This script demonstrates a single-node Gaussian shared-memory run.

# Slurm resources for a Gaussian shared-memory example.
#SBATCH --job-name=test-gaussian16
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err
#SBATCH --partition=debug
#SBATCH --time=00:05:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=4G

# fail fast on errors, unset variables, or failed pipeline commands.
set -euo pipefail
# run from the directory where sbatch was submitted.
cd "${SLURM_SUBMIT_DIR:-$PWD}"

# load Gaussian 16.
module load gaussian/g16

# tell Gaussian how many shared-memory processors to use.
export GAUSS_PDEF="${SLURM_CPUS_PER_TASK}"
# run Gaussian on the HCl input and write HCl.log.
g16 HCl.gjf HCl.log
