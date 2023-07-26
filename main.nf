#!/usr/bin/env nextflow


nextflow.enable.dsl = 2

include { SINGLETON_INPUT } from './local_modules/singleton_input/main'
include { SAMTOOLS_MERGE } from './nf-core-modules/modules/nf-core/samtools/merge/main'
include { CNVKIT_BATCH } from './nf-core-modules/modules/nf-core/cnvkit/batch/main'
include { SEQUENZAUTILS_GCWIGGLE } from './nf-core-modules/modules/nf-core/sequenzautils/gcwiggle/main'
include { SEQUENZAUTILS_BAM2SEQZ } from './nf-core-modules/modules/nf-core/sequenzautils/bam2seqz/main'
//include { MERGE_REPLICATES } from './local_modules/merge_replicates'
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
    .splitCsv(header: ['sample', 'tumor_bam', 'normal_bam'], sep: "\t")
    .map{ row-> tuple([id: row.sample], row.tumor_bam, row.normal_bam) }
    .set { input_files }
}

workflow {

    tumor_bams = input_files
        .map { 
            meta, tumor_bam, normal_bam -> 
            def fmeta = [:]
            fmeta.id = meta.id + ".tumor"
            fmeta.type = "tumor"
            [fmeta, tumor_bam.tokenize(',')] 
        }
        .branch{
            single: it[1].size() == 1
            multiple: it[1].size() > 1
        }

    normal_bams = input_files
        .map { 
            meta, tumor_bam, normal_bam -> 
            def fmeta = [:]
            fmeta.id = meta.id + ".normal"
            fmeta.type = "normal"
            [fmeta, normal_bam.tokenize(',')] 
        }
        .branch{
            single: it[1].size() == 1
            multiple: it[1].size() > 1
        }

    SINGLETON_INPUT(tumor_bams.single.mix(normal_bams.single))

    SAMTOOLS_MERGE(
        tumor_bams.multiple.mix(normal_bams.multiple),
        [[], []],
        [[], []]
    )

    prepared_tumor_bams = SINGLETON_INPUT.out
        .filter { it[0].type == "tumor" }
        .mix(
            SAMTOOLS_MERGE.out.bam
                .filter { it[0].type == "tumor" }
        ).map {
            meta, bam ->
            def fmeta = [:]
            fmeta.id = meta.id[0..-(meta.type.length() + 2)]
            [fmeta, bam]
        }

    prepared_normal_bams = SINGLETON_INPUT.out
        .filter { it[0].type == "normal" }
        .mix(
            SAMTOOLS_MERGE.out.bam
                .filter { it[0].type == "normal" }
        ).map {
            meta, bam ->
            def fmeta = [:]
            fmeta.id = meta.id[0..-(meta.type.length() + 2)]
            [fmeta, bam]
        }

    ch_meta_tumor_normal = prepared_tumor_bams
        .join(prepared_normal_bams, by: [0])

    if (params.toolslist.contains('cnvkit')) {
        // NOTE: it does not provide fasta.fai or CNVkit reference, but these are created every time
        CNVKIT_BATCH(
            ch_meta_tumor_normal,
            params.reference, 
            [], 
            params.intervals, 
            [], 
            false
        )
    }

    if (params.toolslist.contains('sequenza')) {
        SEQUENZAUTILS_GCWIGGLE([[id:'reference'], params.reference])
        wig = SEQUENZAUTILS_GCWIGGLE.out.wig.map { it[1] }

        SEQUENZAUTILS_BAM2SEQZ(ch_meta_tumor_normal, params.reference, wig)

        SEQUENZAUTILS_SEQZBINNING(SEQUENZAUTILS_BAM2SEQZ.out.seqz)
        
        R_SEQUENZA(SEQUENZAUTILS_SEQZBINNING.out.seqz)
    }
}
