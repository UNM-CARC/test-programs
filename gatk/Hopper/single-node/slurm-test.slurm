#!/bin/bash -l
# Run this file with: sbatch slurm-test.slurm
# This script runs a tiny GATK SelectVariants filter example.

# Slurm resources for this short GATK example.
#SBATCH --job-name=test-gatk
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err
#SBATCH --partition=debug
#SBATCH --time=00:05:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=4G

# fail fast on errors, unset variables, or failed pipeline commands.
set -euo pipefail

# locate this example directory when submitted from the repo root
# or from inside gatk/single-node.
script_dir="${SLURM_SUBMIT_DIR:-$PWD}"
if [[ -f "$script_dir/gatk/Hopper/single-node/slurm-test.slurm" ]]; then
    script_dir="$script_dir/gatk/Hopper/single-node"
fi
if [[ -d "$script_dir/gatk/single-node" ]]; then
    script_dir="$script_dir/gatk/Hopper/single-node"
fi

# create a clean per-job output directory so runs do not collide.
run_dir="$script_dir/outputs/${SLURM_JOB_NAME}-${SLURM_JOB_ID}"
rm -rf "$run_dir"
mkdir -p "$run_dir"
cd "$run_dir"

# load GATK.
module --ignore-cache load gatk/4.5.0.0-ukon

# write a tiny VCF with one passing and one filtered variant.
cat > variants.vcf <<'EOF'
##fileformat=VCFv4.2
##contig=<ID=chr1,length=1000>
##FORMAT=<ID=GT,Number=1,Type=String,Description="Genotype">
#CHROM	POS	ID	REF	ALT	QUAL	FILTER	INFO	FORMAT	sample1
chr1	10	.	A	G	50	PASS	.	GT	0/1
chr1	20	.	C	T	10	q10	.	GT	0/1
EOF

# select only unfiltered variants from the test VCF.
gatk SelectVariants \
    -V variants.vcf \
    --exclude-filtered true \
    -O pass_variants.vcf

# confirm the PASS variant remains.
grep -q $'chr1\t10' pass_variants.vcf
# confirm the filtered variant was removed.
! grep -q $'chr1\t20' pass_variants.vcf
