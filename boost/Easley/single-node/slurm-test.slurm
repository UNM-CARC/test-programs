#!/bin/bash -l
# Run this file with: sbatch slurm-test.slurm
# This script compiles and runs a small Boost header/library smoke test.
#SBATCH --job-name=test-boost
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
if [[ -f "$script_dir/boost/Easley/single-node/slurm-test.slurm" ]]; then
    script_dir="$script_dir/boost/Easley/single-node"
fi
module purge
module load boost/1.88.0-65dn

run_dir="$script_dir/outputs/${SLURM_JOB_NAME}-${SLURM_JOB_ID}"
rm -rf "$run_dir"
mkdir -p "$run_dir"
cd "$run_dir"

cat > boost_smoke.cpp <<'EOF'
#include <iostream>
#include <boost/algorithm/string.hpp>
#include <boost/container/small_vector.hpp>
int main() {
    std::string value = "  open boost  ";
    boost::algorithm::trim(value);
    boost::container::small_vector<int, 4> values = {1, 2, 3, 4};
    int sum = 0; for (int v : values) sum += v;
    if (value != "open boost" || sum != 10) return 2;
    std::cout << "Boost header/container smoke test completed\n";
    return 0;
}
EOF
g++ -std=c++17 boost_smoke.cpp -o boost_smoke -I"$BOOST_ROOT/include"
srun ./boost_smoke | tee boost.out
grep -q "Boost header/container smoke test completed" boost.out
