#!/bin/bash
#SBATCH --job-name=pmemd-cuda-test
#SBATCH --output=pmemd-cuda.out
#SBATCH --error=pmemd-cuda.err
#SBATCH --time=00:10:00
#SBATCH --ntasks=1
#SBATCH --gres=gpu:1
#SBATCH --mem=2G
#SBATCH --partition=debug

module purge
module load amber/ambertools/25
module load amber-pmemd/24-cuda
module load cuda/12.8.0-dh6b

echo "=== Running PMEMD.CUDA on a single GPU ==="

# NOTE:
# pmemd.cuda runs entirely on a single GPU.
# No MPI or OpenMP is used unless you specifically run pmemd.cuda.MPI with MPI support.
# CUDA handles the parallelism internally on the GPU.

pmemd.cuda -O \
 -i ../../data/TXM-wbions-prod1-r1.in \
 -o prod.out \
 -p ../../data/TXM-wbions.prmtop \
 -c ../../data/TXM-wbions-eqmd2.rst \
 -r prod.rst \
 -x prod.nc

echo "PMEMD CUDA GPU test completed."
