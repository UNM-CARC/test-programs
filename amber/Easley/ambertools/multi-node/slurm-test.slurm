#!/bin/bash -l
# Run this file with: sbatch slurm-test.slurm
# This script demonstrates launching one AmberTools analysis per Slurm task.

# Give the job a recognizable scheduler name; all suite jobs begin with test-.
#SBATCH --job-name=test-ambertools-mpi
# Write standard output to a file named with the job name and Slurm job ID.
#SBATCH --output=%x-%j.out
# Write standard error to a matching file; this helps diagnose failed jobs.
#SBATCH --error=%x-%j.err
# Request two nodes to demonstrate a multi-node Slurm allocation.
#SBATCH --nodes=2
# Run two tasks per node, for four total cpptraj analyses.
#SBATCH --ntasks-per-node=2
# Reserve memory for the small trajectory analyses.
#SBATCH --mem=2G
# Keep the example short.
#SBATCH --time=00:05:00
# Use the debug partition because this is an instructional/regression test.
#SBATCH --partition=debug

# fail fast on errors, unset variables, or failed pipeline commands.
set -euo pipefail
# start from the directory where sbatch was submitted.
cd "${SLURM_SUBMIT_DIR:-$PWD}"
# locate this example directory when submitted from nearby paths.
if [[ -f ../multi-node/slurm-test.slurm ]]; then
    cd ../multi-node
elif [[ -f amber/ambertools/multi-node/slurm-test.slurm ]]; then
    cd amber/ambertools/multi-node
fi

data_dir="$(cd ../../../../amber/data && pwd)"
export data_dir

# reset modules and load AmberTools for cpptraj.
module purge
module load amber/ambertools/25

# label the parallel cpptraj command in the job log.
echo "=== Running one cpptraj analysis per Slurm task ==="

# write the cpptraj command file used by each Slurm task.
cat > cpptraj.in <<EOF
trajin $data_dir/TXM-wbions-prod6-r1.rst
rms first
EOF

# launch one shell per Slurm task. Each shell runs cpptraj and writes
# a rank-specific log file. SLURM_PROCID is the task/rank number assigned by Slurm.
# /usr/bin/time -v records aggregate resource use in the job log.
/usr/bin/time -v srun -n "${SLURM_NTASKS}" bash -lc \
 'rank="${SLURM_PROCID:-0}"; cpptraj -p "$data_dir/TXM-wbions.prmtop" -i cpptraj.in > "cpptraj-rank-${rank}.log"'

# leave a clear completion marker in the job log.
echo "AmberTools multi-node test completed."
