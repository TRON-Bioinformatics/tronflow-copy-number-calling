#!/usr/bin/env bash


### TEST-00: Check the help message of the pipeline

echo "#######################################################################################"
echo "# TEST-00: Check the help message of the pipeline"
echo "#######################################################################################"

nextflow main.nf --help

if [ $? -eq 1 ]
then
	echo "Fail: Test failed with error exit status"
	exit 1
else
	echo "Success: Test completed"
	echo
fi
