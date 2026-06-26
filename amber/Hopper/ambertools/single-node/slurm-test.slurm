#!/bin/bash -l
# Run this file with: sbatch slurm-test.slurm
# This script demonstrates several single-node AmberTools commands.

# Give the job a recognizable scheduler name; all suite jobs begin with test-.
#SBATCH --job-name=test-ambertools
# Write standard output to a file named with the job name and Slurm job ID.
#SBATCH --output=%x-%j.out
# Write standard error to a matching file; this helps diagnose failed jobs.
#SBATCH --error=%x-%j.err
# Keep this AmberTools smoke test short.
#SBATCH --time=00:05:00
# Request one Slurm task because these commands run serially.
#SBATCH --ntasks=1
# Reserve one CPU core for this serial example.
#SBATCH --cpus-per-task=1
# Reserve memory for the small AmberTools examples.
#SBATCH --mem=1G
# Use the debug partition because this is an instructional/regression test.
#SBATCH --partition=debug

# fail fast on errors, unset variables, or failed pipeline commands.
set -euo pipefail
# start from the directory where sbatch was submitted.
cd "${SLURM_SUBMIT_DIR:-$PWD}"
# locate this example directory when submitted from nearby paths.
if [[ -f ../single-node/slurm-test.slurm ]]; then
    cd ../single-node
elif [[ -f amber/ambertools/single-node/slurm-test.slurm ]]; then
    cd amber/ambertools/single-node
fi

# load AmberTools so cpptraj, tleap, and sander are available.
module load amber/ambertools/25

# label the first command in the job log.
echo "=== Step 1: Running cpptraj RMS fit ==="
# run cpptraj and feed it a tiny analysis script using a here-doc.
cpptraj -p ../../data/TXM-wbions.prmtop <<EOF
trajin ../../data/TXM-wbions-prod6-r1.rst
rms first
EOF

# label the tleap command in the job log.
echo "=== Step 2: Confirming tleap runs ==="
# run tleap from standard input to build a tiny alanine system.
tleap -f - <<EOF
source leaprc.protein.ff14SB
mol = sequence { ALA }
saveamberparm mol test.prmtop test.inpcrd
quit
EOF

# label the sander minimisation in the job log.
echo "=== Step 3: Energy minimisation with sander ==="
# write a minimal sander input file for a short minimisation.
cat > min.in <<EOF
Minimisation
 &cntrl
  imin=1, maxcyc=100, ncyc=50,
  cut=999.0, ntb=0, igb=1,
  ntpr=10
 /
EOF

# run sander through srun so Slurm tracks the process.
# /usr/bin/time -v records resource use in the job log.
/usr/bin/time -v srun sander -O -i min.in -o min.out -p test.prmtop -c test.inpcrd -r min.rst
