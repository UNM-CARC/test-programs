#!/bin/bash -l
# Run this file with: sbatch slurm-test.slurm
# This script demonstrates a two-node Gaussian Linda run on acetyl chloride.

# Slurm resources for a Gaussian Linda parallel example.
#SBATCH --job-name=test-gaussian16-acetylchloride
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err
#SBATCH --partition=debug
#SBATCH --time=00:10:00
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=4G

# fail fast on errors, unset variables, or failed pipeline commands.
set -euo pipefail
# locate this example directory when submitted from the repo root.
script_dir="${SLURM_SUBMIT_DIR:-$PWD}"
if [[ -f "$script_dir/pbs_examples/Hopper/gaussian/gaussian16_linda_acetylchloride/slurm-test.slurm" ]]; then
    script_dir="$script_dir/pbs_examples/Hopper/gaussian/gaussian16_linda_acetylchloride"
fi
if [[ -f "$script_dir/pbs_examples/gaussian/gaussian16_linda_acetylchloride.slurm" ]]; then
    script_dir="$script_dir/pbs_examples/Hopper/gaussian/gaussian16_linda_acetylchloride"
fi

# create a clean per-job output directory so runs do not collide.
run_dir="$script_dir/outputs/${SLURM_JOB_NAME}-${SLURM_JOB_ID}"
rm -rf "$run_dir"
mkdir -p "$run_dir"
cp "$script_dir/AcetylChloride.com" "$run_dir/"
cd "$run_dir"

# load Gaussian 16.
module load gaussian/g16

# enable verbose Linda diagnostics in the Gaussian log.
export GAUSS_LFLAGS="-v"
# declare the Linda worker host list variable before assigning it.
export GAUSS_WDEF
# set worker count from CPUs per task for this Gaussian input.
export GAUSS_PDEF="${SLURM_CPUS_PER_TASK}"
# convert Slurm's allocated host names into Gaussian's comma list.
GAUSS_WDEF="$(scontrol show hostnames "$SLURM_JOB_NODELIST" | paste -sd, -)"

# print the parallel layout for users to inspect.
echo "Parallelizing ${GAUSS_PDEF} Linda workers across ${GAUSS_WDEF}."
# run Gaussian on the copied input file.
g16 AcetylChloride.com AcetylChloride.log
# confirm Gaussian completed normally.
grep -q "Normal termination of Gaussian 16" AcetylChloride.log
