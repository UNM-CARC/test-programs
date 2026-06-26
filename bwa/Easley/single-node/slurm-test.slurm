#!/bin/bash -l
# Run this file with: sbatch slurm-test.slurm
# This script builds a tiny BWA index and aligns synthetic reads.

# Slurm resources for this short threaded BWA example.
#SBATCH --job-name=test-bwa
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

# locate this example directory when submitted from the repo root
# or from inside bwa/single-node.
script_dir="${SLURM_SUBMIT_DIR:-$PWD}"
if [[ -f "$script_dir/bwa/Easley/single-node/slurm-test.slurm" ]]; then
    script_dir="$script_dir/bwa/Easley/single-node"
fi
if [[ -d "$script_dir/bwa/single-node" ]]; then
    script_dir="$script_dir/bwa/Easley/single-node"
fi

# create a clean per-job output directory so runs do not collide.
run_dir="$script_dir/outputs/${SLURM_JOB_NAME}-${SLURM_JOB_ID}"
rm -rf "$run_dir"
mkdir -p "$run_dir"
cd "$run_dir"

# load BWA.
module --ignore-cache load bwa/0.7.17-zvtr

# write a tiny reference FASTA for this self-contained test.
cat > ref.fa <<'EOF'
>chr1
ACGTACGTACGTACGTACGTACGTACGTACGTACGTACGT
EOF
# write two tiny reads that should align to the reference.
cat > reads.fq <<'EOF'
@read1
ACGTACGTACGT
+
IIIIIIIIIIII
@read2
TACGTACGTACG
+
IIIIIIIIIIII
EOF

# build the BWA index.
bwa index ref.fa
# align reads using the CPU count requested from Slurm.
bwa mem -t "${SLURM_CPUS_PER_TASK}" ref.fa reads.fq > aln.sam
# confirm two non-header SAM records were produced.
test "$(grep -vc '^@' aln.sam)" -eq 2
# confirm read1 appears in the alignment output.
grep -q "read1" aln.sam
