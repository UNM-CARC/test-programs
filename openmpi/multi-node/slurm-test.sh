#!/bin/bash

#SBATCH --job-name=prime_search
#SBATCH --output=output.txt
#SBATCH --ntasks=16
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=8
#SBATCH --mem=5gb
#SBATCH --time=00:05:00

module load openmpi

srun ./sieve 100000000000
