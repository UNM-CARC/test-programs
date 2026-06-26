#!/usr/bin/env bash
#SBATCH --job-name=gmx-2026-hbyz
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

ff_root="${SLURM_SUBMIT_DIR}/forcefields"
ff_name="charmm36-feb2026_cgenff-5.0"
work_dir="${SLURM_SUBMIT_DIR}/run-2026.0-cuda-hbyz-${SLURM_JOB_ID:-manual}"

if [[ ! -d "${ff_root}/${ff_name}.ff" ]]; then
    echo "Missing force field directory: ${ff_root}/${ff_name}.ff" >&2
    exit 1
fi

module purge
module load openmpi/4.1.7-e7k3 fftw/3.3.10-qtxc >/dev/null 2>&1
: "${LD_LIBRARY_PATH:=}"
export LD_LIBRARY_PATH=$FFTW_LIB:$LD_LIBRARY_PATH
module load gcc/14.2.0-a75l openmpi/4.1.7-cuda-3ww6 gromacs/2026.0-cuda-hbyz
export GMXLIB="${ff_root}"

mkdir -p "${work_dir}"
cd "${work_dir}"

# Show the installed GROMACS build.
gmx_mpi --version

# Build a topology from the test peptide.
gmx_mpi pdb2gmx \
    -f "${SLURM_SUBMIT_DIR}/minimal_peptide.pdb" \
    -o processed.gro \
    -p topol.top \
    -i posre.itp \
    -ff "${ff_name}" \
    -water tip3p \
    -ignh

# Create a padded simulation box.
gmx_mpi editconf \
    -f processed.gro \
    -o boxed.gro \
    -c \
    -d 1.5 \
    -bt cubic

# Assemble the minimization input.
gmx_mpi grompp \
    -f "${SLURM_SUBMIT_DIR}/minim.mdp" \
    -c boxed.gro \
    -p topol.top \
    -o em.tpr \
    -maxwarn 0

# Run a short minimization on one debug GPU.
srun -N 1 -n 1 gmx_mpi mdrun \
    -deffnm em \
    -ntomp "${SLURM_CPUS_PER_TASK}" \
    -nb gpu
