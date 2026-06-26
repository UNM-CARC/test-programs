#!/bin/bash -l
# Run this file with: sbatch slurm-test.slurm
# This script builds a tiny RSEM reference.

# Slurm resources for this short RSEM example.
#SBATCH --job-name=test-rsem
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
if [[ -f "$script_dir/rsem/Easley/single-node/slurm-test.slurm" ]]; then
    script_dir="$script_dir/rsem/Easley/single-node"
fi
if [[ -d "$script_dir/rsem/single-node" ]]; then
    script_dir="$script_dir/rsem/Easley/single-node"
fi

# create a clean per-job output directory so runs do not collide.
run_dir="$script_dir/outputs/${SLURM_JOB_NAME}-${SLURM_JOB_ID}"
rm -rf "$run_dir"
mkdir -p "$run_dir"
cd "$run_dir"

# load RSEM.
module --ignore-cache load rsem/1.3.3-fdfy

# write a tiny transcript FASTA.
cat > transcripts.fa <<'EOF'
>tx1
ACGTTGCAACGATCGTAGCTAGGCTAATCGGATCGATCGTTACGATCGTAGCTAGCTA
>tx2
TTGCAACGATCGTAGCTAGGCTAATCGGATCGATCGTTACGATCGTAGCTAGCTAACG
EOF

# prepare an RSEM reference from the transcript FASTA.
rsem-prepare-reference transcripts.fa test_reference

# confirm expected RSEM reference metadata files were created.
test -s test_reference.grp
test -s test_reference.ti
