#!/bin/bash -l
# Run this file with: sbatch slurm-test.slurm
# This script compiles and runs a small HDF5 dataset I/O smoke test.
#SBATCH --job-name=test-hdf5
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err
#SBATCH --partition=debug
#SBATCH --time=00:05:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=1G

set -euo pipefail
script_dir="${SLURM_SUBMIT_DIR:-$PWD}"
if [[ -f "$script_dir/hdf5/Easley/single-node/slurm-test.slurm" ]]; then
    script_dir="$script_dir/hdf5/Easley/single-node"
fi
module purge
module load gcc/14.2.0-a75l
module load openmpi/4.1.7-762w
module load hdf5/1.14.6-57x4

run_dir="$script_dir/outputs/${SLURM_JOB_NAME}-${SLURM_JOB_ID}"
rm -rf "$run_dir"
mkdir -p "$run_dir"
cd "$run_dir"

cat > hdf5_smoke.c <<'EOF'
#include <stdio.h>
#include <hdf5.h>
int main(void) {
    int values[4] = {1, 2, 3, 4}, readback[4] = {0, 0, 0, 0};
    hsize_t dims[1] = {4};
    hid_t file = H5Fcreate("hdf5-smoke.h5", H5F_ACC_TRUNC, H5P_DEFAULT, H5P_DEFAULT);
    hid_t space = H5Screate_simple(1, dims, NULL);
    hid_t dset = H5Dcreate2(file, "/values", H5T_NATIVE_INT, space, H5P_DEFAULT, H5P_DEFAULT, H5P_DEFAULT);
    if (H5Dwrite(dset, H5T_NATIVE_INT, H5S_ALL, H5S_ALL, H5P_DEFAULT, values) < 0) return 2;
    H5Dclose(dset); H5Sclose(space); H5Fclose(file);
    file = H5Fopen("hdf5-smoke.h5", H5F_ACC_RDONLY, H5P_DEFAULT);
    dset = H5Dopen2(file, "/values", H5P_DEFAULT);
    if (H5Dread(dset, H5T_NATIVE_INT, H5S_ALL, H5S_ALL, H5P_DEFAULT, readback) < 0) return 3;
    H5Dclose(dset); H5Fclose(file);
    int sum = 0; for (int i = 0; i < 4; ++i) sum += readback[i];
    if (sum != 10) return 4;
    puts("HDF5 dataset I/O smoke test completed");
    return 0;
}
EOF
h5cc hdf5_smoke.c -o hdf5_smoke
srun ./hdf5_smoke | tee hdf5.out
test -s hdf5-smoke.h5
grep -q "HDF5 dataset I/O smoke test completed" hdf5.out
