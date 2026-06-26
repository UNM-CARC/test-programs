#!/bin/bash -l
# Run this file with: sbatch slurm-test.slurm
# This script demonstrates PMEMD.CUDA on one GPU.

# Give the job a recognizable scheduler name; all suite jobs begin with test-.
#SBATCH --job-name=test-pmemd-cuda
# Write standard output to a file named with the job name and Slurm job ID.
#SBATCH --output=%x-%j.out
# Write standard error to a matching file; this helps diagnose failed jobs.
#SBATCH --error=%x-%j.err
# Allow enough time for the GPU PMEMD smoke test.
#SBATCH --time=00:10:00
# Request one Slurm task because pmemd.cuda itself controls the GPU work.
#SBATCH --ntasks=1
# Request one GPU for pmemd.cuda.
#SBATCH --gres=gpu:1
# Reserve memory for the small molecular dynamics system.
#SBATCH --mem=2G
# Use the debug partition because this is an instructional/regression test.
#SBATCH --partition=debug

# fail fast on errors, unset variables, or failed pipeline commands.
set -euo pipefail
# locate this example directory when submitted from the repo root
# or from inside amber/gpu/pmemd.
script_dir="${SLURM_SUBMIT_DIR:-$PWD}"
if [[ -f "$script_dir/amber/Hopper/gpu/pmemd/slurm-test.slurm" ]]; then
    script_dir="$script_dir/amber/Hopper/gpu/pmemd"
fi
if [[ -f "$script_dir/amber/Hopper/gpu/pmemd/slurm-test.slurm" ]]; then
    script_dir="$script_dir/amber/Hopper/gpu/pmemd"
fi
# create a clean per-job output directory so runs do not collide.
run_dir="$script_dir/outputs/${SLURM_JOB_NAME}-${SLURM_JOB_ID}"
# remove any stale directory with the same job-derived name.
rm -rf "$run_dir"
# create the output directory.
mkdir -p "$run_dir"
# run PMEMD from the per-job directory so outputs stay contained.
cd "$run_dir"

# reset modules and load AmberTools, GPU PMEMD, and CUDA runtime.
module purge
module load amber/ambertools/25
module load amber/pmemd/cuda/24
module load cuda/12.8.0-dh6b

# label the PMEMD CUDA command in the job log.
echo "=== Running PMEMD.CUDA on a single GPU ==="

# NOTE:
# pmemd.cuda runs entirely on a single GPU.
# No MPI or OpenMP is used unless you specifically run pmemd.cuda.MPI with MPI support.
# write a short PMEMD input file for the regression run.
cat > test-pmemd.in <<'EOF'
TX Motif short PMEMD CUDA regression run
 &cntrl
  imin=0, irest=1, ntx=5,
  ntb=2, iwrap=1, pres0=1.0, ntp=1, taup=2.0,
  cut=12.0, ntr=0, ntc=2, ntf=2,
  tempi=300.0, temp0=300.0, ntt=3, gamma_ln=5.0, ig=-1,
  nstlim=10000, dt=0.002,
  ntpr=5000, ntwx=10000, ntwr=10000,
  ioutfm=0
 /
EOF

# launch pmemd.cuda through srun so Slurm tracks GPU job execution.
# /usr/bin/time -v records resource use in the job log.
/usr/bin/time -v srun pmemd.cuda -O \
 -i test-pmemd.in \
 -o prod.out \
 -p "$script_dir/../../data/TXM-wbions.prmtop" \
 -c "$script_dir/../../data/TXM-wbions-eqmd2.rst" \
 -r prod.rst \
 -x prod.nc

# confirm the run reached the requested final MD step.
grep -q "NSTEP =    10000" prod.out
# leave a clear completion marker in the job log.
echo "PMEMD CUDA GPU test completed."
