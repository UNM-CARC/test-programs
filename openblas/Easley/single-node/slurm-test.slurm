#!/bin/bash -l
# Run this file with: sbatch slurm-test.slurm
# This script compiles and runs small OpenBLAS BLAS/LAPACK smoke tests.
#SBATCH --job-name=test-openblas
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
if [[ -f "$script_dir/openblas/Easley/single-node/slurm-test.slurm" ]]; then
    script_dir="$script_dir/openblas/Easley/single-node"
fi
module purge
module load gcc/14.2.0-a75l
module load openblas/0.3.30-cpqn

run_dir="$script_dir/outputs/${SLURM_JOB_NAME}-${SLURM_JOB_ID}"
rm -rf "$run_dir"
mkdir -p "$run_dir"
cd "$run_dir"

cat > openblas_smoke.c <<'EOF'
#include <math.h>
#include <stdio.h>
#include <cblas.h>
extern void dgesv_(int*, int*, double*, int*, int*, double*, int*, int*);
int main(void) {
    double a[4] = {1, 3, 2, 4}; /* column-major [[1,2],[3,4]] */
    double b[4] = {7, 15, 10, 22};
    double c[4] = {0, 0, 0, 0};
    cblas_dgemm(CblasColMajor, CblasNoTrans, CblasNoTrans, 2, 2, 2, 1.0, a, 2, a, 2, 0.0, c, 2);
    for (int i = 0; i < 4; ++i) if (fabs(c[i] - b[i]) > 1e-12) return 2;
    int n = 2, nrhs = 1, lda = 2, ldb = 2, ipiv[2], info = 0;
    double amat[4] = {3, 1, 1, 2};
    double rhs[2] = {9, 8};
    dgesv_(&n, &nrhs, amat, &lda, ipiv, rhs, &ldb, &info);
    if (info != 0) return 3;
    if (fabs(rhs[0] - 2.0) > 1e-12 || fabs(rhs[1] - 3.0) > 1e-12) return 4;
    puts("OpenBLAS dgemm/dgesv smoke test completed");
    return 0;
}
EOF
openblas_libdir="$(pkg-config --variable=libdir openblas)"
gfortran_libdir="$(dirname "$(gfortran -print-file-name=libgfortran.so)")"
gcc $(pkg-config --cflags openblas) openblas_smoke.c -o openblas_smoke $(pkg-config --libs --static openblas) -Wl,-rpath,"$openblas_libdir" -Wl,-rpath,"$gfortran_libdir"
srun ./openblas_smoke | tee openblas.out
grep -q "OpenBLAS dgemm/dgesv smoke test completed" openblas.out
