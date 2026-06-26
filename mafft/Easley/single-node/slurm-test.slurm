#!/bin/bash -l
# Run this file with: sbatch slurm-test.slurm
# This script aligns three synthetic sequences with MAFFT.

# Slurm resources for this short threaded MAFFT example.
#SBATCH --job-name=test-mafft
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err
#SBATCH --partition=debug
#SBATCH --time=00:05:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=1G

# fail fast on errors, unset variables, or failed pipeline commands.
set -euo pipefail

# locate this example directory when submitted from the repo root.
script_dir="${SLURM_SUBMIT_DIR:-$PWD}"
if [[ -f "$script_dir/mafft/Easley/single-node/slurm-test.slurm" ]]; then
    script_dir="$script_dir/mafft/Easley/single-node"
fi
if [[ -d "$script_dir/mafft/single-node" ]]; then
    script_dir="$script_dir/mafft/Easley/single-node"
fi

# create a clean per-job output directory so runs do not collide.
run_dir="$script_dir/outputs/${SLURM_JOB_NAME}-${SLURM_JOB_ID}"
rm -rf "$run_dir"
mkdir -p "$run_dir"
cd "$run_dir"

# load MAFFT.
module --ignore-cache load mafft/7.525-fg7s

# write a tiny FASTA file for the alignment.
cat > sequences.fa <<'EOF'
>seq1
ACGTACGTACGT
>seq2
ACGTTGGTACGT
>seq3
ACGTACGTACTT
EOF

# run MAFFT using the CPU count requested from Slurm.
mafft --thread "${SLURM_CPUS_PER_TASK}" sequences.fa > aligned.fa
# confirm all three input sequences are represented in the alignment.
test "$(grep -c '^>' aligned.fa)" -eq 3
# confirm a specific sequence label survived the alignment.
grep -q "seq3" aligned.fa
