#!/usr/bin/env bash
# Run this file with: sbatch slurm-test.slurm
# This script demonstrates Spark local-mode parallelism inside one Slurm job.

# Slurm resources for a small local Spark wordcount example.
#SBATCH --job-name=test-spark-wordcount
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err
#SBATCH --partition=debug
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=4G
#SBATCH --time=00:05:00

# fail fast on errors, unset variables, or failed pipeline commands.
set -euo pipefail

# locate this example directory when submitted from the repo root.
script_dir="${SLURM_SUBMIT_DIR:-$PWD}"
if [[ -f "$script_dir/spark/Easley/single-node/slurm-test.slurm" ]]; then
    script_dir="$script_dir/spark/Easley/single-node"
fi
if [[ -f "$script_dir/spark/Easley/single-node/slurm-test.slurm" ]]; then
    script_dir="$script_dir/spark/Easley/single-node"
fi

# reset modules and load the working Spark module.
module purge
module load spark/3.5.1-kn2k

# create a clean per-job output directory so runs do not collide.
run_dir="$script_dir/outputs/${SLURM_JOB_NAME}-${SLURM_JOB_ID}"
rm -rf "$run_dir"
mkdir -p "$run_dir"
cd "$run_dir"

# write a tiny text input for the wordcount job.
cat > input.txt <<'EOF'
spark makes distributed data processing approachable
spark maps words across workers
slurm allocates the cores spark uses
EOF

# write a small PySpark wordcount application.
cat > wordcount.py <<'EOF'
import sys
from operator import add
from pyspark.sql import SparkSession

spark = SparkSession.builder.appName("QuickBytesWordCount").getOrCreate()
sc = spark.sparkContext

counts = (
    sc.textFile(sys.argv[1])
    .flatMap(lambda line: line.split())
    .map(lambda word: (word.lower(), 1))
    .reduceByKey(add)
    .collect()
)

with open("wordcount.out", "w", encoding="utf-8") as handle:
    for word, count in sorted(counts):
        handle.write(f"{word}\t{count}\n")

spark.stop()
EOF

# run Spark in local mode with worker count from Slurm CPUs.
"${SPARK_BIN}/spark-submit" --master "local[${SLURM_CPUS_PER_TASK}]" wordcount.py input.txt
# confirm Spark counted the word "spark" three times.
grep -q $'spark\t3' wordcount.out
# confirm Spark counted the word "slurm" once.
grep -q $'slurm\t1' wordcount.out
