#!/bin/bash
#SBATCH --job-name=ambertools-test
#SBATCH --output=ambertools.out
#SBATCH --error=ambertools.err
#SBATCH --time=00:05:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=1G
#SBATCH --partition=debug

module load amber/ambertools/25

echo "=== Step 1: Running cpptraj RMS fit ==="
cpptraj -p ../../data/TXM-wbions.prmtop <<EOF
trajin ../../data/TXM-wbions-prod6-r1.rst
rms first
EOF

echo "=== Step 2: Confirming tleap runs ==="
tleap -f - <<EOF
source leaprc.protein.ff14SB
mol = sequence { ALA }
saveamberparm mol test.prmtop test.inpcrd
quit
EOF

echo "=== Step 3: Energy minimisation with sander ==="
cat > min.in <<EOF
Minimisation
 &cntrl
  imin=1, maxcyc=100, ncyc=50,
  cut=8.0, ntb=1,
  ntpr=10
 /
EOF

sander -O -i min.in -o min.out -p test.prmtop -c test.inpcrd -r min.rst
