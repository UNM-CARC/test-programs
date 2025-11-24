#!/usr/bin/bash
#SBATCH --job-name=orca_test
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
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
INPUT_FILE=$SLURM_SUBMIT_DIR/MsrP-4S-opt7.inp

# Run Orca
$ORCA_BIN $(basename $INPUT_FILE)
