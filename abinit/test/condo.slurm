#!/bin/bash
#SBATCH --partition condo
#SBATCH -n 8 # number of processors to allocate
#SBATCH --mail-user mfricke@unm.edu
#SBATCH --mail-type all
#SBATCH --job-name abinit

module purge # make sure there are no lingering loaded modules, JIC
# load module for Hopper
module load intel abinit/9.6.1-qrve

# the input file to use for the run
export INPUTFILE=t41.in # XXX FIXME! XXX

srun --mpi=pmi2 -n $SLURM_NTASKS abinit $INPUTFILE
