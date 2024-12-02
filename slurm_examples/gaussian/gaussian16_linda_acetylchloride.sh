#!/bin/bash

#SBATCH --nodes=2
#SBATCH --ntasks-per-node=4
#SBATCH --time=00:10:00
#SBATCH --job-name=g16_acetylchloride
#SBATCH --mail-user yourusername@unm.edu

module load gaussian/g16

# To make linda print verbose messages
export GAUSS_LFLAGS="-v"

INPUT_MOLECULE=$SLURM_SUBMIT_DIR/AcetylChloride.com
OUTPUT_FILE=$SLURM_SUBMIT_DIR/AcetyleChloride.log

# Reformat the SLURM provided list of compute nodes to a format Gaussian can understand
# i.e. remove duplicates and replace newlines with commas
export GAUSS_WDEF=$(cat $CARC_NODEFILE | uniq | sed -z 's/\n/,/g;s/,$/\n/')

# Tell Linda to use as many nodes as requested by the user
export GAUSS_PDEF=$SLURM_JOB_NUM_NODES
echo "Parallelizing $GAUSS_PDEF processes across $GAUSS_WDEF nodes."

# Run Gaussian
g16 $INPUT_MOLECULE $OUTPUT_FILE
