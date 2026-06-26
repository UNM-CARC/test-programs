nextflow.enable.dsl=2

params.outdir = params.outdir ?: 'results'

process make_input {
    output:
    path 'numbers.txt'

    script:
    """
    seq 1 1000 > numbers.txt
    """
}

process sum_input {
    input:
    path numbers

    output:
    path 'sum.txt'

    script:
    """
    awk '{s+=\$1} END {print s}' ${numbers} > sum.txt
    """
}

workflow {
    make_input()
    sum_input(make_input.out)
}
