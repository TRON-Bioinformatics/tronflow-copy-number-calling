process SINGLETON_INPUT {
    tag "$meta.id"

    input:
    tuple val(meta), path(input_bam)

    output:
    tuple val(meta), path("${meta.id}.bam")

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    ln -s $input_bam ${meta.id}.bam
    """
}
