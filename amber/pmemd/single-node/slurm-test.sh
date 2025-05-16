#!/bin/bash
#SBATCH --job-name=pmemd-cpu-test
#SBATCH --output=pmemd-cpu.out
#SBATCH --error=pmemd-cpu.err
#SBATCH --time=00:05:00
#SBATCH --ntasks=4
#SBATCH --mem=2G
#SBATCH --partition=debug

module purge
module load amber/ambertools/25
module load amber-pmemd/24-cpu

echo "=== Running PMEMD.MPI on a single node ==="

# NOTE:
# Amber's PMEMD does NOT support OpenMP.
# It is parallelised using MPI only, and this script uses 4 MPI ranks via srun.
# The OpenMP model is supported in sander (sander.OMP) and some AmberTools components (cpptraj.OMP),
# but NOT in pmemd, pmemd.cuda, or pmemd.cuda.MPI.

srun pmemd.MPI -O \
 -i ../../data/TXM-wbions-prod1-r1.in \
 -o prod.out \
 -p ../../data/TXM-wbions.prmtop \
 -c ../../data/TXM-wbions-eqmd2.rst \
 -r prod.rst \
 -x prod.nc

echo "PMEMD single-node test completed."
