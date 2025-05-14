#!/bin/bash
#SBATCH --job-name=test-ior
#SBATCH --output=output.txt
#SBATCH --error=error.txt
#SBATCH --time=00:05:00
#SBATCH --mem=2G
#SBATCH --partition=debug
#SBATCH --nodes=2
#SBATCH --ntasks=32

module load ior
/usr/bin/time -v srun -n 32 ior -w -r -o testfile
