#!/bin/bash
#SBATCH --job-name=test-petsc
#SBATCH --output=output.txt
#SBATCH --error=error.txt
#SBATCH --time=00:05:00
#SBATCH --mem=2G
#SBATCH --partition=debug
#SBATCH --nodes=2
#SBATCH --ntasks=8

module load petsc

# Assumes ex19 was included in the module
/usr/bin/time -v srun -n 8 ex19 -snes_monitor
