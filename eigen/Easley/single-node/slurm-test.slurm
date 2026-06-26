#!/bin/bash -l
# Run this file with: sbatch slurm-test.slurm
# This script compiles and runs a small Eigen matrix solve smoke test.
#SBATCH --job-name=test-eigen
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
if [[ -f "$script_dir/eigen/Easley/single-node/slurm-test.slurm" ]]; then
    script_dir="$script_dir/eigen/Easley/single-node"
fi
module purge
module load eigen/3.4.0-4lpz

run_dir="$script_dir/outputs/${SLURM_JOB_NAME}-${SLURM_JOB_ID}"
rm -rf "$run_dir"
mkdir -p "$run_dir"
cd "$run_dir"

cat > eigen_smoke.cpp <<'EOF'
#include <cmath>
#include <iostream>
#include <Eigen/Dense>
int main() {
    Eigen::Matrix2d a;
    a << 3.0, 1.0, 1.0, 2.0;
    Eigen::Vector2d b(9.0, 8.0);
    Eigen::Vector2d x = a.colPivHouseholderQr().solve(b);
    if (std::abs(x[0] - 2.0) > 1e-12 || std::abs(x[1] - 3.0) > 1e-12) return 2;
    std::cout << "Eigen matrix solve smoke test completed\n";
    return 0;
}
EOF
g++ -std=c++17 eigen_smoke.cpp -o eigen_smoke
srun ./eigen_smoke | tee eigen.out
grep -q "Eigen matrix solve smoke test completed" eigen.out
