#!/bin/bash
#SBATCH --job-name=test-bowtie
#SBATCH --output=output.txt
#SBATCH --error=error.txt
#SBATCH --time=00:02:00
#SBATCH --mem=1G
#SBATCH --ntasks=1
#SBATCH --partition=debug

module load bowtie
srun bowtie-build test.fa test_index
srun bowtie -q test_index reads.fq -S alignment.sam
