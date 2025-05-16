#!/bin/bash
#SBATCH --job-name=test-trimmomatic
#SBATCH --output=output.txt
#SBATCH --error=error.txt
#SBATCH --time=00:05:00
#SBATCH --mem=2G
#SBATCH --partition=debug
#SBATCH --nodes=1
#SBATCH --ntasks=2

cp /opt/spack/opt/spack/linux-sapphirerapids/trimmomatic-0.39-66mweo7ujulq25p5xz3oog6oabqt2hay/share/adapters/TruSeq3-SE.fa .

module load trimmomatic time
$(which time) -v srun -n 2 trimmomatic SE -threads 2 reads.fq trimmed.fq ILLUMINACLIP:TruSeq3-SE.fa:2:30:10
