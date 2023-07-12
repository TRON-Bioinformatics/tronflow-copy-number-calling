
process MERGE_REPLICATES {
    tag "$meta.id"
    label 'process_low'

    conda (params.enable_conda ? 'bioconda::samtools=1.15.1' : null)

    input:
    tuple val(meta), val(tumor), val(normal)

    output:
    tuple val(meta), path("${meta.id}.tumor.bam"), path("${meta.id}.normal.bam"), emit: merged_bams

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
