#!/bin/bash -l
# Run this file with: sbatch slurm-test.slurm
# This script compiles and runs small Intel oneMKL BLAS/LAPACK smoke tests.
#SBATCH --job-name=test-mkl
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
if [[ -f "$script_dir/intel-oneapi-mkl/Easley/single-node/slurm-test.slurm" ]]; then
    script_dir="$script_dir/intel-oneapi-mkl/Easley/single-node"
fi
module purge
module load intel-oneapi-mkl/2024.2.2-tczp

run_dir="$script_dir/outputs/${SLURM_JOB_NAME}-${SLURM_JOB_ID}"
rm -rf "$run_dir"
mkdir -p "$run_dir"
cd "$run_dir"

cat > mkl_smoke.c <<'EOF'
#include <math.h>
#include <stdio.h>
#include <mkl.h>
int main(void) {
    double a[4] = {1, 3, 2, 4};
    double expected[4] = {7, 15, 10, 22};
    double c[4] = {0, 0, 0, 0};
    cblas_dgemm(CblasColMajor, CblasNoTrans, CblasNoTrans, 2, 2, 2, 1.0, a, 2, a, 2, 0.0, c, 2);
    for (int i = 0; i < 4; ++i) if (fabs(c[i] - expected[i]) > 1e-12) return 2;
    MKL_INT n = 2, nrhs = 1, lda = 2, ldb = 2, ipiv[2];
    double amat[4] = {3, 1, 1, 2};
    double rhs[2] = {9, 8};
    MKL_INT info = LAPACKE_dgesv(LAPACK_COL_MAJOR, n, nrhs, amat, lda, ipiv, rhs, ldb);
    if (info != 0) return 3;
    if (fabs(rhs[0] - 2.0) > 1e-12 || fabs(rhs[1] - 3.0) > 1e-12) return 4;
    puts("Intel oneMKL dgemm/dgesv smoke test completed");
    return 0;
}
EOF
mkl_libdir="$MKLROOT/lib/intel64"
gcc mkl_smoke.c -o mkl_smoke -L"$mkl_libdir" -Wl,-rpath,"$mkl_libdir" -lmkl_intel_lp64 -lmkl_sequential -lmkl_core -lpthread -lm -ldl
srun ./mkl_smoke | tee mkl.out
grep -q "Intel oneMKL dgemm/dgesv smoke test completed" mkl.out
