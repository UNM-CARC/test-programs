#!/bin/bash -l
# Run this file with: sbatch slurm-test.slurm
# This script converts tiny PED/MAP data and computes allele frequencies.

# Slurm resources for this short threaded PLINK2 example.
#SBATCH --job-name=test-plink-ng
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
if [[ -f "$script_dir/plink-ng/Hopper/single-node/slurm-test.slurm" ]]; then
    script_dir="$script_dir/plink-ng/Hopper/single-node"
fi
if [[ -d "$script_dir/plink-ng/single-node" ]]; then
    script_dir="$script_dir/plink-ng/Hopper/single-node"
fi

# create a clean per-job output directory so runs do not collide.
run_dir="$script_dir/outputs/${SLURM_JOB_NAME}-${SLURM_JOB_ID}"
rm -rf "$run_dir"
mkdir -p "$run_dir"
cd "$run_dir"

# load PLINK2.
module --ignore-cache load plink-ng/v2.0.0-a.7.1

# write tiny PED genotype data.
cat > cohort.ped <<'EOF'
FAM1 IND1 0 0 1 1 A A C C G G
FAM1 IND2 0 0 2 1 A G C C G T
FAM2 IND3 0 0 1 2 G G C T T T
EOF
# write the matching MAP marker file.
cat > cohort.map <<'EOF'
1 rs1 0 100
1 rs2 0 200
1 rs3 0 300
EOF

# convert PED/MAP to binary PLINK format using Slurm CPU count.
plink2 --ped cohort.ped --map cohort.map --make-bed --out cohort --threads "${SLURM_CPUS_PER_TASK}"
# compute allele frequencies from the binary PLINK dataset.
plink2 --bfile cohort --freq --out cohort_freq --threads "${SLURM_CPUS_PER_TASK}"

# confirm binary PLINK output was created.
test -s cohort.bed
# confirm the expected marker appears in allele-frequency output.
grep -q "rs1" cohort_freq.afreq
