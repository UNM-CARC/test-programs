#!/bin/bash
#SBATCH --job-name=pmemd-multinode-test
#SBATCH --output=pmemd-multinode.out
#SBATCH --error=pmemd-multinode.err
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=4
#SBATCH --mem=2G
#SBATCH --time=00:10:00
#SBATCH --partition=debug

module purge
module load amber/ambertools/25
module load amber-pmemd/24-cpu

echo "=== Running PMEMD.MPI across multiple nodes ==="

# NOTE:
# PMEMD uses MPI for distributed-memory parallelism.
# This test uses 2 nodes with 4 MPI ranks each (total of 8).
# PMEMD does not use OpenMP — no threading is involved here.
# Use pmemd.MPI for CPU-parallel MD on clusters.

srun pmemd.MPI -O \
 -i ../../data/TXM-wbions-prod6-r1.in \
 -o prod6.out \
 -p ../../data/TXM-wbions.prmtop \
 -c ../../data/TXM-wbions-prod5-r1.rst \
 -r prod6.rst \
 -x prod6.nc

echo "PMEMD multi-node test completed."
