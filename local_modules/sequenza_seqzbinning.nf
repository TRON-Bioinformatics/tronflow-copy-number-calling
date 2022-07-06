
process SEQUENZAUTILS_SEQZBINNING {
    tag "$meta.id"
    label 'process_medium'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), meta:meta, publish_by_meta:['id']) }

    conda (params.enable_conda ? "bioconda::sequenza-utils=3.0.0" : null)
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
    sequenza-utils \\
        seqz_binning \\
        --seqz $seqz \\
        -o ${prefix}.binned.gz
    """
}