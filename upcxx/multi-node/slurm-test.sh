#!/bin/bash
#SBATCH --job-name=test-upcxx
#SBATCH --output=output.txt
#SBATCH --error=error.txt
#SBATCH --time=00:05:00
#SBATCH --mem=2G
#SBATCH --partition=debug
#SBATCH --nodes=2
#SBATCH --ntasks=4

module load upcxx
/usr/bin/time -v srun ./hello
