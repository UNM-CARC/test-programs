#!/bin/bash -l
# Run this file with: sbatch slurm-test.slurm
# This script runs SeqKit stats and read selection on a tiny FASTQ file.

# Slurm resources for this short SeqKit example.
#SBATCH --job-name=test-seqkit
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
if [[ -f "$script_dir/seqkit/Hopper/single-node/slurm-test.slurm" ]]; then
    script_dir="$script_dir/seqkit/Hopper/single-node"
fi
if [[ -d "$script_dir/seqkit/single-node" ]]; then
    script_dir="$script_dir/seqkit/Hopper/single-node"
fi

# create a clean per-job output directory so runs do not collide.
run_dir="$script_dir/outputs/${SLURM_JOB_NAME}-${SLURM_JOB_ID}"
rm -rf "$run_dir"
mkdir -p "$run_dir"
cd "$run_dir"

# load SeqKit.
module --ignore-cache load seqkit/2.8.2-tp5s

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

# summarize the FASTQ file.
seqkit stats reads.fq > stats.tsv
# select read2 into a separate FASTQ file.
seqkit grep -p read2 reads.fq > read2.fq
# confirm read2 was selected.
grep -q "read2" read2.fq
# confirm the stats output references the input file.
grep -q "reads.fq" stats.tsv
