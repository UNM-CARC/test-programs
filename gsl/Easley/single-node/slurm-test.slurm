#!/bin/bash -l
# Run this file with: sbatch slurm-test.slurm
# This script compiles and runs a small GSL special-function/statistics smoke test.
#SBATCH --job-name=test-gsl
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
if [[ -f "$script_dir/gsl/Easley/single-node/slurm-test.slurm" ]]; then
    script_dir="$script_dir/gsl/Easley/single-node"
fi
module purge
module load gcc/13.3.0-23o2
module load gsl/2.8-kjkc

run_dir="$script_dir/outputs/${SLURM_JOB_NAME}-${SLURM_JOB_ID}"
rm -rf "$run_dir"
mkdir -p "$run_dir"
cd "$run_dir"

cat > gsl_smoke.c <<'EOF'
#include <math.h>
#include <stdio.h>
#include <gsl/gsl_sf_bessel.h>
#include <gsl/gsl_statistics_double.h>
int main(void) {
    double data[4] = {1.0, 2.0, 3.0, 4.0};
    double mean = gsl_stats_mean(data, 1, 4);
    double j0 = gsl_sf_bessel_J0(0.0);
    if (fabs(mean - 2.5) > 1e-12 || fabs(j0 - 1.0) > 1e-12) return 2;
    puts("GSL special-function/statistics smoke test completed");
    return 0;
}
EOF
gcc -I"$GSL_ROOT/include" gsl_smoke.c -o gsl_smoke -L"$GSL_LIB" -Wl,-rpath,"$GSL_LIB" -lgsl -lgslcblas -lm
srun ./gsl_smoke | tee gsl.out
grep -q "GSL special-function/statistics smoke test completed" gsl.out
