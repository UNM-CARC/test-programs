#!/usr/bin/tcsh
# Matthew Fricke, April 10th, 2020
#SBATCH --job-name=orca_test
#SBATCH --output=test.out
#SBATCH --ntasks=32
#SBATCH --time=02:00:00
#SBATCH --cpus-per-task=1
#SBATCH --partition=tc
#SBATCH -w taos22

set files=td_Th2-Pt-cat-tzvp.inp

cd $SLURM_SUBMIT_DIR/

#module load openmpi-3.1.4-intel-19.0.4-python3-ajqkuiv
module load openmpi-3.1.5-gcc-5.4.0-f6ikvl6
#export PATH=".:$PATH"
module load orca/4.2.1
#module load openmpi-3.1.4-gcc-5.4.0-python3-emzdrpu
#module unload slurm-18-08-0-1-gcc-5.4.0-python3-uazqgum

# Orca needs the full path when running in parallel
set full_orca_path="`which orca`"

# Run Orca
$full_orca_path $files
