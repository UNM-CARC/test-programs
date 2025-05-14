#!/bin/bash
#SBATCH --job-name=test-hpcg
#SBATCH --output=output.txt
#SBATCH --error=error.txt
#SBATCH --time=00:05:00
#SBATCH --mem=2G
#SBATCH --partition=debug
#SBATCH --nodes=2
#SBATCH --ntasks=64

module load hpcg
/usr/bin/time -v srun -n 64 xhpcg
