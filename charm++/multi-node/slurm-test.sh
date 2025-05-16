#!/bin/bash
#SBATCH --job-name=test-charm++
#SBATCH --output=output.txt
#SBATCH --error=error.txt
#SBATCH --time=00:05:00
#SBATCH --mem=2G
#SBATCH --partition=debug
#SBATCH --nodes=2
#SBATCH --ntasks=8

module load charmpp time

# Create example hello program
cd hello_example/
charmc hello.ci
charmc hello.C -o hello
mv hello ../
cd ../

# Generate a properly formatted machine file
scontrol show hostnames $SLURM_JOB_NODELIST | awk '{print "host "$1}' > nodelist.txt

# Launch Charm++ program
$(which time) -v charmrun +p8 hello ++nodelist nodelist.txt ++remote-shell ssh

