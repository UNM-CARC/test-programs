#!/usr/bin/env bash
# Run this file with: sbatch slurm-test.slurm
# This script demonstrates a single-node OpenMM library smoke test.

# Give the job a recognizable scheduler name; all suite jobs begin with test-.
#SBATCH --job-name=test-openmm
# Write standard output to a file named with the job name and Slurm job ID.
#SBATCH --output=%x-%j.out
# Write standard error to a matching file; this helps diagnose failed jobs.
#SBATCH --error=%x-%j.err
# Use the debug partition because this is an instructional/regression test.
#SBATCH --partition=debug
# Request one node for this single-node OpenMM example.
#SBATCH --nodes=1
# Request one Slurm task because this OpenMM example is not an MPI program.
#SBATCH --ntasks=1
# Give OpenMM two CPU cores for the single-node test.
#SBATCH --cpus-per-task=2
# Reserve modest memory for the OpenMM runtime.
#SBATCH --mem=2G
# Keep this smoke test short.
#SBATCH --time=00:05:00

# fail fast on errors, unset variables, or failed pipeline commands.
set -euo pipefail

# locate this OpenMM example directory when submitted from the
# repository root or from inside openmm/Easley/single-node.
script_dir="${SLURM_SUBMIT_DIR:-$PWD}"
if [[ -f "$script_dir/openmm/Easley/single-node/slurm-test.slurm" ]]; then
    script_dir="$script_dir/openmm/Easley/single-node"
fi

# reset modules so this example is not affected by the submit shell.
module purge

# identify the OpenMM 8.1.1 installation. The current Easley
# modulefile for openmm/8.1.1-wauv depends on a stale py-numpy module, so this
# smoke test sets the same OpenMM paths directly until the modulefile is fixed.
openmm_root="/opt/spack/opt/spack/linux-sapphirerapids/openmm-8.1.1-wauvsqj6tsfvrcjcyhnz5gjr33sbjbs2"
# make OpenMM command-line tools available in PATH for this job.
export PATH="$openmm_root/bin:$PATH"
# make the OpenMM shared libraries available to the test program.
export LD_LIBRARY_PATH="$openmm_root/lib:${LD_LIBRARY_PATH:-}"
# point OpenMM at the plugin directory used by this installation.
export OPENMM_PLUGIN_DIR="$openmm_root/lib/plugins"

# create a clean per-job output directory so runs do not collide.
run_dir="$script_dir/outputs/${SLURM_JOB_NAME}-${SLURM_JOB_ID}"
# remove any stale directory with the same job-derived name.
rm -rf "$run_dir"
# create the directory where this job will write files.
mkdir -p "$run_dir"
# run OpenMM from the per-job directory so outputs stay contained.
cd "$run_dir"

# report the OpenMM executable being used so users can confirm
# that this example is exercising the intended installation.
echo "OpenMM test executable: $(command -v TestReferenceHarmonicBondForce)"
# run an OpenMM-provided harmonic-bond force test under srun so
# Slurm launches it on the allocated compute node with the requested CPUs.
srun --cpus-per-task="$SLURM_CPUS_PER_TASK" TestReferenceHarmonicBondForce | tee openmm.out
# print a stable completion marker after the OpenMM test exits
# successfully, because this installed test executable may produce little output.
echo "OpenMM smoke test completed" | tee -a openmm.out

# confirm the program completed the OpenMM force test.
grep -q "OpenMM smoke test completed" openmm.out
