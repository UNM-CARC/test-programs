#!/bin/bash
#SBATCH --partition biocomp
#SBATCH --job-name t41_multigpu
#SBATCH --nodes 1
#SBATCH --ntasks 32 
#SBATCH --gpus=1
#SBATCH --output %x-%j.out
#SBATCH --mail-user mfricke@unm.edu
#SBATCH --mail-type all

# Location of the input directory
# containing the .abi file
INPUT_DIR=$SLURM_SUBMIT_DIR/inputs/t41


# Load the cuda enabled abinit module
module load abinit/cuda/10.0.9

# Create an output path based on the job name
OUTPUT_DIR=$SLURM_SUBMIT_DIR/outputs/${SLURM_JOB_NAME}_${SLURM_JOBID}_$(date +'%Y-%m-%d_%H-%M-%S')/

# Copy the input data into the output directory and enter that directory
# When abinit runs the output will be saved in the output directory
mkdir -p $OUTPUT_DIR && cp $INPUT_DIR/* $OUTPUT_DIR/
cd $OUTPUT_DIR
INPUT_FILE=$(basename *.abi) 

# Set OpenMP Variables
export OMP_NUM_THREADS=$SLURM_NTASKS_PER_NODE
# Require GPU to run
export OMP_TARGET_OFFLOAD=MANDATORY

echo Input: $INPUT_DIR
echo Output: $OUTPUT_DIR
echo Abinit Input File: $INPUT_FILE
# Find a file in the input directory with an .abi extention
# and run abinit on it
srun abinit $INPUT_FILE 

