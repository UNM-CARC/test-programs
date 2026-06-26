#!/bin/bash -l
# Run this file with: sbatch slurm-test.slurm
# This script compiles and runs a small ScaLAPACK/BLACS descriptor smoke test.
#SBATCH --job-name=test-scalapack
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err
#SBATCH --partition=debug
#SBATCH --time=00:05:00
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=2
#SBATCH --cpus-per-task=1
#SBATCH --mem=1G

set -euo pipefail
script_dir="${SLURM_SUBMIT_DIR:-$PWD}"
if [[ -f "$script_dir/netlib-scalapack/Easley/multi-node/slurm-test.slurm" ]]; then
    script_dir="$script_dir/netlib-scalapack/Easley/multi-node"
fi
module purge
module load gcc/14.2.0-a75l
module load openmpi/4.1.7-e7k3
module load netlib-scalapack/2.2.2-zoxl

run_dir="$script_dir/outputs/${SLURM_JOB_NAME}-${SLURM_JOB_ID}"
rm -rf "$run_dir"
mkdir -p "$run_dir"
cd "$run_dir"

cat > scalapack_smoke.f90 <<'EOF'
program scalapack_smoke
  implicit none
  integer :: iam, nprocs, ictxt, nprow, npcol, myrow, mycol, info
  integer :: desc(9)
  call blacs_pinfo(iam, nprocs)
  nprow = 1
  npcol = nprocs
  call blacs_get(-1, 0, ictxt)
  call blacs_gridinit(ictxt, 'R', nprow, npcol)
  call blacs_gridinfo(ictxt, nprow, npcol, myrow, mycol)
  call descinit(desc, 1, 1, 1, 1, 0, 0, ictxt, 1, info)
  if (info /= 0) stop 2
  if (myrow < 0 .or. mycol < 0) stop 3
  if (iam == 0) print *, 'ScaLAPACK BLACS descriptor smoke test completed'
  call blacs_gridexit(ictxt)
  call blacs_exit(0)
end program scalapack_smoke
EOF
OMPI_FC="$(command -v gfortran)" mpifort scalapack_smoke.f90 -o scalapack_smoke -L"$NETLIB_SCALAPACK_LIB" -Wl,-rpath,"$NETLIB_SCALAPACK_LIB" -lscalapack
srun -n "${SLURM_NTASKS}" ./scalapack_smoke | tee scalapack.out
grep -q "ScaLAPACK BLACS descriptor smoke test completed" scalapack.out
