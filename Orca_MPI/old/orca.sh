#!/usr/bin/bash
# Matthew Fricke, April 10th, 2020
#SBATCH --job-name=orca_test
#SBATCH --output=test.out
#SBATCH --ntasks=8
#SBATCH --cpus-per-task=1
#SBATCH --partition=tc
#SBATCH --mem-per-cpu=6GB

files=MsrP-4S-opt7.inp

cd $SLURM_SUBMIT_DIR/

module load openmpi-3.1.5-gcc-5.4.0-f6ikvl6
module load orca/4.2.1

# Orca needs the full path when running in parallel
full_orca_path=`which orca`

# Run Orca
$full_orca_path $files
