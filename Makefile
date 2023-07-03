SHELL := /bin/bash

all : clean test_00 test_01 test_02

.PHONY: all clean test_00 test_01 test_02

clean:
	rm -rf tests/output
	rm -rf work
	rm -f report*
	rm -f timeline*
	rm -f trace*
	rm -f dag*
	rm -f .nextflow.log*
	rm -rf .nextflow*

test_00:
	bash tests/scripts/run_test_00.sh

test_01:
	bash tests/scripts/run_test_01.sh

test_02:
	bash tests/scripts/run_test_02.sh
