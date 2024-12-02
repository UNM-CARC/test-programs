#!/bin/bash

#SBATCH --job-name=prime_search_proj
#SBATCH --output=output.txt
#SBATCH --ntasks=16
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=8
#SBATCH --mem-per-cpu=5gb
#SBATCH --time=00:05:00
#SBATCH --mail-type=All
#SBATCH --mail-user=mfricke@hpc.unm.edu

module load openmpi3
prun sieve 100000000000
