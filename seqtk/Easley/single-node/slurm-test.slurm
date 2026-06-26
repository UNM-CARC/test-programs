#!/bin/bash -l
# Run this file with: sbatch slurm-test.slurm
# This script converts a tiny FASTQ file to FASTA with SeqTK.

# Slurm resources for this short SeqTK example.
#SBATCH --job-name=test-seqtk
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
if [[ -f "$script_dir/seqtk/Easley/single-node/slurm-test.slurm" ]]; then
    script_dir="$script_dir/seqtk/Easley/single-node"
fi
if [[ -d "$script_dir/seqtk/single-node" ]]; then
    script_dir="$script_dir/seqtk/Easley/single-node"
fi

# create a clean per-job output directory so runs do not collide.
run_dir="$script_dir/outputs/${SLURM_JOB_NAME}-${SLURM_JOB_ID}"
rm -rf "$run_dir"
mkdir -p "$run_dir"
cd "$run_dir"

# load SeqTK.
module --ignore-cache load seqtk/1.4-qhos

# write a tiny FASTQ input.
cat > reads.fq <<'EOF'
@read1
ACGTACGT
+
IIIIIIII
@read2
TTTTCCCC
+
HHHHHHHH
EOF

# convert FASTQ to FASTA.
seqtk seq -A reads.fq > reads.fa
# confirm both reads are present in FASTA output.
test "$(grep -c '^>' reads.fa)" -eq 2
# confirm read1 appears as a FASTA header.
grep -q ">read1" reads.fa
