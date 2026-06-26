#!/bin/bash -l
# Run this file with: sbatch slurm-test.slurm
# This script runs FASTX-Toolkit quality statistics and FASTQ-to-FASTA conversion.

# Slurm resources for this short serial FASTX-Toolkit example.
#SBATCH --job-name=test-fastx-toolkit
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

# locate this example directory when submitted from the repo root
# or from inside fastx-toolkit/single-node.
script_dir="${SLURM_SUBMIT_DIR:-$PWD}"
if [[ -f "$script_dir/fastx-toolkit/Hopper/single-node/slurm-test.slurm" ]]; then
    script_dir="$script_dir/fastx-toolkit/Hopper/single-node"
fi
if [[ -d "$script_dir/fastx-toolkit/single-node" ]]; then
    script_dir="$script_dir/fastx-toolkit/Hopper/single-node"
fi

# create a clean per-job output directory so runs do not collide.
run_dir="$script_dir/outputs/${SLURM_JOB_NAME}-${SLURM_JOB_ID}"
rm -rf "$run_dir"
mkdir -p "$run_dir"
cd "$run_dir"

# load FASTX-Toolkit.
module --ignore-cache load fastx-toolkit/0.0.14-36g4

# write a tiny FASTQ input file.
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

# compute per-base quality statistics.
fastx_quality_stats -i reads.fq -o quality.tsv
# convert FASTQ reads to FASTA.
fastq_to_fasta -i reads.fq -o reads.fa
# confirm both reads were converted to FASTA.
test "$(grep -c '^>' reads.fa)" -eq 2
# confirm the statistics table has its expected header.
grep -q "^column" quality.tsv
