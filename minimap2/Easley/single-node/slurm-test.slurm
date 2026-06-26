#!/bin/bash -l
# Run this file with: sbatch slurm-test.slurm
# This script aligns synthetic long reads with minimap2.

# Slurm resources for this short threaded minimap2 example.
#SBATCH --job-name=test-minimap2
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
if [[ -f "$script_dir/minimap2/Easley/single-node/slurm-test.slurm" ]]; then
    script_dir="$script_dir/minimap2/Easley/single-node"
fi
if [[ -d "$script_dir/minimap2/single-node" ]]; then
    script_dir="$script_dir/minimap2/Easley/single-node"
fi

# create a clean per-job output directory so runs do not collide.
run_dir="$script_dir/outputs/${SLURM_JOB_NAME}-${SLURM_JOB_ID}"
rm -rf "$run_dir"
mkdir -p "$run_dir"
cd "$run_dir"

# load minimap2.
module --ignore-cache load minimap2/2.28-bmh2

# write a synthetic reference sequence.
cat > ref.fa <<'EOF'
>chr1
ACGTTGCAACGATCGTAGCTAGGCTAATCGGATCGATCGTTACGATCGTAGCTAGCTAGGATCCGATGCTAGCTTACGATCGATGCTAGCTAGGCTAACCGTTAACGATCGTAGCTAGGCTAATCGGATCGATCGTTACGATCGTAGCTAGCTAAGCTTGACCTGACTGATCGATGCTAGCTAACCGGTTAGCTAGCTAGGATCCGATGCTAGCTTACGATCGATGCTAGCTAGGCTA
EOF
# write synthetic query reads.
cat > query.fa <<'EOF'
>read1
GATCCGATGCTAGCTTACGATCGATGCTAGCTAGGCTAACCGTTAACGATCGTAGCTAGGCTAATCGGATCGATCGTTACGATCGTAGCTAGCTAAGCTTGACCTGACTGATCGATG
>read2
AACCGTTAACGATCGTAGCTAGGCTAATCGGATCGATCGTTACGATCGTAGCTAGCTAAGCTTGACCTGACTGATCGATGCTAGCTAACCGGTTAGCTAGCTAGGATCCGATGCTAG
EOF

# run minimap2 using the CPU count requested from Slurm.
minimap2 -t "${SLURM_CPUS_PER_TASK}" -x map-ont -k7 -w3 ref.fa query.fa > aln.paf
# confirm both reads produced alignments.
test "$(wc -l < aln.paf)" -eq 2
# confirm read1 appears in the PAF output.
grep -q "read1" aln.paf
