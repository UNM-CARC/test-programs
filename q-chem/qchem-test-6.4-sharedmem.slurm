#!/usr/bin/env bash
# Shared-memory Q-Chem CPU example.
# - Uses the q-chem/6.4-cpu module.
# - Writes temporary files under QCSCRATCH/QCTMPDIR.
# - Makes MEM_TOTAL explicit via QCHEM_MEM_TOTAL_MB, defaulting to 8000 MB.

#SBATCH --job-name=qchem-6.4-shm
#SBATCH --output=%x-%j.out
#SBATCH --time=00:10:00
#SBATCH --partition=debug
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=user@myemail.addr

set -euo pipefail

work_dir="${SLURM_SUBMIT_DIR}/run-6.4-shm-${SLURM_JOB_ID:-manual}"
scratch_dir="${work_dir}/scratch"
input_file="${SLURM_SUBMIT_DIR}/water_b3lyp.in"
output_file="${work_dir}/water_b3lyp.out"
qchem_mem_total_mb="${QCHEM_MEM_TOTAL_MB:-8000}"

module purge
module load q-chem/6.4-cpu

# Users may override QCSCRATCH/QCTMPDIR before sbatch to point elsewhere.
export QCSCRATCH="${QCSCRATCH:-/carc/scratch/users/${USER}}"
export QCTMPDIR="${QCTMPDIR:-${QCSCRATCH}}"

# Create the working directory and the shared scratch root if needed.
mkdir -p "${scratch_dir}" "${QCSCRATCH}"
# Use a per-job .qchemrc so MEM_TOTAL is visible and easy to override.
printf '$rem\n MEM_TOTAL %s\n$end\n' "${qchem_mem_total_mb}" > "${work_dir}/.qchemrc"
export HOME="${work_dir}"
cd "${work_dir}"

qchem -nt "${SLURM_CPUS_PER_TASK}" "${input_file}" "${output_file}" "${scratch_dir}"
