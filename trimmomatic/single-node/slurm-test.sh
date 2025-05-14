#!/bin/bash
#SBATCH --job-name=test-trimmomatic
#SBATCH --output=output.txt
#SBATCH --error=error.txt
#SBATCH --time=00:05:00
#SBATCH --mem=2G
#SBATCH --partition=debug
#SBATCH --nodes=1
#SBATCH --ntasks=2

module load trimmomatic
/usr/bin/time -v srun -n 2 trimmomatic SE -threads 2 reads.fq trimmed.fq ILLUMINACLIP:TruSeq3-SE.fa:2:30:10
