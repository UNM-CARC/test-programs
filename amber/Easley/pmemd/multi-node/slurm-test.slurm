#!/bin/bash -l
# Run this file with: sbatch slurm-test.slurm
# This script demonstrates PMEMD.MPI across two nodes.

# Give the job a recognizable scheduler name; all suite jobs begin with test-.
#SBATCH --job-name=test-pmemd-multinode
# Write standard output to a file named with the job name and Slurm job ID.
#SBATCH --output=%x-%j.out
# Write standard error to a matching file; this helps diagnose failed jobs.
#SBATCH --error=%x-%j.err
# Request two nodes for distributed-memory MPI.
#SBATCH --nodes=2
# Run two MPI ranks on each node.
#SBATCH --ntasks-per-node=2
# Reserve memory for the small molecular dynamics system.
#SBATCH --mem=2G
# Allow enough time for the short PMEMD molecular dynamics run.
#SBATCH --time=00:10:00
# Use the debug partition because this is an instructional/regression test.
#SBATCH --partition=debug

# fail fast on errors, unset variables, or failed pipeline commands.
set -euo pipefail
# locate this example directory when submitted from the repo root
# or from inside amber/pmemd/multi-node.
script_dir="${SLURM_SUBMIT_DIR:-$PWD}"
if [[ -f "$script_dir/amber/Easley/pmemd/multi-node/slurm-test.slurm" ]]; then
    script_dir="$script_dir/amber/Easley/pmemd/multi-node"
fi
if [[ -f "$script_dir/amber/Easley/pmemd/multi-node/slurm-test.slurm" ]]; then
    script_dir="$script_dir/amber/Easley/pmemd/multi-node"
fi
data_dir="$(cd "$script_dir/../../../../amber/data" && pwd)"
# create a clean per-job output directory so runs do not collide.
run_dir="$script_dir/outputs/${SLURM_JOB_NAME}-${SLURM_JOB_ID}"
# remove any stale directory with the same job-derived name.
rm -rf "$run_dir"
# create the output directory.
mkdir -p "$run_dir"
# run PMEMD from the per-job directory so outputs stay contained.
cd "$run_dir"

# reset modules and load AmberTools plus the CPU MPI PMEMD build.
module purge
module load amber/ambertools/25
module load amber/pmemd/cpu/24

# label the PMEMD command in the job log.
echo "=== Running PMEMD.MPI across multiple nodes ==="

# NOTE:
# PMEMD uses MPI for distributed-memory parallelism.
# This test uses 2 nodes with 4 MPI ranks each (total of 8).
# PMEMD does not use OpenMP — no threading is involved here.
# write a short PMEMD input file for the regression run.
cat > test-pmemd.in <<'EOF'
TX Motif short PMEMD multi-node regression run
 &cntrl
  imin=0, irest=1, ntx=5,
  ntb=2, iwrap=1, pres0=1.0, ntp=1, taup=2.0,
  cut=12.0, ntr=0, ntc=2, ntf=2,
  tempi=300.0, temp0=300.0, ntt=3, gamma_ln=5.0, ig=-1,
  nstlim=1000, dt=0.002,
  ntpr=500, ntwx=1000, ntwr=1000,
  ioutfm=0
 /
EOF

# launch PMEMD.MPI with one rank per Slurm task.
# /usr/bin/time -v records resource use in the job log.
/usr/bin/time -v srun -n "${SLURM_NTASKS}" pmemd.MPI -O \
 -i test-pmemd.in \
 -o prod6.out \
 -p "$data_dir/TXM-wbions.prmtop" \
 -c "$data_dir/TXM-wbions-prod5-r1.rst" \
 -r prod6.rst \
 -x prod6.nc

# confirm the run reached the requested final MD step.
grep -q "NSTEP =     1000" prod6.out
# leave a clear completion marker in the job log.
echo "PMEMD multi-node test completed."
