#!/bin/bash -l
# Run this file with: sbatch slurm-test.slurm
# This script demonstrates a two-node MPI PMEMD run.

# Give the job a recognizable scheduler name; all suite jobs begin with test-.
#SBATCH --job-name=test-amber-pmemd
# Write standard output to a file named with the job name and Slurm job ID.
#SBATCH --output=%x-%j.out
# Write standard error to a matching file; this helps diagnose failed jobs.
#SBATCH --error=%x-%j.err
# Use the debug partition because this is an instructional/regression test.
#SBATCH --partition=debug
# Allow enough time for the short PMEMD molecular dynamics run.
#SBATCH --time=00:10:00
# Request two nodes for distributed-memory MPI.
#SBATCH --nodes=2
# Run two MPI ranks on each node.
#SBATCH --ntasks-per-node=2
# Reserve memory for the small molecular dynamics system.
#SBATCH --mem=4G

# fail fast on errors, unset variables, or failed pipeline commands.
set -euo pipefail
# locate the Amber directory when submitted from the repo root or
# from inside amber/.
script_dir="${SLURM_SUBMIT_DIR:-$PWD}"
if [[ -f "$script_dir/amber/Hopper/single-node/gibbs/slurm-test.slurm" ]]; then
    script_dir="$script_dir/amber/Hopper/single-node/gibbs"
fi
if [[ -f "$script_dir/amber/gibbs.slurm" ]]; then
    script_dir="$script_dir/amber/Hopper/single-node/gibbs"
fi

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

# write a short PMEMD input file for the regression run.
cat > test-pmemd.in <<'EOF'
TX Motif short PMEMD regression run
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
srun -n "${SLURM_NTASKS}" pmemd.MPI -O \
    -i test-pmemd.in \
    -o prod.out \
    -p "$script_dir/data/TXM-wbions.prmtop" \
    -c "$script_dir/data/TXM-wbions-prod5-r1.rst" \
    -r prod.rst \
    -x prod.nc

# confirm the run reached the requested final MD step.
grep -q "NSTEP =     1000" prod.out
