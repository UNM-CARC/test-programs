#!/usr/bin/bash
#SBATCH --job-name=BSONoSolv
#SBATCH --output=slurm_test_%x_%j.out
#SBATCH --error=slurm_test_%x_%j.err
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=64
#SBATCH --cpus-per-task=1
#SBATCH --mem=24GB
#SBATCH --time=48:00:00
#SBATCH --partition=general
#SBATCH --mail-user=xbarr@unm.edu
#SBATCH --mail-type=ALL

module load orca/6.1.0

# Orca needs the full path when running in parallel
# https://orca-manual.mpi-muelheim.mpg.de/contents/essentialelements/parallel.html
ORCA_BIN=$(which orca)
INPUT_FILE=$SLURM_SUBMIT_DIR/BpyPtBdt-ORCA61-opt.inp
SCRATCH_DIR=/carc/scratch/users/$USER/ORCA_$SLURM_JOB_ID

# Create scratch directory for the job
# mkdir -p $SCRATCH_DIR

# Copy input file to scratch directory
# cp $INPUT_FILE $SCRATCH_DIR/$(basename $INPUT_FILE)

# cd $SCRATCH_DIR

# Run Orca
$ORCA_BIN $(basename $INPUT_FILE)