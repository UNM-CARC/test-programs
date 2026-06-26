#!/bin/bash -l
# Run this file with: sbatch slurm-test.slurm
# This script demonstrates a multi-node Charm++ program.

# Slurm resources for a two-node Charm++ example.
#SBATCH --job-name=test-charm++
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err
#SBATCH --time=00:05:00
#SBATCH --mem=2G
#SBATCH --partition=debug
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=2

# fail fast on errors, unset variables, or failed pipeline commands.
set -euo pipefail
# locate this example directory when submitted from common paths.
cd "${SLURM_SUBMIT_DIR:-$PWD}"
if [[ -f charm++/multi-node/slurm-test.slurm ]]; then
    cd charm++/multi-node
elif [[ -f ../multi-node/slurm-test.slurm ]]; then
    cd ../multi-node
fi

# load Charm++ and the time utility module.
module load charmpp time

# build the example hello program only if it is not already built.
if [[ ! -x ./hello ]]; then
    # enter the source directory before compiling.
    cd hello_example/
    # generate Charm++ interface code from hello.ci.
    charmc hello.ci
    # compile the Charm++ C++ source into an executable.
    charmc hello.C -o hello
    # move the executable next to this Slurm script.
    mv hello ../
    # return to the Slurm example directory.
    cd ../
fi

# convert Slurm's node list into the machine-file format charmrun expects.
scontrol show hostnames $SLURM_JOB_NODELIST | awk '{print "host "$1}' > nodelist.txt

# launch the Charm++ program with one processing element per Slurm task.
# $(which time) uses the module-provided time command for resource logging.
$(which time) -v charmrun "+p${SLURM_NTASKS}" ./hello ++nodelist nodelist.txt ++remote-shell ssh
