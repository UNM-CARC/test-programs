#!/bin/bash -l
# Run this file with: sbatch slurm-test.slurm
# This script compiles and runs a small zlib-ng compatibility API smoke test.
#SBATCH --job-name=test-zlib-ng
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
if [[ -f "$script_dir/zlib-ng/Easley/single-node/slurm-test.slurm" ]]; then
    script_dir="$script_dir/zlib-ng/Easley/single-node"
fi
module purge
module load zlib-ng/2.2.4-xrgr

run_dir="$script_dir/outputs/${SLURM_JOB_NAME}-${SLURM_JOB_ID}"
rm -rf "$run_dir"
mkdir -p "$run_dir"
cd "$run_dir"

cat > zlib_ng_smoke.c <<'EOF'
#include <stdio.h>
#include <string.h>
#include <zlib.h>
int main(void) {
    const unsigned char input[] = "zlib-ng compatibility smoke test";
    unsigned char compressed[128], output[128];
    uLongf clen = sizeof(compressed), olen = sizeof(output);
    if (compress2(compressed, &clen, input, sizeof(input), Z_BEST_COMPRESSION) != Z_OK) return 2;
    if (uncompress(output, &olen, compressed, clen) != Z_OK) return 3;
    if (olen != sizeof(input) || memcmp(input, output, sizeof(input)) != 0) return 4;
    puts("zlib-ng compress/uncompress smoke test completed");
    return 0;
}
EOF
gcc zlib_ng_smoke.c -o zlib_ng_smoke -I"$ZLIB_NG_ROOT/include" -L"$ZLIB_NG_ROOT/lib" -lz
srun ./zlib_ng_smoke | tee zlib-ng.out
grep -q "zlib-ng compress/uncompress smoke test completed" zlib-ng.out
