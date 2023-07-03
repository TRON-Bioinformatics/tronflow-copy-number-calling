#!/bin/bash


source tests/scripts/assert.sh
output=tests/output/test01
echo -e "sample1\t"`pwd`"tests/data/tumor_WES.downsampled_0001.bam\t"`pwd`"tests/data/normal_WES.downsampled_0001.bam" > tests/output/test01/test_input.tsv
nextflow main.nf -profile test,mamba --output $output --input_files tests/output/test01/test_input.tsv --skip_sequenza

# CNVkit output
test -s $output/cnvkit/reference.cnn || { echo "Missing output reference!"; exit 1; }
test -s $output/cnvkit/sample1.tumor.call.cns || { echo "Missing output calls!"; exit 1; }
test -s $output/cnvkit/minimal_intervals.target.bed || { echo "Missing output target!"; exit 1; }
test -s $output/cnvkit/minimal_intervals.antitarget.bed || { echo "Missing output antitarget!"; exit 1; }

# Sequenza output
#test -s $output/sequenza/sample1.gz || { echo "Missing output sequenza SEQZ!"; exit 1; }
#test -s $output/sequenza/sample1.binned.gz || { echo "Missing output sequenza binned SEQZ!"; exit 1; }
