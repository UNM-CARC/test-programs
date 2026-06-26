#!/bin/bash

#SBATCH --job-name=mpi_test
#SBATCH --output=output.txt
#SBATCH --error=error.txt
#SBATCH --nodes=2
#SBATCH --ntasks=32
#SBATCH --gpus=2
#SBATCH --time=00:05:00
#SBATCH --mail-type=All
#SBATCH --mail-user=mfricke@carc.unm.edu
#SBATCH --partition=dualGPU

#echo "Allocated the following nodes: $SLURM_NODELIST"
#echo -ne "Running on $HOSTNAME "
# For wheelie
#if [[ $HOSTNAME == "wheelie"* ]]; 
#then
#    echo "which is a wheelie compute node."
#    module load openmpi-3.1.5-intel-19.0.4-qi6o33b
#fi
# For taos
#if [[ $HOSTNAME == "taos"* ]]; 
#then
#    echo "which is a taos compute node."
#    module load openmpi-3.1.4-gcc-5.4.0-python3-emzdrpu
#    module unload slurm-18-08-0-1-gcc-5.4.0-python3-uazqgum
#fi
#mpirun mpihello 

srun --mpi=pmi2 mpihello
