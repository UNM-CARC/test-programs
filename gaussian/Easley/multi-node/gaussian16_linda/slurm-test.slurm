#!/bin/bash -l
# Run this file with: sbatch slurm-test.slurm
# This script demonstrates a two-node Gaussian Linda run.

# Slurm resources for a Gaussian Linda parallel example.
#SBATCH --job-name=test-gaussian16-linda
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err
#SBATCH --partition=debug
#SBATCH --time=00:05:00
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=4G

# fail fast on errors, unset variables, or failed pipeline commands.
set -euo pipefail
# run from the directory where sbatch was submitted.
cd "${SLURM_SUBMIT_DIR:-$PWD}"

# load Gaussian 16.
module load gaussian/g16

# enable verbose Linda diagnostics in the Gaussian log.
export GAUSS_LFLAGS="-v"
# declare the Linda worker host list variable before assigning it.
export GAUSS_WDEF
# set the number of Linda workers from the Slurm task count.
export GAUSS_PDEF="${SLURM_NTASKS}"
# convert Slurm's allocated host names into Gaussian's comma list.
GAUSS_WDEF="$(scontrol show hostnames "$SLURM_JOB_NODELIST" | paste -sd, -)"

# print the parallel layout for users to inspect.
echo "Parallelizing ${GAUSS_PDEF} Linda workers across ${GAUSS_WDEF}."
# run Gaussian on the HCl input and write HCl.log.
g16 HCl.gjf HCl.log
