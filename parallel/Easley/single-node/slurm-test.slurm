#!/usr/bin/env bash
# Run this file with: sbatch slurm-test.slurm
# This script demonstrates GNU Parallel on one node.

# Slurm resources for an embarrassingly parallel single-node example.
#SBATCH --job-name=test-gnu-parallel
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
if [[ -f "$script_dir/parallel/Easley/single-node/slurm-test.slurm" ]]; then
    script_dir="$script_dir/parallel/Easley/single-node"
fi
if [[ -f "$script_dir/parallel/Easley/single-node/slurm-test.slurm" ]]; then
    script_dir="$script_dir/parallel/Easley/single-node"
fi

# reset modules and load GNU Parallel.
module purge
module load parallel/20240822-ao2z

# create a clean per-job output directory so runs do not collide.
run_dir="$script_dir/outputs/${SLURM_JOB_NAME}-${SLURM_JOB_ID}"
rm -rf "$run_dir"
mkdir -p "$run_dir"
cd "$run_dir"

# create eight small task IDs for GNU Parallel.
seq 1 8 > tasks.txt

# run one Python hashing task per input line, up to the Slurm CPU count.
parallel --jobs "${SLURM_CPUS_PER_TASK}" --joblog parallel.joblog \
    'python3 -c "import hashlib, sys; n=int(sys.argv[1]); payload=(str(n)*2000000).encode(); print(f\"{n}\t{hashlib.sha256(payload).hexdigest()}\")" {} > result-{}.txt' \
    :::: tasks.txt

# combine task outputs in numeric order.
cat result-*.txt | sort -n > parallel-results.tsv
# confirm all eight tasks produced output.
test "$(wc -l < parallel-results.tsv)" -eq 8
# confirm every GNU Parallel task exit code was zero.
awk 'NR > 1 { if ($7 != 0) exit 1 }' parallel.joblog
