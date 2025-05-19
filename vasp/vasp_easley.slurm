#!/bin/bash
# Sample Vasp Job Submission Script
# Matthew Fricke, May 20th, 2025
#SBATCH --job-name=vasp_sample
#SBATCH --output=vasp_sample_easley.out
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=64
#SBATCH --mail-user=yourusername@unm.edu
#SBATCH --mail-type=ALL
#SBATCH --partition=debug
#SBATCH --time=1:00:00

module load vasp/6.4.3
srun --mpi=pmi2 vasp_std


