#!/bin/bash
#SBATCH --job-name=test-bowtie2
#SBATCH --output=output.txt
#SBATCH --error=error.txt
#SBATCH --time=00:05:00
#SBATCH --mem=2G
#SBATCH --partition=debug
#SBATCH --nodes=1
#SBATCH --ntasks=4

module load bowtie2
/usr/bin/time -v bowtie2-build test.fa test_index && srun -n 4 bowtie2 -x test_index -U reads.fq -p 4 -S alignment.sam
