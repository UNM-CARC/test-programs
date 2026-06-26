# PFLOTRAN-ELM 3.9 Hopper Validation

Purpose: lightweight Slurm validation for Miranda Noonan's PFLOTRAN-ELM interface stack on Hopper.

Installed paths:

- PFLOTRAN-ELM interface: `/opt/local/pflotran-elm/3.9`
- PETSc dependency: `/opt/local/petsc/3.9.4`
- Setup script installed with the stack: `/opt/local/pflotran-elm/3.9/setup-pflotran-elm.sh`

Build environment expected by this stack:

- `pflotran-elm/3.9`
- PETSc `3.9.4`
- `PETSC_ARCH` unset

Validation performed by `validate-pflotran-elm-3.9.sbatch`:

- Loads the PFLOTRAN-ELM module stack.
- Confirms `PETSC_DIR`, `CLM_PFLOTRAN_SOURCE_DIR`, and `PFLOTRAN_ELM_DIR` resolve to existing paths.
- Confirms `libpflotran.a` exists in both the source and installed library locations.
- Confirms key PFLOTRAN-ELM module files exist, including `clm_pflotran_interface_data.mod`, `pflotran_clm_main_module.mod`, and `material_aux_class.mod`.
- Confirms PETSc headers report version `3.9.4`.
- Builds and runs `pflotran_elm_smoke.F90`, a tiny Fortran driver that initializes PETSc, uses the PFLOTRAN-ELM CLM interface data module, sets a 1 x 1 x 1 mapped CLM grid, and links against `libpflotran.a`.

Example use:

```bash
cd /carc/scratch/projects/mfricke/mfricke2016402/test-programs/pflotran-elm/3.9
sbatch validate-pflotran-elm-3.9.sbatch
```

A successful validation log contains both `PFLOTRAN-ELM smoke test linked and initialized PETSc.` and `PFLOTRAN-ELM validation checks passed.` The generated Slurm output file is named `pflotran-elm-3.9-test-<jobid>.out`.
