#!/bin/bash
#SBATCH --job-name=ambertools-mpi-test
#SBATCH --output=ambertools-mpi.out
#SBATCH --error=ambertools-mpi.err
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=4
#SBATCH --mem=2G
#SBATCH --time=00:05:00
#SBATCH --partition=debug

module purge
module load amber/ambertools/25

echo "=== Step 1: Running sander.MPI minimisation across nodes ==="

cat > min.in <<EOF
Minimisation
 &cntrl
  imin=1, maxcyc=100, ncyc=50,
  cut=8.0, ntb=1,
  ntpr=10
 /
EOF

srun sander.MPI -O -i min.in -o min.out \
 -p ../../data/TXM-wbions.prmtop \
 -c ../../data/TXM-wbions-eqmd2.rst \
 -r min.rst

echo "=== Step 2: Optional: Try cpptraj.MPI if compiled ==="
# Uncomment below if cpptraj.MPI exists and was built
srun cpptraj.MPI -p ../../data/TXM-wbions.prmtop <<EOF
trajin ../../data/TXM-wbions-prod6-r1.rst
rms first
EOF

echo "AmberTools multi-node test completed."
