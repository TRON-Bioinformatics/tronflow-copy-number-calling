#!/usr/bin/env nextflow


nextflow.enable.dsl = 2

include { CNVKIT_BATCH } from './modules/modules/nf-core/cnvkit/batch/main'
include { SEQUENZAUTILS_GCWIGGLE } from './modules/modules/nf-core/sequenzautils/gcwiggle/main'
include { SEQUENZAUTILS_BAM2SEQZ } from './modules/modules/nf-core/sequenzautils/bam2seqz/main'
include { SEQUENZAUTILS_SEQZBINNING; SEQUENZA_R } from './local_modules/sequenza'


def helpMessage() {
    log.info params.help_message
}

if (params.help) {
    helpMessage()
    exit 0
}

if (!params.reference) {
    log.error "--reference is required"
    exit 1
}

if (! params.input_files) {
  exit 1, "--input_files is required!"
}
else {
  Channel
    .fromPath(params.input_files)
    .splitCsv(header: ['name', 'tumor_bam', 'normal_bam'], sep: "\t")
    .map{ row-> tuple([id: row.name], row.tumor_bam, row.normal_bam) }
    .set { input_files }
}

process CHECK_INPUTS {
    debug true
    tag "$meta.id"
    label 'process_low'

    input:
    tuple val(meta), val(tumor), val(normal)
    val(reference)

    output:
    tuple val(meta), path("finished.txt")

    script:
    """
    echo "[ DEBUG ] Tumor"
    md5sum $tumor
    echo "[ DEBUG ] Normal"
    md5sum $normal
    echo "[ DEBUG ] Reference"
    md5sum $reference
    head -n 100 $reference
    touch finished.txt
    """
}

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

workflow {
    CHECK_INPUTS(input_files, params.reference)
    MERGE_REPLICATES(input_files)
    merged_bams = MERGE_REPLICATES.out.merged_bams

    if (!params.skip_cnvkit) {
        // NOTE: it does not provide fasta.fai or CNVkit reference, but these are created every time
        CNVKIT_BATCH(merged_bams, params.reference, [], params.intervals, [], false)
    }

    if (!params.skip_sequenza) {
        SEQUENZAUTILS_GCWIGGLE([[id:'reference'], params.reference])
        wig = SEQUENZAUTILS_GCWIGGLE.out.wig.map { it[1] }

        SEQUENZAUTILS_BAM2SEQZ(merged_bams, params.reference, wig)

        if (!params.testmode) {
            SEQUENZAUTILS_SEQZBINNING(SEQUENZAUTILS_BAM2SEQZ.out.seqz)
            SEQUENZA_R(SEQUENZAUTILS_SEQZBINNING.out.seqz)
        } 
        else {
            SEQUENZA_R(SEQUENZAUTILS_BAM2SEQZ.out.seqz)
        }
    }
}
