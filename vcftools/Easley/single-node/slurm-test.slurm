#!/bin/bash -l
# Run this file with: sbatch slurm-test.slurm
# This script filters a tiny VCF file with VCFtools.

# Slurm resources for this short VCFtools example.
#SBATCH --job-name=test-vcftools
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
if [[ -f "$script_dir/vcftools/Easley/single-node/slurm-test.slurm" ]]; then
    script_dir="$script_dir/vcftools/Easley/single-node"
fi
if [[ -d "$script_dir/vcftools/single-node" ]]; then
    script_dir="$script_dir/vcftools/Easley/single-node"
fi

# create a clean per-job output directory so runs do not collide.
run_dir="$script_dir/outputs/${SLURM_JOB_NAME}-${SLURM_JOB_ID}"
rm -rf "$run_dir"
mkdir -p "$run_dir"
cd "$run_dir"

# load VCFtools.
module --ignore-cache load vcftools/0.1.16-a6ey

# write a tiny VCF with two PASS records and one filtered record.
cat > variants.vcf <<'EOF'
##fileformat=VCFv4.2
##FORMAT=<ID=GT,Number=1,Type=String,Description="Genotype">
#CHROM	POS	ID	REF	ALT	QUAL	FILTER	INFO	FORMAT	sample1	sample2
chr1	10	rs1	A	G	60	PASS	.	GT	0/1	0/0
chr1	20	rs2	C	T	10	q10	.	GT	1/1	0/1
chr1	30	rs3	G	A	99	PASS	.	GT	0/0	0/1
EOF

# remove filtered variants and recode the VCF.
vcftools --vcf variants.vcf --remove-filtered-all --recode --out pass_only
# confirm the recoded VCF exists and is nonempty.
test -s pass_only.recode.vcf
# confirm only the two PASS variants remain.
test "$(grep -vc '^#' pass_only.recode.vcf)" -eq 2
