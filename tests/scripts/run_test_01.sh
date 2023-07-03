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
cnv_tool="cnvkit"
skip_sequenza=true

# Create input file for pipeline

sample_id_tum="sample1"

mkdir -p $output

echo -e "${sample_id_tum}\t"`pwd`"/tests/data/tumor_WES.downsampled_0001.bam\t"`pwd`"/tests/data/normal_WES.downsampled_0001.bam" > $input

echo "Success: Input file created"

## Execute pipeline

nextflow run main.nf \
	-profile mamba,test \
	--input_files ${input} \
	--output ${output} \
	--skip_sequenza ${skip_sequenza}

if [ $? -eq 1 ]
then
	echo "Fail: Pipeline execution failed with error exit status"
	exit 1
else
	echo "Success: Pipeline execution completed"
fi

## Run output checks

test -s ${output}/${cnv_tool}/reference.cnn || { echo "Error: Missing output file 'reference.cnn' for ${test_id}!"; exit 1; }
test -s ${output}/${cnv_tool}/${sample_id_tum}.tumor.call.cns || { echo "Error: Missing output file '${sample_id_tum}.tumor.call.cns' for ${test_id}!"; exit 1; }
test -s ${output}/${cnv_tool}/minimal_intervals.target.bed || { echo "Error: Missing output file 'minimal_intervals.target.bed' for ${test_id}!"; exit 1; }
test -s ${output}/${cnv_tool}/minimal_intervals.antitarget.bed || { echo "Error: Missing output file 'minimal_intervals.antitarget.bed' for ${test_id}!"; exit 1; }

echo "Success: Output files are existing and non-empty"

echo "Success: Test completed"
echo
