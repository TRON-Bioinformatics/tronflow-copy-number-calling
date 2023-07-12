#!/usr/bin/env bash


### TEST-02: Check the pipeline when running with Sequenza 

echo "#######################################################################################"
echo "# TEST-02: Check the pipeline when running with Sequenza"
echo "#######################################################################################"

## Set up environment

# Set pipeline parameters

test_id="TEST-02"
input=`pwd`"/tests/output/${test_id}/input_${test_id}.tsv"
output=`pwd`"/tests/output/${test_id}"
reference=`pwd`"/tests/nf-core-test-datasets/data/genomics/homo_sapiens/genome/chr21/sequence/genome.fasta"
intervals=`pwd`"/tests/nf-core-test-datasets/data/genomics/homo_sapiens/genome/chr21/sequence/multi_intervals.bed"
tool="sequenza"

# Create input file for pipeline

sample_id_tum="sample1"

mkdir -p $output

echo -e "${sample_id_tum}\t"`pwd`"/tests/nf-core-test-datasets/data/genomics/homo_sapiens/illumina/bam/test.paired_end.markduplicates.sorted.bam\t"`pwd`"/tests/nf-core-test-datasets/data/genomics/homo_sapiens/illumina/bam/test2.paired_end.markduplicates.sorted.bam" > $input

echo "Success: Input file created"

## Execute pipeline

nextflow run main.nf \
	-profile mamba,test \
	--input_files ${input} \
	--output ${output} \
	--reference ${reference} \
	--intervals ${intervals} \
	--tool ${tool}

if [ $? -eq 1 ]
then
	echo "Fail: Pipeline execution failed with error exit status"
	exit 1
else
	echo "Success: Pipeline execution completed"
fi

## Run output checks

test -s ${output}/${tool}/${sample_id_tum}.gz || { echo "Error: Missing output file '${sample_id_tum}.gz' for ${test_id}!"; exit 1; }
test -s ${output}/${tool}/${sample_id_tum}.binned.gz || { echo "Error: Missing output file '${sample_id_tum}.binned.gz' for ${test_id}!"; exit 1; }

echo "Success: Output files are existing and non-empty"

echo "Success: Test completed"
echo
