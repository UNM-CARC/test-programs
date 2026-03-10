#!/bin/bash
#SBATCH --job-name=test-lammps
#SBATCH --time=00:05:00
#SBATCH --partition=debug
#SBATCH --ntasks=64
#SBATCH --cpus-per-task=1
#SBATCH --nodes=1
#SBATCH --mem=248G

module purge
module load openmpi/4.1.7-3ilj
module load fftw
module load lammps

# Expose OpenMP thread count explicitly
export OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK}
export LD_LIBRARY_PATH=${FFTW_LIB}:${LD_LIBRARY_PATH}

echo "MPI ranks: $SLURM_NTASKS"
echo "CPUs per task: $SLURM_CPUS_PER_TASK"
echo "OMP threads: $OMP_NUM_THREADS"

srun lmp -in in.lj
