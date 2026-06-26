#!/bin/bash -l
# Run this file with: sbatch slurm-test.slurm
# This script demonstrates multi-node NAMD with charmrun.

# Slurm resources for a two-node NAMD example.
#SBATCH --partition=debug
#SBATCH --job-name=test-namd
#SBATCH --time 00:10:00
#SBATCH --nodes 2
#SBATCH --ntasks-per-node 2
#SBATCH --mem 2GB
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err

# fail fast on errors, unset variables, or failed pipeline commands.
set -euo pipefail
# locate this example directory when submitted from common paths.
cd "${SLURM_SUBMIT_DIR:-$PWD}"
if [[ -f namd/multi-node/slurm-test.slurm ]]; then
    cd namd/multi-node
elif [[ -f ../multi-node/slurm-test.slurm ]]; then
    cd ../multi-node
fi

# load the verbs-enabled NAMD build for multi-node execution.
module load namd/2.14/verbs

# create a temporary node file in the format charmrun expects.
NAMD_NODEFILE=$(mktemp -p "$SLURM_SUBMIT_DIR")
# charmrun node files start with a group line.
echo group main > $NAMD_NODEFILE
# convert Slurm's allocated node list into charmrun host lines.
while IFS= read -r NODENAME; do
    echo host $NODENAME >> $NAMD_NODEFILE
done < <(scontrol show hostnames "$SLURM_JOB_NODELIST")

# remove duplicate host lines from the temporary node file.
echo "$(sort -u $NAMD_NODEFILE)" > $NAMD_NODEFILE

# print the generated node file for troubleshooting.
echo Wrote NAMD node file to $NAMD_NODEFILE containing:
cat $NAMD_NODEFILE

# NAMD Binaries are not SLURM aware - so we use charmrun directly
# launch NAMD through charmrun with one worker per Slurm task.
/usr/bin/time -v charmrun "$(which namd2)" "+p${SLURM_NTASKS}" ++nodelist "$NAMD_NODEFILE" ubq_ws_eq.conf

# remove the temporary charmrun node file after the run.
rm "$NAMD_NODEFILE"
