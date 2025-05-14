#!/bin/bash
#SBATCH --job-name=test-fastqc
#SBATCH --output=output.txt
#SBATCH --error=error.txt
#SBATCH --time=00:05:00
#SBATCH --mem=2G
#SBATCH --partition=debug
#SBATCH --nodes=1
#SBATCH --ntasks=2

module load fastqc
/usr/bin/time -v srun -n 2 fastqc reads.fq
