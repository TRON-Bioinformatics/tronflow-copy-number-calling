# TronFlow Copy Number Calling: Changelog 

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased] 

### Added 

- [Fork of nf-core/test-datasets repository](https://github.com/TRON-Bioinformatics/nf-core-test-datasets) as a submodule (`tests/nf-core-test-datasets`) to introduce new test dataset provided by nf-core  
- New `--tools` flag with which the tool(s) to be run during pipeline execution can be specified  
- This `CHANGELOG.md` file and documention on old releases as well as recent development  
- `CITATIONS.md` file with citations of all relevant software tools so far  

### Changed 

- Copy git repository from [GitHub](https://github.com/TRON-Bioinformatics/tronflow-copy-number-calling) to [GitLab](https://gitlab.rlp.net/tron/tronflow-copy-number-calling) and continue development there  
- Refactor tests for GitLab CI environment  
- Extract `MERGE_REPLICATES` process from `main.nf` and store it in an individual local module at `local_modules/merge_replicates.nf`  
- Restructure `nextflow.config` based on nf-core's best practices (see [nf-core/sarek](https://github.com/nf-core/sarek))  
- Update time span in `LICENSE` file  

### Fixed 

- Automated test for sequenza by [addind a samtools dependency to module for sequenza](https://github.com/TRON-Bioinformatics/modules/commit/b7c2f13956aa75f9ae2d0433825c9f199c02722e) (in [fork of nf-core/modules](https://github.com/TRON-Bioinformatics/modules))  

### Removed 

- Previous test dataset introduced by Pablo  
- Flags `--skip_cnvkit` and `--skip_sequenza` since they are deprecated and replaced by `--tools` flag  

## [0.2.2](https://gitlab.rlp.net/tron/tronflow-copy-number-calling/-/releases/v0.2.2) - 2023-06-23

### Added 

- Enable the use of mamba in the CI environment  

### Changed 

- Hard code VROOM_SIZE  
- Change nf-core modules git submodule to TRON fork  
- Change test dataset to a mock reference genome that has full chromosomes 6 and 22  

### Fixed 

- Fix R version for sequenza  

## [0.2.1](https://gitlab.rlp.net/tron/tronflow-copy-number-calling/-/releases/v0.2.1) - 2022-10-25

### Added 

- A parameter for the value VROOM_CONNECTION_SIZE environment variable during sequenza execution. Also increases its default value from 50000000 to 500000000. For some samples Sequenza fails when this value is too low.  

## [0.2.0](https://gitlab.rlp.net/tron/tronflow-copy-number-calling/-/releases/v0.2.0) - 2022-07-06

### Added 

- Integrate Sequenza as another copy number caller  

### Changed 

- Change the name from tronflow-cnvkit to tronflow-copy-number-calling  

## [0.1.1](https://gitlab.rlp.net/tron/tronflow-copy-number-calling/-/releases/v0.1.1) - 2022-06-20

### Changed 

- Tentative release increasing the allowed time to create a conda environment  

## [0.1.0](https://gitlab.rlp.net/tron/tronflow-copy-number-calling/-/releases/v0.1.0) - 2022-06-15

First release!
