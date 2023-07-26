#!/usr/bin/env bash


### TEST-01: Check the pipeline when running with CNVkit 

echo "#######################################################################################"
echo "# TEST-01: Check the pipeline when running with CNVkit"
echo "#######################################################################################"

## Set up environment

# Set pipeline parameters

test_id="TEST-01"
input=`pwd`"/tests/output/${test_id}/input_${test_id}.tsv"
output=`pwd`"/tests/output/${test_id}"
reference=`pwd`"/tests/nf-core-test-datasets/data/genomics/homo_sapiens/genome/chr21/sequence/genome.fasta"
intervals=`pwd`"/tests/nf-core-test-datasets/data/genomics/homo_sapiens/genome/chr21/sequence/multi_intervals.bed"
tool="cnvkit"

# Create input file for pipeline

sample_id_tum="sample1"

mkdir -p $output

echo -e "${sample_id_tum}\t"`pwd`"/tests/nf-core-test-datasets/data/genomics/homo_sapiens/illumina/bam/test.paired_end.markduplicates.sorted.bam\t"`pwd`"/tests/nf-core-test-datasets/data/genomics/homo_sapiens/illumina/bam/test2.paired_end.markduplicates.sorted.bam" > $input

echo "Success: Input file created"

## Execute pipeline

nextflow run main.nf \
	-profile test,mamba \
	--input_files ${input} \
	--output ${output} \
	--reference ${reference} \
	--intervals ${intervals} \
	--tools ${tool}

if [ $? -eq 1 ]
then
	echo "Fail: Pipeline execution failed with error exit status"
	exit 1
else
	echo "Success: Pipeline execution completed"
fi

## Run output checks

test -s ${output}/${tool}/${sample_id_tum}/reference.cnn || { echo "Error: Missing output file 'reference.cnn' for ${test_id}!"; exit 1; }
test -s ${output}/${tool}/${sample_id_tum}/${sample_id_tum}.tumor.call.cns || { echo "Error: Missing output file '${sample_id_tum}.tumor.call.cns' for ${test_id}!"; exit 1; }
test -s ${output}/${tool}/${sample_id_tum}/multi_intervals.target.bed || { echo "Error: Missing output file 'multi_intervals.target.bed' for ${test_id}!"; exit 1; }
test -s ${output}/${tool}/${sample_id_tum}/multi_intervals.antitarget.bed || { echo "Error: Missing output file 'multi_intervals.antitarget.bed' for ${test_id}!"; exit 1; }

echo "Success: Output files are existing and non-empty"

echo "Success: Test completed"
echo
