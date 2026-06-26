#!/bin/bash -l
# Run this file with: sbatch slurm-test.slurm
# This script demonstrates a small local Snakemake workflow inside a Slurm job.

# Slurm resources for this small workflow example.
#SBATCH --job-name=test-snakemake
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err
#SBATCH --partition=debug
#SBATCH --time=00:05:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=2G

# fail fast on errors, unset variables, or failed pipeline commands.
set -euo pipefail

# locate this example directory when submitted from the repo root.
script_dir="${SLURM_SUBMIT_DIR:-$PWD}"
if [[ -f "$script_dir/snakemake/Hopper/single-node/slurm-test.slurm" ]]; then
    script_dir="$script_dir/snakemake/Hopper/single-node"
fi
if [[ -f "$script_dir/snakemake/Hopper/single-node/slurm-test.slurm" ]]; then
    script_dir="$script_dir/snakemake/Hopper/single-node"
fi

# create a clean per-job output directory and copy workflow inputs.
run_dir="$script_dir/outputs/${SLURM_JOB_NAME}-${SLURM_JOB_ID}"
rm -rf "$run_dir"
mkdir -p "$run_dir"
cp -a "$script_dir/Snakefile" "$script_dir/code" "$script_dir/data" "$run_dir/"
cd "$run_dir"

# load Snakemake and Python.
module --ignore-cache load snakemake/6.15.1-6ocs python/3.13.5-ajzf

# run Snakemake locally using the CPU count requested from Slurm.
snakemake --cores "${SLURM_CPUS_PER_TASK}" --printshellcmds results/results_all.txt
# confirm the workflow produced its final output file.
test -s results/results_all.txt
# confirm the output has one result per input step size.
test "$(wc -l < results/results_all.txt)" -eq "$(wc -l < data/step_sizes.txt)"
# confirm the results file contains pi estimates.
grep -q "pi =" results/results_all.txt
