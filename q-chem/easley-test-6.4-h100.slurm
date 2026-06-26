#!/usr/bin/env bash
# GPU Q-Chem H100 example.
# - Uses the q-chem/6.4-h100 module.
# - Enables the CUDA-enabled Q-Chem build on one H100 GPU.
# - Writes temporary files under QCSCRATCH/QCTMPDIR.
# - Makes MEM_TOTAL explicit via QCHEM_MEM_TOTAL_MB, defaulting to 8000 MB.

#SBATCH --job-name=qchem-6.4-h100
#SBATCH --output=%x-%j.out
#SBATCH --time=00:10:00
#SBATCH --partition=debug
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --gres=gpu:1
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=user@myemail.addr

set -euo pipefail

work_dir="${SLURM_SUBMIT_DIR}/run-6.4-h100-${SLURM_JOB_ID:-manual}"
scratch_dir="${work_dir}/scratch"
input_file="${SLURM_SUBMIT_DIR}/sos_ch2ch2_gpu.in"
output_file="${work_dir}/sos_ch2ch2_gpu.out"
qchem_mem_total_mb="${QCHEM_MEM_TOTAL_MB:-8000}"

module purge
module load q-chem/6.4-h100

# Users may override QCSCRATCH/QCTMPDIR before sbatch to point elsewhere.
export QCSCRATCH="${QCSCRATCH:-/easley/scratch/users/${USER}}"
export QCTMPDIR="${QCTMPDIR:-${QCSCRATCH}}"

# Create the working directory and the shared scratch root if needed.
mkdir -p "${scratch_dir}" "${QCSCRATCH}"
# Use a per-job .qchemrc so MEM_TOTAL is visible and easy to override.
printf '$rem\n MEM_TOTAL %s\n$end\n' "${qchem_mem_total_mb}" > "${work_dir}/.qchemrc"
export HOME="${work_dir}"
cd "${work_dir}"

qchem -gpu -nt "${SLURM_CPUS_PER_TASK}" "${input_file}" "${output_file}" "${scratch_dir}"
