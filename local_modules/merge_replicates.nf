
process MERGE_REPLICATES {
    tag "$meta.id"
    label 'process_low'

    conda (params.enable_conda ? 'bioconda::samtools=1.17' : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/samtools:1.17--h00cdaf9_0' :
        'biocontainers/samtools:1.17--h00cdaf9_0' }"

    input:
    tuple val(meta), val(tumor), val(normal)

    output:
    tuple val(meta), path("${meta.id}.tumor.bam"), path("${meta.id}.normal.bam"),   emit: merged_bams
    path "versions.yml",                                                            emit: versions

    script:
    if (tumor.contains(',')) {
        tumor_inputs = tumor.split(",").join(" ")
        tumor_merge_cmd = "samtools merge ${meta.id}.tumor.bam ${tumor_inputs}"
    }
    else {
        tumor_merge_cmd = "cp ${tumor} ${meta.id}.tumor.bam"
    }

    if (normal.contains(',')) {
        normal_inputs = normal.split(",").join(" ")
        normal_merge_cmd = "samtools merge ${meta.id}.normal.bam ${normal_inputs}"
    }
    else {
        normal_merge_cmd = "cp ${normal} ${meta.id}.normal.bam"
    }
    """
    ${tumor_merge_cmd}
    ${normal_merge_cmd}
    """
}
