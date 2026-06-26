#!/usr/bin/env bash

# Alquimia 1.1.0 on Hopper, built with PFLOTRAN v5.0 chemistry support.
# Source this file before compiling or running against this install.

module purge
module load gcc/13.2.0-4u2z
module load openmpi/5.0.3-ttaq
module load petsc/3.20.2-pgyc

export ALQUIMIA_DIR=/opt/local/alquimia/1.1.0
export PFLOTRAN_DIR=/opt/local/pflotran/5.0
export PFLOTRAN_INC="${PFLOTRAN_DIR}/include"
export PFLOTRAN_LIB="${PFLOTRAN_DIR}/lib/libpflotranchem.a"

export PETSC_DIR=/opt/spack/opt/spack/linux-rocky8-cascadelake/gcc-13.2.0/petsc-3.20.2-pgycycjpv2fx562mmmecesisldgkkkjx
unset PETSC_ARCH

export PATH="${ALQUIMIA_DIR}/bin:${PATH}"
export LD_LIBRARY_PATH="${ALQUIMIA_DIR}/lib:${PETSC_DIR}/lib:${LD_LIBRARY_PATH:-}"
