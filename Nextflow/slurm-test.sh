#!/bin/bash

#SBATCH --job-name nxf_rnaseq 
#SBATCH --output slurm-%j.out
#SBATCH --error slurm-%j.error
#SBATCH --time 00:20:00
#SBATCH --partition=general
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=32G

module load gcc apptainer openjdk nextflow

nextflow pull nf-core/rnaseq
nextflow run nf-core/rnaseq -c ./nextflow.config -profile test,singularity --outdir results
