#!/bin/bash -l
# Run this file with: sbatch slurm-test.slurm
# This script creates a Picard sequence dictionary for a tiny reference.

# Slurm resources for this short Picard example.
#SBATCH --job-name=test-picard
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err
#SBATCH --partition=debug
#SBATCH --time=00:05:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=2G

# fail fast on errors, unset variables, or failed pipeline commands.
set -euo pipefail

# locate this example directory when submitted from the repo root.
script_dir="${SLURM_SUBMIT_DIR:-$PWD}"
if [[ -f "$script_dir/picard/Easley/single-node/slurm-test.slurm" ]]; then
    script_dir="$script_dir/picard/Easley/single-node"
fi
if [[ -d "$script_dir/picard/single-node" ]]; then
    script_dir="$script_dir/picard/Easley/single-node"
fi

# create a clean per-job output directory so runs do not collide.
run_dir="$script_dir/outputs/${SLURM_JOB_NAME}-${SLURM_JOB_ID}"
rm -rf "$run_dir"
mkdir -p "$run_dir"
cd "$run_dir"

# load Picard.
module --ignore-cache load picard/3.1.1-lsaf

# write a tiny reference FASTA.
cat > reference.fa <<'EOF'
>chr1
ACGTTGCAACGATCGTAGCTAGGCTAATCGGATCGATCGTTACGATCGTAGCTAGCTA
EOF

# create a Picard sequence dictionary.
picard CreateSequenceDictionary \
    R=reference.fa \
    O=reference.dict

# confirm the dictionary contains the expected contig.
grep -q "SN:chr1" reference.dict
