#!/usr/bin/env nextflow


nextflow.enable.dsl = 2

include { CNVKIT_BATCH } from './nf-core-modules/modules/nf-core/cnvkit/batch/main'
include { SEQUENZAUTILS_GCWIGGLE } from './nf-core-modules/modules/nf-core/sequenzautils/gcwiggle/main'
include { SEQUENZAUTILS_BAM2SEQZ } from './nf-core-modules/modules/nf-core/sequenzautils/bam2seqz/main'
include { MERGE_REPLICATES } from './local_modules/merge_replicates'
include { SEQUENZAUTILS_SEQZBINNING } from './local_modules/sequenzautils/seqzbinning/main'
include { R_SEQUENZA } from './local_modules/rsequenza/main'

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

if (!params.intervals) {
    log.error "--intervals is required"
    exit 1
}

if (!params.tools) {
    log.error "--tools is required"
    exit 1
}
else {
    params.toolslist = params.tools?.split(',') as List
}

if (!params.input_files) {
  exit 1, "--input_files is required!"
}
else {
  Channel
    .fromPath(params.input_files)
    .splitCsv(header: ['name', 'tumor_bam', 'normal_bam'], sep: "\t")
    .map{ row-> tuple([id: row.name], row.tumor_bam, row.normal_bam) }
    .set { input_files }
}

workflow {
    MERGE_REPLICATES(input_files)
    merged_bams = MERGE_REPLICATES.out.merged_bams

    if (params.toolslist.contains('cnvkit')) {
        // NOTE: it does not provide fasta.fai or CNVkit reference, but these are created every time
        CNVKIT_BATCH(merged_bams, params.reference, [], params.intervals, [], false)
    }

    if (params.toolslist.contains('sequenza')) {
        SEQUENZAUTILS_GCWIGGLE([[id:'reference'], params.reference])
        wig = SEQUENZAUTILS_GCWIGGLE.out.wig.map { it[1] }

        SEQUENZAUTILS_BAM2SEQZ(merged_bams, params.reference, wig)

        SEQUENZAUTILS_SEQZBINNING(SEQUENZAUTILS_BAM2SEQZ.out.seqz)
        
        R_SEQUENZA(SEQUENZAUTILS_SEQZBINNING.out.seqz)
    }
}
