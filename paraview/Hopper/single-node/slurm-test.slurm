#!/usr/bin/env bash
# Run this file with: sbatch slurm-test.slurm
# This script demonstrates ParaView pvbatch on Slurm tasks.

# Slurm resources for a small parallel ParaView batch example.
#SBATCH --job-name=test-paraview-batch
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err
#SBATCH --partition=debug
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=00:05:00

# fail fast on errors, unset variables, or failed pipeline commands.
set -euo pipefail

# locate this example directory when submitted from the repo root.
script_dir="${SLURM_SUBMIT_DIR:-$PWD}"
if [[ -f "$script_dir/paraview/Hopper/single-node/slurm-test.slurm" ]]; then
    script_dir="$script_dir/paraview/Hopper/single-node"
fi
if [[ -f "$script_dir/paraview/Hopper/single-node/slurm-test.slurm" ]]; then
    script_dir="$script_dir/paraview/Hopper/single-node"
fi

# reset modules and load ParaView.
module purge
module load paraview/6.0

# create a clean per-job output directory so runs do not collide.
run_dir="$script_dir/outputs/${SLURM_JOB_NAME}-${SLURM_JOB_ID}"
rm -rf "$run_dir"
mkdir -p "$run_dir"
cd "$run_dir"

# write a small pvbatch Python pipeline.
cat > paraview_batch.py <<'EOF'
from paraview.simple import Sphere, Calculator
from paraview import servermanager

sphere = Sphere(ThetaResolution=96, PhiResolution=48)
calc = Calculator(Input=sphere)
calc.ResultArrayName = "radius_squared"
calc.Function = "coordsX*coordsX + coordsY*coordsY + coordsZ*coordsZ"
calc.UpdatePipeline()
data = servermanager.Fetch(calc)
points = data.GetNumberOfPoints()
cells = data.GetNumberOfCells()

with open("paraview-batch.out", "w", encoding="utf-8") as handle:
    handle.write("paraview_version=%s\n" % servermanager.vtkSMProxyManager.GetVersionMajor())
    handle.write("points=%d\n" % points)
    handle.write("cells=%d\n" % cells)
EOF

# launch pvbatch with one process per Slurm task.
srun -n "${SLURM_NTASKS}" pvbatch --force-offscreen-rendering paraview_batch.py
# confirm the pipeline produced point-count output.
grep -q "points=" paraview-batch.out
# confirm the pipeline produced cell-count output.
grep -q "cells=" paraview-batch.out
