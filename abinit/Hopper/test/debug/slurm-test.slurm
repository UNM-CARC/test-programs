#!/bin/bash -l
# Run this file with: sbatch slurm-test.slurm
# This script demonstrates a two-node ABINIT MPI run.

# Use the debug partition because this is an instructional/regression test.
#SBATCH --partition=debug
# Request two nodes for this MPI example.
#SBATCH --nodes 2
# Request four MPI tasks on each node.
#SBATCH --ntasks-per-node 4 # number of processors to allocate
# Use at most one task per physical core.
#SBATCH --ntasks-per-core 1
# Allow enough time for the small ABINIT test calculation.
#SBATCH --time=00:20:00
# Send Slurm mail to the maintainer; users may remove or change this.
#SBATCH --mail-user mfricke@unm.edu
# Send mail for all job state changes; this is optional user notification.
#SBATCH --mail-type all
# Give the job a recognizable scheduler name; all suite jobs begin with test-.
#SBATCH --job-name=test-abinit

# start with a clean module environment.
module purge # make sure there are no lingering loaded modules, JIC
# add the local module tree that contains ABINIT modules.
module use /opt/local/modules
# choose the CUDA build on Hopper, otherwise use the CPU ABINIT build.
case "$(hostname -s)" in
    hopper*) module load abinit/cuda/10.4.5 ;;
    *) module load abinit/10.4.5 ;;
esac
# locate this example directory when submitted from the repo root
# or from inside abinit/.
script_dir="${SLURM_SUBMIT_DIR:-$PWD}"
if [[ -f "$script_dir/abinit/Hopper/test/debug/slurm-test.slurm" ]]; then
    script_dir="$script_dir/abinit/Hopper/test/debug"
fi
if [[ -f "$script_dir/abinit/test/debug.slurm" ]]; then
    script_dir="$script_dir/abinit/Hopper/test/debug"
elif [[ -f "$script_dir/test/debug.slurm" ]]; then
    script_dir="$script_dir/abinit/Hopper/test/debug"
fi

# create a clean per-job output directory so runs do not collide.
run_dir="$script_dir/outputs/${SLURM_JOB_NAME}-${SLURM_JOB_ID}"
# create the output directory.
mkdir -p "$run_dir"
# copy the ABINIT input file and pseudopotentials into the run dir.
cp "$script_dir"/t41.in "$script_dir"/Si_r.psp8 "$script_dir"/O.psp8 "$run_dir"/
# run ABINIT from the directory containing its input files.
cd "$run_dir"

# name the input file passed to ABINIT below.
export INPUTFILE=t41.in # XXX FIXME! XXX

# Optional Slurm setting, intentionally disabled for this example.
#export SLURM_OVERLAP=1

# launch ABINIT with the number of tasks requested from Slurm.
srun -n "$SLURM_NTASKS" abinit $INPUTFILE
# confirm ABINIT reported successful completion in its output file.
grep -q "Calculation completed" t41.abo
# Historical launcher alternative, left disabled because srun is preferred.
#mpirun abinit $INPUTFILE
