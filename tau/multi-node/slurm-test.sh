#!/bin/bash
#SBATCH --job-name=test-tau
#SBATCH --output=output.txt
#SBATCH --error=error.txt
#SBATCH --time=00:05:00
#SBATCH --mem=2G
#SBATCH --partition=debug
#SBATCH --nodes=2
#SBATCH --ntasks=8

module load tau
/usr/bin/time -v srun -n 8 ./hello
