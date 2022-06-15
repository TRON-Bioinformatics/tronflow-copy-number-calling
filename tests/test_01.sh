#!/bin/bash


source tests/assert.sh
output=output/test1
echo -e "sample1\t"`pwd`"/test_data/TESTX_S1_L001.bam\t"`pwd`"/test_data/TESTX_S1_L003.bam" > test_data/test_input.txt
nextflow main.nf -profile test,conda --output $output --input_files test_data/test_input.txt

test -s $output/reference.cnn || { echo "Missing output reference!"; exit 1; }
test -s $output/sample1.tumor.call.cns || { echo "Missing output calls!"; exit 1; }
test -s $output/minimal_intervals.target.bed || { echo "Missing output target!"; exit 1; }
test -s $output/minimal_intervals.antitarget.bed || { echo "Missing output antitarget!"; exit 1; }
