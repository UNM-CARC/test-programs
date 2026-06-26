#!/usr/bin/env bash
# MPI Q-Chem CPU example using the documented 4-water MBE input.
# - Uses the q-chem/6.4-cpu module.
# - Uses Slurm-launched MPI ranks plus OpenMP threads within each rank.
# - Keeps QCSCRATCH on shared storage and QCLOCALSCR on node-local /tmp.
# - Makes MEM_TOTAL explicit via QCHEM_MEM_TOTAL_MB, defaulting to 8000 MB.
# - Treats the run as successful if Q-Chem reaches its normal success footer,
#   even if the MPI launcher returns a nonzero shell status on this system.

#SBATCH --job-name=qchem-6.4-mpi
#SBATCH --output=%x-%j.out
#SBATCH --time=00:10:00
#SBATCH --partition=debug
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=user@myemail.addr

set -euo pipefail

work_dir="${SLURM_SUBMIT_DIR}/run-6.4-mpi-${SLURM_JOB_ID:-manual}"
input_file="${SLURM_SUBMIT_DIR}/mbe_bsse_4water_mpi.in"
output_file="${work_dir}/mbe_bsse_4water_mpi.out"
qchem_run_name="run-6.4-mpi-${SLURM_JOB_ID:-manual}"
qchem_mem_total_mb="${QCHEM_MEM_TOTAL_MB:-8000}"

module purge
module load q-chem/6.4-cpu

export QCMPI=slurm
export QCMPIRUN=srun
# Shared scratch is where saved files are collected after a successful run.
export QCSCRATCH="${QCSCRATCH:-/carc/scratch/users/${USER}}"
# Local scratch reduces shared-file contention during MPI execution.
export QCLOCALSCR="${QCLOCALSCR:-/tmp/qchem-${USER}-${SLURM_JOB_ID}}"
unset QCTMPDIR

# Create the shared work area and the shared scratch root.
mkdir -p "${work_dir}" "${QCSCRATCH}"
# Ensure the node-local scratch root exists on each allocated node.
srun -N "${SLURM_JOB_NUM_NODES}" -n "${SLURM_JOB_NUM_NODES}" mkdir -p "${QCLOCALSCR}"
# Use a per-job .qchemrc so MEM_TOTAL is visible and easy to override.
printf '$rem\n MEM_TOTAL %s\n$end\n' "${qchem_mem_total_mb}" > "${work_dir}/.qchemrc"
export HOME="${work_dir}"
cd "${work_dir}"

# Pass a simple run name as the third qchem argument; the wrapper treats this
# as the save/run identifier and derives rank-specific scratch paths from it.
set +e
qchem -mpi -np "${SLURM_NTASKS}" -nt "${SLURM_CPUS_PER_TASK}" \
  "${input_file}" "${output_file}" "${qchem_run_name}"
qchem_rc=$?
set -e

# Q-Chem can finish successfully while the Slurm MPI launcher still reports a
# nonzero shell status. If the normal closing footer is present, treat that as
# a successful end-user run.
if [[ "${qchem_rc}" -ne 0 ]] && grep -q "Thank you very much for using Q-Chem" "${output_file}"; then
  echo "Q-Chem completed successfully despite launcher exit code ${qchem_rc}; treating run as successful."
  qchem_rc=0
fi

exit "${qchem_rc}"
