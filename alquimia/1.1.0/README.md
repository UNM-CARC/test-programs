# Alquimia 1.1.0 Hopper Install Notes

Purpose: Alquimia with PFLOTRAN chemistry support for Miranda Noonan's PFLOTRAN/PETSc/Alquimia workflow.

Installed paths:

- Alquimia: `/opt/local/alquimia/1.1.0`
- PFLOTRAN chemistry dependency: `/opt/local/pflotran/5.0`
- PFLOTRAN-ELM legacy stack remains separate: `/opt/local/pflotran-elm/3.9`

Source versions:

- Alquimia: `LBL-EESA/alquimia-dev`, tag `v1.1.0`, commit `211931c3e76b1ae7cdb48c46885b248412d6fe3d`
- PFLOTRAN chemistry dependency: upstream PFLOTRAN tag `v5.0`, commit `a2104cedea1528a00aa2718572d43a4461019c60`

Build environment:

- `gcc/13.2.0-4u2z`
- `openmpi/5.0.3-ttaq`
- `petsc/3.20.2-pgyc`
- `PETSC_ARCH` unset

Compatibility note:

Alquimia `v1.1.0` expects the upstream PFLOTRAN v5-style module API, including `material_aux_module.mod`, `reaction_base_module.mod`, and `reaction_rt_type`. PFLOTRAN-ELM `3.9` requires PETSc `3.9.4` and does not expose the newer PFLOTRAN API expected by this Alquimia release. The PFLOTRAN-ELM `2020` branch still exposes `material_aux_class.mod`, not `material_aux_module.mod`, so it is not compatible with unmodified Alquimia `v1.1.0`.

Validation:

- Alquimia configured, built, and installed successfully against `/opt/local/pflotran/5.0/lib/libpflotranchem.a`.
- Runtime linkage of `/opt/local/alquimia/1.1.0/lib/libalquimia.so` resolves to PETSc `3.20.2`.
- Use `validate-alquimia-1.1.0.sbatch` in this directory for Slurm validation. It copies the bundled `batch_chem_calcite_short` inputs into a per-job run directory and runs `batch_chem` through `srun -n 1`.

Example use:

```bash
cd /carc/scratch/projects/mfricke/mfricke2016402/test-programs/alquimia/1.1.0
sbatch validate-alquimia-1.1.0.sbatch
```

A successful validation log contains `Success!` and prints the run directory path. The generated Slurm output file is named `alquimia-1.1.0-test-<jobid>.out`.
