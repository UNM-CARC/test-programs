#!/bin/bash
#SBATCH --job-name=test-bowtie
#SBATCH --output=output.txt
#SBATCH --error=error.txt
#SBATCH --time=00:02:00
#SBATCH --mem=1G
#SBATCH --partition=debug

module load bowtie
bowtie-build test.fa test_index
bowtie -q test_index reads.fq -S alignment.sam
