#!/usr/bin/env bash
# Run this file with: sbatch slurm-test.slurm
# This script demonstrates Stacks ustacks on synthetic RAD-like reads.

# Slurm resources for this short threaded Stacks example.
#SBATCH --job-name=test-stacks-ustacks
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err
#SBATCH --partition=debug
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=2G
#SBATCH --time=00:05:00

# fail fast on errors, unset variables, or failed pipeline commands.
set -euo pipefail

# locate this example directory when submitted from the repo root.
script_dir="${SLURM_SUBMIT_DIR:-$PWD}"
if [[ -f "$script_dir/stacks/Hopper/single-node/slurm-test.slurm" ]]; then
    script_dir="$script_dir/stacks/Hopper/single-node"
fi
if [[ -f "$script_dir/stacks/Hopper/single-node/slurm-test.slurm" ]]; then
    script_dir="$script_dir/stacks/Hopper/single-node"
fi

# reset modules and load Stacks.
module purge
module load stacks/2.53-ftxb

# create a clean per-job output directory with a Stacks output subdir.
run_dir="$script_dir/outputs/${SLURM_JOB_NAME}-${SLURM_JOB_ID}"
rm -rf "$run_dir"
mkdir -p "$run_dir/stacks_out"
cd "$run_dir"

# generate 40 identical synthetic reads for ustacks.
for i in $(seq 1 40); do
    printf '@sample_read_%03d\nACGTTGCATGTCAGTACGTAGCTAGCTAGTACGTACGTAGCTAGCTAGTACGATCG\n+\nIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII\n' "$i"
done > sample.fastq

# run ustacks using the CPU count requested from Slurm.
ustacks \
    -f sample.fastq \
    -o stacks_out \
    -i 1 \
    --name sample \
    -m 3 \
    -p "${SLURM_CPUS_PER_TASK}"

# confirm the expected Stacks output tables were created.
test -s stacks_out/sample.tags.tsv
test -s stacks_out/sample.snps.tsv
test -s stacks_out/sample.alleles.tsv
# record how many output files were produced.
printf 'ustacks_outputs=%s\n' "$(find stacks_out -type f | wc -l)" > stacks-test.out
