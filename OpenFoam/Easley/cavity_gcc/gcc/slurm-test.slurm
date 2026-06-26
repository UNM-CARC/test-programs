#!/bin/bash -l
# Run this file with: sbatch slurm-test.slurm
# This script demonstrates a small parallel OpenFOAM cavity-flow run.

# Give the job a recognizable scheduler name; all suite jobs begin with test-.
#SBATCH --job-name=test-openfoam-gcc
# Write standard output to a file named with the job name and Slurm job ID.
#SBATCH --output=%x-%j.out
# Write standard error to a matching file; this helps diagnose failed jobs.
#SBATCH --error=%x-%j.err
# Use the debug partition because this is an instructional/regression test.
#SBATCH --partition=debug
# Allow enough time for meshing, decomposition, solving, and reconstruction.
#SBATCH --time=00:10:00
# Request one node for this small parallel example.
#SBATCH --nodes=1
# Request two MPI tasks; icoFoam runs once per task under srun below.
#SBATCH --ntasks=2
# Reserve memory for the small cavity mesh and solver output.
#SBATCH --mem=2G

# fail fast on errors, unset variables, or failed pipeline commands.
set -euo pipefail
# locate the OpenFOAM case directory when submitted from the
# repository root or from inside OpenFoam/cavity_gcc.
script_dir="${SLURM_SUBMIT_DIR:-$PWD}"
if [[ -f "$script_dir/OpenFoam/Easley/cavity_gcc/gcc/slurm-test.slurm" ]]; then
    script_dir="$script_dir/OpenFoam/Easley/cavity_gcc/gcc"
fi
if [[ -f "$script_dir/OpenFoam/cavity_gcc/gcc.slurm" ]]; then
    script_dir="$script_dir/OpenFoam/Easley/cavity_gcc/gcc"
fi

# load the MPI runtime and OpenFOAM module used by this example.
# --ignore-cache avoids stale Lmod cache entries on shared filesystems.
module --ignore-cache load intel-oneapi-mpi/2021.15.0-6pwh openfoam-org/11-xdif

# create a clean per-job output directory so runs do not collide.
run_dir="$script_dir/outputs/${SLURM_JOB_NAME}-${SLURM_JOB_ID}"
# remove any stale directory with the same job-derived name.
rm -rf "$run_dir"
# create the directory for this job's copied case files.
mkdir -p "$run_dir"
# copy the initial conditions and solver controls into the run dir.
cp -a "$script_dir/0" "$script_dir/system" "$run_dir/"
# create the OpenFOAM constant directory for physical properties.
mkdir -p "$run_dir/constant"
# copy the original transport properties file for compatibility.
cp "$script_dir/constant/transportProperties" "$run_dir/constant/"
# OpenFOAM 11 expects physicalProperties, so this converts the
# legacy case file name/object while leaving the source fixture unchanged.
sed 's/object      transportProperties;/object      physicalProperties;/' \
    "$script_dir/constant/transportProperties" > "$run_dir/constant/physicalProperties"
# run OpenFOAM commands from the prepared case directory.
cd "$run_dir"

# remove any stale OpenFOAM processor directories before decomposing.
rm -rf processor*
# generate the computational mesh.
blockMesh > log.blockMesh
# split the mesh into the number of subdomains configured in system/.
decomposePar > log.decomposePar
# launch the parallel solver with one MPI rank per Slurm task.
srun -n "${SLURM_NTASKS}" icoFoam -parallel > log.icoFoam
# combine per-rank results back into a single case for inspection.
reconstructPar > log.reconstructPar
