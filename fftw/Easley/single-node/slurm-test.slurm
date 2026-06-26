#!/bin/bash -l
# Run this file with: sbatch slurm-test.slurm
# This script compiles and runs a small FFTW 1D DFT smoke test.
#SBATCH --job-name=test-fftw
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
if [[ -f "$script_dir/fftw/Easley/single-node/slurm-test.slurm" ]]; then
    script_dir="$script_dir/fftw/Easley/single-node"
fi
module purge
module load openmpi/4.1.7-3ilj
module load fftw/3.3.10-wfyy

run_dir="$script_dir/outputs/${SLURM_JOB_NAME}-${SLURM_JOB_ID}"
rm -rf "$run_dir"
mkdir -p "$run_dir"
cd "$run_dir"

cat > fftw_smoke.c <<'EOF'
#include <math.h>
#include <stdio.h>
#include <fftw3.h>
int main(void) {
    fftw_complex in[4], out[4];
    for (int i = 0; i < 4; ++i) { in[i][0] = 0.0; in[i][1] = 0.0; }
    in[0][0] = 1.0;
    fftw_plan plan = fftw_plan_dft_1d(4, in, out, FFTW_FORWARD, FFTW_ESTIMATE);
    if (!plan) return 2;
    fftw_execute(plan);
    for (int i = 0; i < 4; ++i) {
        if (fabs(out[i][0] - 1.0) > 1e-12 || fabs(out[i][1]) > 1e-12) return 3;
    }
    fftw_destroy_plan(plan);
    puts("FFTW 1D DFT smoke test completed");
    return 0;
}
EOF
fftw_libdir="$(pkg-config --variable=libdir fftw3)"
gcc $(pkg-config --cflags fftw3) fftw_smoke.c -o fftw_smoke $(pkg-config --libs fftw3) -Wl,-rpath,"$fftw_libdir" -lm
srun ./fftw_smoke | tee fftw.out
grep -q "FFTW 1D DFT smoke test completed" fftw.out
