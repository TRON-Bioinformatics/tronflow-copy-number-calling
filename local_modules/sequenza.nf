
process SEQUENZAUTILS_SEQZBINNING {
    tag "$meta.id"

    conda (params.enable_conda ? "python=3.9.13 bioconda::sequenza-utils=3.0.0" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/sequenza-utils:3.0.0--py38h6ed170a_2"
    } else {
        container "quay.io/biocontainers/sequenza-utils:3.0.0--py38h6ed170a_2"
    }

    input:
    tuple val(meta), path(seqz)

    output:
    tuple val(meta), path("*.binned.gz"), emit: seqz

    script:
    def prefix = "${meta.id}"
    """
    mamba list
    sequenza-utils \\
        seqz_binning \\
        --seqz $seqz \\
        -o ${prefix}.binned.gz
    """
}

process SEQUENZA_R {
    tag "$meta.id"

    conda (params.enable_conda ? "conda-forge::r-base=4.2.2 bioconda::r-sequenza=3.0.0" : null)

    input:
    tuple val(meta), path(seqz)

    output:
    tuple val(meta), path("*"), emit: sequenza

    script:
    """
    #!/usr/bin/env Rscript

    library(sequenza)

    Sys.setenv(VROOM_CONNECTION_SIZE = "131072000")

    seqz <- sequenza.extract(file="${seqz}", verbose = FALSE)
    #data.file <-  system.file("extdata", "example.seqz.txt.gz", package = "sequenza")
    #seqz <- sequenza.extract(data.file, verbose = FALSE)

    CP <- sequenza.fit(seqz)
    sequenza.results(sequenza.extract=seqz, cp.table=CP, sample.id="${meta.id}", out.dir=".")
    """
}
