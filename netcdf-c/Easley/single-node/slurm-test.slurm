#!/bin/bash -l
# Run this file with: sbatch slurm-test.slurm
# This script compiles and runs a small NetCDF-C variable I/O smoke test.
#SBATCH --job-name=test-netcdf-c
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
if [[ -f "$script_dir/netcdf-c/Easley/single-node/slurm-test.slurm" ]]; then
    script_dir="$script_dir/netcdf-c/Easley/single-node"
fi
module purge
module load gcc/14.2.0-a75l
module load openmpi/4.1.7-6x5e
module load netcdf-c/4.9.3-zy2g

run_dir="$script_dir/outputs/${SLURM_JOB_NAME}-${SLURM_JOB_ID}"
rm -rf "$run_dir"
mkdir -p "$run_dir"
cd "$run_dir"

cat > netcdf_smoke.c <<'EOF'
#include <stdio.h>
#include <netcdf.h>
#define NCHECK(call) do { int e = (call); if (e != NC_NOERR) { fprintf(stderr, "%s\n", nc_strerror(e)); return 2; } } while (0)
int main(void) {
    int ncid, dimid, varid;
    int values[4] = {2, 4, 6, 8}, readback[4] = {0, 0, 0, 0};
    NCHECK(nc_create("netcdf-smoke.nc", NC_CLOBBER, &ncid));
    NCHECK(nc_def_dim(ncid, "x", 4, &dimid));
    NCHECK(nc_def_var(ncid, "values", NC_INT, 1, &dimid, &varid));
    NCHECK(nc_enddef(ncid));
    NCHECK(nc_put_var_int(ncid, varid, values));
    NCHECK(nc_close(ncid));
    NCHECK(nc_open("netcdf-smoke.nc", NC_NOWRITE, &ncid));
    NCHECK(nc_inq_varid(ncid, "values", &varid));
    NCHECK(nc_get_var_int(ncid, varid, readback));
    NCHECK(nc_close(ncid));
    int sum = 0; for (int i = 0; i < 4; ++i) sum += readback[i];
    if (sum != 20) return 3;
    puts("NetCDF-C variable I/O smoke test completed");
    return 0;
}
EOF
netcdf_libdir="$(nc-config --libs | sed -n 's/.*-L\([^ ]*\).*/\1/p')"
"$(nc-config --cc)" $(nc-config --cflags) netcdf_smoke.c -o netcdf_smoke $(nc-config --libs) -Wl,-rpath,"$netcdf_libdir"
srun ./netcdf_smoke | tee netcdf.out
test -s netcdf-smoke.nc
grep -q "NetCDF-C variable I/O smoke test completed" netcdf.out
