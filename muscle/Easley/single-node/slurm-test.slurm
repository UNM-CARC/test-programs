#!/bin/bash -l
# Run this file with: sbatch slurm-test.slurm
# This script aligns three synthetic sequences with MUSCLE.

# Slurm resources for this short MUSCLE example.
#SBATCH --job-name=test-muscle
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err
#SBATCH --partition=debug
#SBATCH --time=00:05:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=1G

# fail fast on errors, unset variables, or failed pipeline commands.
set -euo pipefail

# locate this example directory when submitted from the repo root.
script_dir="${SLURM_SUBMIT_DIR:-$PWD}"
if [[ -f "$script_dir/muscle/Easley/single-node/slurm-test.slurm" ]]; then
    script_dir="$script_dir/muscle/Easley/single-node"
fi
if [[ -d "$script_dir/muscle/single-node" ]]; then
    script_dir="$script_dir/muscle/Easley/single-node"
fi

# create a clean per-job output directory so runs do not collide.
run_dir="$script_dir/outputs/${SLURM_JOB_NAME}-${SLURM_JOB_ID}"
rm -rf "$run_dir"
mkdir -p "$run_dir"
cd "$run_dir"

# load MUSCLE.
module --ignore-cache load muscle/3.8.1551-nuba

# write a tiny FASTA file for the alignment.
cat > sequences.fa <<'EOF'
>seq1
ACGTACGTACGT
>seq2
ACGTTGGTACGT
>seq3
ACGTACGTACTT
EOF

# run MUSCLE on the synthetic FASTA input.
muscle -in sequences.fa -out aligned.fa
# confirm all three input sequences are represented in the alignment.
test "$(grep -c '^>' aligned.fa)" -eq 3
# confirm a specific sequence label survived the alignment.
grep -q "seq2" aligned.fa
