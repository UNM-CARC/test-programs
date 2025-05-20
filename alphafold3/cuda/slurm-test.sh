#!/bin/bash
#SBATCH --job-name=af3_test
#SBATCH --output=af3_test.out
#SBATCH --error=af3_test.err
#SBATCH --partition=debug
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=64G
#SBATCH --gpus=1
#SBATCH --time=01:00:00

# Load required modules
module load gcc/14.2.0-a75l apptainer

# Define paths
AF_INPUT="$SLURM_SUBMIT_DIR/af_input"
AF_OUTPUT="$SLURM_SUBMIT_DIR/af_output"
MODEL_DIR="$HOME/af_models"  # Update if your model parameters are elsewhere
DATABASES_DIR="/carc/scratch/shared/alphafold"
SIF_IMAGE="/projects/shared/singularity/alphafold3.sif"

# Run AlphaFold 3 using Apptainer (Singularity)
apptainer exec --nv \
  --bind "${AF_INPUT}:/root/af_input" \
  --bind "${AF_OUTPUT}:/root/af_output" \
  --bind "${MODEL_DIR}:/root/models" \
  --bind "${DATABASES_DIR}:/root/public_databases" \
  "${SIF_IMAGE}" \
  python run_alphafold.py \
    --json_path=/root/af_input/test.json \
    --model_dir=/root/models \
    --output_dir=/root/af_output
