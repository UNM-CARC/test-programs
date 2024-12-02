#!/bin/sh
#SBATCH  -J bfs                          # Job name
#SBATCH  -p normal                       # Queue (development or normal)
#SBATCH  -N 1                            # Number of nodes
#SBATCH --tasks-per-node 4               # Number of tasks per node
#SBATCH  -t 01:00:00                     # Time limit hrs:min:sec
#SBATCH  -A 2016230                      # Allocation
#SBATCH  -o bfs=%j.out                   # Standard output and error log
#SBATCH --mail-user mfricke@unm.edu
#SBATCH --mail-type ALL

#module load petsc

pwd; hostname; date

srun ./test_bfs -tests 4 -num_time 1000

date
