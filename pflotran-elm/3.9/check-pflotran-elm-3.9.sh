#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
build_dir="${1:-$PWD}"

PFLOTRAN_ELM_DIR="${PFLOTRAN_ELM_ROOT:?PFLOTRAN_ELM_ROOT is not set}"

echo "PFLOTRAN_ELM_ROOT=${PFLOTRAN_ELM_ROOT}"
echo "CLM_PFLOTRAN_SOURCE_DIR=${CLM_PFLOTRAN_SOURCE_DIR}"
echo "PETSC_DIR=${PETSC_DIR}"
echo "PETSC_ARCH=${PETSC_ARCH:-}"

test -d "$PFLOTRAN_ELM_DIR"
test -d "$CLM_PFLOTRAN_SOURCE_DIR"
test -d "$PETSC_DIR"
for required_file in \
  "$PFLOTRAN_LIB" \
  "$PFLOTRAN_ELM_DIR/include/clm_pflotran_interface_data.mod" \
  "$PFLOTRAN_ELM_DIR/include/pflotran_clm_main_module.mod" \
  "$PFLOTRAN_ELM_DIR/include/material_aux_class.mod" \
  "$PETSC_DIR/include/petscversion.h"
do
  if [[ ! -f "$required_file" ]]; then
    echo "Missing required installed file: $required_file" >&2
    exit 1
  fi
done

grep -Eq "#define[[:space:]]+PETSC_VERSION_MAJOR[[:space:]]+3" "$PETSC_DIR/include/petscversion.h"
grep -Eq "#define[[:space:]]+PETSC_VERSION_MINOR[[:space:]]+9" "$PETSC_DIR/include/petscversion.h"
grep -Eq "#define[[:space:]]+PETSC_VERSION_SUBMINOR[[:space:]]+4" "$PETSC_DIR/include/petscversion.h"

command -v mpif90

mkdir -p "$build_dir"
mpif90 -cpp -I"$PFLOTRAN_ELM_DIR/include" -I"$PETSC_DIR/include" \
  -o "$build_dir/pflotran_elm_smoke" \
  "$script_dir/pflotran_elm_smoke.F90" \
  $PFLOTRAN_LIB

"$build_dir/pflotran_elm_smoke"

echo "PFLOTRAN-ELM validation checks passed."
