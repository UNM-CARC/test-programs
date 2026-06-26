#!/usr/bin/env bash
# Run this file with: sbatch slurm-test.slurm
# This script demonstrates a VASP NaCl charge-analysis run.

# Slurm resources for a 4-rank VASP MPI example.
#SBATCH --job-name=test-vasp-nacl-luke
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err
#SBATCH --partition=debug
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=00:10:00

# fail fast on errors, unset variables, or failed pipeline commands.
set -euo pipefail

# locate this example directory when submitted from the repo root.
script_dir="${SLURM_SUBMIT_DIR:-$PWD}"
if [[ -f "$script_dir/vasp/Easley/NaCl_charges/LUKE/slurm-test.slurm" ]]; then
    script_dir="$script_dir/vasp/Easley/NaCl_charges/LUKE"
fi
if [[ -f "$script_dir/vasp/Easley/NaCl_charges/LUKE/slurm-test.slurm" ]]; then
    script_dir="$script_dir/vasp/Easley/NaCl_charges/LUKE"
fi

# reset modules and load VASP.
module purge
module load vasp/6.4.3

# create a clean per-job output directory so runs do not collide.
run_dir="$script_dir/outputs/${SLURM_JOB_NAME}-${SLURM_JOB_ID}"
rm -rf "$run_dir"
mkdir -p "$run_dir"
# copy VASP input files into the per-job run directory.
cp "$script_dir"/{INCAR,KPOINTS,POSCAR,POTCAR} "$run_dir"/
cd "$run_dir"

# launch VASP with one MPI rank per Slurm task using PMI2.
srun --mpi=pmi2 vasp_std > vasp.out

# Test checks: confirm VASP finished, reported free energy, and wrote charge files.
grep -q "General timing and accounting" OUTCAR
grep -q "FREE ENERGIE OF THE ION-ELECTRON SYSTEM" OUTCAR
test -s AECCAR0
test -s AECCAR2
test -s PROCAR
