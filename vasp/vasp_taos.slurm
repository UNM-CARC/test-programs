#!/bin/bash
# Sample Vasp Job Submission Script
# Matthew Fricke, October 26th, 2020
#SBATCH --job-name=vasp_sample
#SBATCH --output=vasp_sample_taos.out
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=64
#SBATCH --mail-user=mfricke@unm.edu
#SBATCH --mail-type=ALL
#SBATCH --partition=community
#SBATCH --time=1:00:00

module load vasp/intel/19.0.5/6.1.0
mpirun -bootstrap slurm vasp_std

