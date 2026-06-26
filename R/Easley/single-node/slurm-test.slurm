#!/usr/bin/env bash
# Run this file with: sbatch slurm-test.slurm
# This script demonstrates a shared-memory parallel R calculation.

# Give the job a recognizable scheduler name; all suite jobs begin with test-.
#SBATCH --job-name=test-r-parallel
# Write standard output to a file named with the job name and Slurm job ID.
#SBATCH --output=%x-%j.out
# Write standard error to a matching file; this helps diagnose failed jobs.
#SBATCH --error=%x-%j.err
# Use the debug partition because this is an instructional/regression test.
#SBATCH --partition=debug
# Request one node for this shared-memory R example.
#SBATCH --nodes=1
# Request one Slurm task; R will fork worker processes inside this task.
#SBATCH --ntasks=1
# Reserve four CPU cores for R's parallel::mclapply call.
#SBATCH --cpus-per-task=4
# Reserve memory for the four R workers and their random-number vectors.
#SBATCH --mem=2G
# Keep the example short; increase this for larger simulations.
#SBATCH --time=00:05:00

# fail fast on errors, unset variables, or failed pipeline commands.
set -euo pipefail

# locate this example directory when submitted either from the
# repository root or from inside R/.
script_dir="${SLURM_SUBMIT_DIR:-$PWD}"
if [[ -f "$script_dir/R/Easley/single-node/slurm-test.slurm" ]]; then
    script_dir="$script_dir/R/Easley/single-node"
fi
if [[ -f "$script_dir/R/Easley/single-node/slurm-test.slurm" ]]; then
    script_dir="$script_dir/R/Easley/single-node"
fi

# reset modules and load the tested R version.
module purge
module load r/4.4.3-wsvf

# create a clean per-job output directory so runs do not collide.
run_dir="$script_dir/outputs/${SLURM_JOB_NAME}-${SLURM_JOB_ID}"
# remove any stale directory with the same job-derived name.
rm -rf "$run_dir"
# create the directory where this job will write files.
mkdir -p "$run_dir"
# run from the per-job directory so generated files stay contained.
cd "$run_dir"

# write a small R program into the run directory. Users can replace
# this here-document with their own R script for real work.
cat > parallel_pi.R <<'EOF'
workers <- as.integer(Sys.getenv("SLURM_CPUS_PER_TASK", "1"))
workers <- max(1L, workers)
samples_per_worker <- 10000000L

set.seed(20260623)
worker_seeds <- sample.int(.Machine$integer.max, workers)

estimate_hits <- function(seed) {
  set.seed(seed)
  x <- runif(samples_per_worker)
  y <- runif(samples_per_worker)
  sum((x * x + y * y) <= 1)
}

hits <- unlist(parallel::mclapply(worker_seeds, estimate_hits, mc.cores = workers))
pi_estimate <- 4 * sum(hits) / (samples_per_worker * workers)

writeLines(sprintf("workers=%d", workers))
writeLines(sprintf("samples=%d", samples_per_worker * workers))
writeLines(sprintf("pi_estimate=%.6f", pi_estimate))

if (abs(pi_estimate - pi) > 0.02) {
  stop("parallel Monte Carlo estimate is outside expected tolerance")
}
EOF

# run the R program. tee saves a copy while still showing output.
Rscript parallel_pi.R | tee r-parallel.out
# confirm the R program used the CPU count requested from Slurm.
grep -q "workers=${SLURM_CPUS_PER_TASK}" r-parallel.out
# confirm the R program produced the expected result line.
grep -q "pi_estimate=" r-parallel.out
