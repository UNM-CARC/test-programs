#!/bin/bash

#SBATCH --job-name=slurm_test
#SBATCH --output=output.txt
#SBATCH --nodes=4
#SBATCH --time=24:00:00
prun $HOME/mpitest/sieve 100000000
