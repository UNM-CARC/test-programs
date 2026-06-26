#!/usr/bin/env bash

# PFLOTRAN-ELM 3.9 interface stack on Hopper.
# Source this before compiling code against the installed interface library.

module purge
module use /opt/local/modules
module load pflotran-elm/3.9
