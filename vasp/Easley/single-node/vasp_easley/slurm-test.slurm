#!/bin/bash
# Sample Vasp Job Submission Script
# Matthew Fricke, May 20th, 2025
# Run this file with: sbatch slurm-test.slurm
# This script demonstrates a two-node VASP MPI run on the debug partition.

# Slurm resources for a larger VASP MPI example.  Thirty-two MPI ranks per
# node fits Hopper debug's 32 CPU cores per node while still running correctly
# on Easley debug nodes.
#SBATCH --job-name=test-vasp
#SBATCH --output=vasp_sample_easley.out
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=32
#SBATCH --mail-user=yourusername@unm.edu
#SBATCH --mail-type=ALL
#SBATCH --partition=debug
#SBATCH --time=1:00:00

# load VASP.
module load vasp/6.4.3
# launch VASP with one MPI rank per Slurm task using PMI2.
srun --mpi=pmi2 vasp_std
