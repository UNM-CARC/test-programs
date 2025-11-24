# How to use ORCA
ORCA only requires an input file to run. Details on the structure of these files can be found [here](https://www.faccts.de/docs/orca/6.1/manual/contents/essentialelements/input.html).

In general, ORCA only makes use of MPI for parallelization. The number of ranks is determined by both the slurm configuration, and the input file. The number of ranks can be by adding/adjusting the following block in the input file.

```bash
%pal nprocs       32 # or nprocs_world - total number of parallel processes
     nprocs_group  4 #                 - number of parallel processes per sub-task (optional)
     end
```

More information in this can be found [here](https://www.faccts.de/docs/orca/6.1/manual/contents/essentialelements/parallel.html).


# How to run examples
As stated before, ORCA only needs a single input file to work. The examples for Easley and Hopper can be ran by simply submitting the slurm batch script. The input file and configuration takes about 2 hours to run.
