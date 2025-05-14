#!/bin/bash
#SBATCH --job-name=test-lammps
#SBATCH --output=output.txt
#SBATCH --error=error.txt
#SBATCH --time=00:05:00
#SBATCH --mem=2G
#SBATCH --partition=debug
#SBATCH --nodes=1
#SBATCH --ntasks=64

module load lammps
/usr/bin/time -v srun -n 64 lmp -in in.lj
