#!/bin/bash -l
# Run this file with: sbatch slurm-test.slurm
# This script demonstrates a single-node MPI LAMMPS run.

# Slurm resources for a four-rank single-node LAMMPS example.
#SBATCH --job-name=test-lammps
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err
#SBATCH --time=00:05:00
#SBATCH --mem=2G
#SBATCH --partition=debug
#SBATCH --nodes=1
#SBATCH --ntasks=4

# fail fast on errors, unset variables, or failed pipeline commands.
set -euo pipefail
# locate this example directory when submitted from the repo root.
cd "${SLURM_SUBMIT_DIR:-$PWD}"
if [[ ! -f in.lj && -f lammps/single-node/in.lj ]]; then
    cd lammps/single-node
fi

# load MPI, FFTW, and LAMMPS.
module load openmpi/4.1.7-3ilj fftw/3.3.10-wfyy lammps/20250722-57pz
# CARC module files record application library paths separately from the
# dynamic linker path used by batch-launched MPI ranks.
# expose required shared libraries to MPI-launched LAMMPS ranks.
export LD_LIBRARY_PATH="${FFTW_LIB}:${CARC_LIBRARY_PATH}:${LD_LIBRARY_PATH:-}"
# launch LAMMPS with one MPI rank per Slurm task.
# /usr/bin/time -v records resource use in the job log.
/usr/bin/time -v srun -n "${SLURM_NTASKS}" lmp -in in.lj
