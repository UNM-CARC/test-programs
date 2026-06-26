#!/bin/bash -l
# Run this file with: sbatch slurm-test.slurm
# This script demonstrates a GPU-enabled ABINIT run.

# Use the debug partition because this is an instructional/regression test.
#SBATCH --partition=debug
# Give the job a recognizable scheduler name; all suite jobs begin with test-.
#SBATCH --job-name=test-abinit-gpu
# Request one node for this GPU example.
#SBATCH --nodes 1
# Request four MPI tasks for ABINIT.
#SBATCH --ntasks 4
# Request one H100 GPU on the node.
#SBATCH --gres=gpu:h100:1
# Keep the example short.
#SBATCH --time=00:10:00
# Write standard output to a file named with the job name and Slurm job ID.
#SBATCH --output %x-%j.out
# Send Slurm mail to the maintainer; users may remove or change this.
#SBATCH --mail-user mfricke@unm.edu
# Send mail for all job state changes; this is optional user notification.
#SBATCH --mail-type all

# locate this example directory when submitted from the repo root
# or from inside abinit/Hopper/gpu.
script_dir="${SLURM_SUBMIT_DIR:-$PWD}"
if [[ -f "$script_dir/abinit/Hopper/gpu/slurm-test.slurm" ]]; then
    script_dir="$script_dir/abinit/Hopper/gpu"
fi
if [[ -f "$script_dir/abinit/Hopper/gpu/slurm-test.slurm" ]]; then
    script_dir="$script_dir/abinit/Hopper/gpu"
fi

# location of the input directory containing the .abi file.
INPUT_DIR=$script_dir/inputs/t41


# reset modules and load the CUDA-enabled ABINIT module.
module purge
# add the local module tree that contains this ABINIT build.
module use /opt/local/modules
module load abinit/cuda/10.4.5

# create a unique output path based on the job name, job ID, and time.
OUTPUT_DIR=$script_dir/outputs/${SLURM_JOB_NAME}_${SLURM_JOBID}_$(date +'%Y-%m-%d_%H-%M-%S')/

# copy input data into the output directory and enter that directory.
# When ABINIT runs, all output will be saved in this per-job output directory.
mkdir -p $OUTPUT_DIR && cp $INPUT_DIR/* $OUTPUT_DIR/
cd $OUTPUT_DIR
# find the ABINIT input file copied into the run directory.
INPUT_FILE=$(basename *.abi) 

# tell OpenMP-aware code how many threads/ranks are available per node.
export OMP_NUM_THREADS=$SLURM_NTASKS_PER_NODE
# require GPU offload so the test fails if it silently falls back to CPU.
export OMP_TARGET_OFFLOAD=MANDATORY

# echo paths and input file to the job log for troubleshooting.
echo Input: $INPUT_DIR
echo Output: $OUTPUT_DIR
echo Abinit Input File: $INPUT_FILE
# launch ABINIT through Slurm so the requested tasks are used.
srun abinit $INPUT_FILE 
