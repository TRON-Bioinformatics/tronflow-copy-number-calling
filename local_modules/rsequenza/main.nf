process R_SEQUENZA {
    tag "$meta.id"
    label 'process_medium'

    conda (params.enable_conda ? "conda-forge::r-base=4.2.2 bioconda::r-sequenza=3.0.0" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/r-sequenza:3.0.0--r42h3342da4_5' :
        'biocontainers/r-sequenza:3.0.0--r42h3342da4_5' }"

    input:
    tuple val(meta), path(seqz)

    output:
    tuple val(meta), path("*"),     emit: sequenza
    path "versions.yml",            emit: versions

    when:
    task.ext.when == null || task.ext.when

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

    # version export
    f <- file("versions.yml","w")
    sequenza_version = sessionInfo()\$otherPkgs\$sequenza\$Version
    writeLines(paste0('"', "$task.process", '"', ":"), f)
    writeLines(paste("    sequenza:", sequenza_version), f)
    close(f)
    """
}
