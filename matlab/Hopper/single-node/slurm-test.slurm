#!/usr/bin/env bash
# Run this file with: sbatch slurm-test.slurm
# This script demonstrates MATLAB Parallel Computing Toolbox on one node.

# Slurm resources for a shared-memory MATLAB parallel example.
#SBATCH --job-name=test-matlab-parallel
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err
#SBATCH --partition=debug
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=6G
#SBATCH --time=00:10:00

# fail fast on errors, unset variables, or failed pipeline commands.
set -euo pipefail

# locate this example directory when submitted from the repo root.
script_dir="${SLURM_SUBMIT_DIR:-$PWD}"
if [[ -f "$script_dir/matlab/Hopper/single-node/slurm-test.slurm" ]]; then
    script_dir="$script_dir/matlab/Hopper/single-node"
fi
if [[ -f "$script_dir/matlab/Hopper/single-node/slurm-test.slurm" ]]; then
    script_dir="$script_dir/matlab/Hopper/single-node"
fi

# reset modules and load MATLAB.
module purge
module load matlab/R2024b

# create a clean per-job output directory so runs do not collide.
run_dir="$script_dir/outputs/${SLURM_JOB_NAME}-${SLURM_JOB_ID}"
rm -rf "$run_dir"
mkdir -p "$run_dir"
cd "$run_dir"

# write a MATLAB program that opens a local parallel pool and
# performs one matrix-multiply task per Slurm CPU.
cat > matlab_parallel_test.m <<'EOF'
workers = str2double(getenv('SLURM_CPUS_PER_TASK'));
if isnan(workers) || workers < 1
    workers = 1;
end

pool = gcp('nocreate');
if isempty(pool)
    pool = parpool('local', workers);
end

parts = zeros(workers, 1);
parfor idx = 1:workers
    rng(20260623 + idx);
    A = rand(700, 700);
    B = rand(700, 700);
    C = A * B;
    parts(idx) = sum(C(:));
end

total = sum(parts);
fid = fopen('matlab-parallel.out', 'w');
fprintf(fid, 'workers=%d\n', workers);
fprintf(fid, 'total=%.6f\n', total);
fclose(fid);

assert(isfinite(total) && total > 0);
delete(pool);
exit;
EOF

# run MATLAB in noninteractive batch mode.
matlab -batch "matlab_parallel_test"
# confirm MATLAB used the requested worker count.
grep -q "workers=${SLURM_CPUS_PER_TASK}" matlab-parallel.out
# confirm MATLAB produced a numeric result.
grep -q "total=" matlab-parallel.out
