# TronFlow Copy Number Calling 

![GitHub tag (latest SemVer)](https://img.shields.io/github/v/release/tron-bioinformatics/tronflow-copy-number-calling?sort=semver)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.7248131.svg)](https://doi.org/10.5281/zenodo.7248131)
[![Run tests](https://github.com/TRON-Bioinformatics/tronflow-copy-number-calling/actions/workflows/automated_tests.yml/badge.svg?branch=master)](https://github.com/TRON-Bioinformatics/tronflow-copy-number-calling/actions/workflows/automated_tests.yml)
[![License](https://img.shields.io/badge/license-MIT-green)](https://opensource.org/licenses/MIT)
[![Powered by Nextflow](https://img.shields.io/badge/powered%20by-Nextflow-orange.svg?style=flat&colorA=E1523D&colorB=007D8A)](https://www.nextflow.io/)
[![run with conda](https://img.shields.io/badge/run%20with-conda-3EB049?labelColor=000000&logo=anaconda)](https://docs.conda.io/en/latest/)

> **The TronFlow Copy Number Calling pipeline is part of a collection of computational workflows for tumor-normal pair somatic variant calling. Discover other TronFlow workflows at the [TRON-Bioinformatics GitHub page](https://github.com/TRON-Bioinformatics).** 

Find the documentation here [![Documentation Status](https://readthedocs.org/projects/tronflow-docs/badge/?version=latest)](https://tronflow-docs.readthedocs.io/en/latest/?badge=latest)

## Introduction  

**TronFlow Copy Number Calling** is a workflow created to detect copy number variations (CNVs) on whole-exome sequencing data from human tumor-normal pairs. 

The pipeline is built using [Nextflow](https://www.nextflow.io), a workflow management tool that "enables scalable and reproducible scientific workflows using software containers" (Di Tommaso et al., 2017). In particular, Nextflow's [DSL2 syntax extension](https://www.nextflow.io/docs/latest/dsl2.html) is applied which enables the usage of module libraries and therefore eases the process of creating complex data analysis pipelines. Taking advantage of this feature, the pipeline re-uses modular Nextflow implementations from [nf-core/modules](https://github.com/nf-core/modules) (Ewels et al., 2020) if available. Furthermore, the pipeline employs a comprehensive collection of test datasets from [nf-core/test-datasets](https://github.com/nf-core/test-datasets) for continuous integration tests. 

## Pipeline summary 

This workflow integrates the following tools for somatic copy number calling based on tumor-normal pairs:  

- CNVkit (Talevich et al., 2016)  
- Sequenza (Favero et al., 2015)  
- More coming soon...  

A selection of one (or multiple) tool(s) can be achieved using the `--tools` flag. For more information about the pipeline's usage, please continue reading [here](#usage). 

## Usage 

### Software requirements 

Minimum requirements: 

- `java >= 11`: We recommend using [SDKMAN!](https://sdkman.io/) for installation of the Java SDK. See also [here](https://www.nextflow.io/docs/latest/getstarted.html#requirements) for nextflow specific instructions.  
- `nextflow >= 19.10.0`: We recommend using the latest stable release of nextflow. For installation instructions please see also [here](https://www.nextflow.io/docs/latest/getstarted.html#installation).  
- `conda`: We recommend using [`mamba`](https://mamba.readthedocs.io/en/latest/installation.html) as a faster alternative.  

### Input table 

First, create a samplesheet with your input data that complies to the following format: 

`input_files.tsv`: 

```
sample_1<TAB>/path/to/sample_1_tumor.bam<TAB>/path/to/sample_1_normal.bam
sample_2<TAB>/path/to/sample_2_tumor_1.bam,/path/to/sample_2_tumor_2.bam<TAB>/path/to/sample_2_normal_1.bam,/path/to/sample_2_normal_2.bam
```

> **Note**
> The pipeline expects a file containing three tab-separated columns without a header. Each row represents a pair of tumor and normal BAM files. Multiple tumor or normal BAM files (i.e. replicates) can be provided separated by commas. The BAM files need to be sorted and indexed. 

### How to run the pipeline 

Option 1: Run it from GitHub as follows...

```bash
$ nextflow run tron-bioinformatics/tronflow-copy-number-calling -r <RELEASE|BRANCH> -profile conda --input_files <YOUR_INPUT_FILE> --reference <YOUR_REFERENCE_FASTA> --intervals <YOUR_TARGET_REGIONS_BED> --tools cnvkit,sequenza
```

Option 2: Download the project and run it as follows...

```bash
$ nextflow run main.nf -profile conda --input_files <YOUR_INPUT_FILE> --reference <YOUR_REFERENCE_FASTA> --intervals <YOUR_TARGET_REGIONS_BED> --tools cnvkit,sequenza
```

See help message for all of the available options when running the pipeline: 

```
$ nextflow run main.nf --help

TronFlow Copy Number Calling <REVISION>

Nextflow pipeline for copy number calling using different tools

Usage:
    nextflow run main.nf -profile conda --input_files input_files.tsv --reference reference.fasta --intervals target_region.bed --tools cnvkit,sequenza

Input:
    * input_files: the path to a tab-separated values file containing in each row the sample name, tumor bam and normal bam
    The input file does not have header!
    Example input file:
    name1	tumor_bam1	normal_bam1
    name2	tumor_bam2	normal_bam2
    * reference: path to the FASTA genome reference
    * intervals: path to the BED file with the targeted region
    * tools: tools to perform CN calling with (single and multiple entries possible, use ',' as delimiter) [ cnvkit, sequenza ]

Optional input:
    * output: the folder where to publish output (default: output)
    * VROOM_CONNECTION_SIZE: value for the environment variable VROOM_CONNECTION_SIZE which sometimes causes trouble with sequenza (default: 500000000)
    * cpus: the number of CPUs used by each job (default: 1)
    * memory: the amount of memory used by each job (default: 4g)

Output:
    CNVkit:  
    * cnvkit/*.antitarget.bed : antitarget regions  
    * cnvkit/*.target.bed : target regions  
    * cnvkit/reference.cnn  
    * cnvkit/*.tumor.targetcoverage.cnn : binned tumor coverage in target region  
    * cnvkit/*.normal.targetcoverage.cnn : binned normal coverage in target region  
    * cnvkit/*.tumor.antitargetcoverage.cnn : binned tumor coverage in anti-target region  
    * cnvkit/*.normal.antitargetcoverage.cnn : binned normal coverage in ani-target region  
    * cnvkit/*.tumor.bintest.cns  
    * cnvkit/*.tumor.cnr : copy number ratios  
    * cnvkit/*.tumor.cns  
    * cnvkit/*.tumor.call.cns : copy number segments  
    Sequenza:  
    * sequenza/*.gz
    * sequenza/*.binned.gz  
    * sequenza/*_alternative_solutions.txt  
    * sequenza/*_confints_CP.txt  
    * sequenza/*_segments.txt  
    * sequenza/*_sequenza_log.txt : sequenza log file  
    * sequenza/*_alternative_fit.pdf  
    * sequenza/*_chromosome_depths.pdf  
    * sequenza/*_chromosome_view.pdf  
    * sequenza/*_CN_bars.pdf  
    * sequenza/*_CP_contours.pdf
    * sequenza/*_gc_plots.pdf  
    * sequenza/*_genome_view.pdf
    * sequenza/*_model_fit.pdf  
    * sequenza/*_sequenza_cp_table.RData  
    * sequenza/*_sequenza_extract.RData  

```

## Pipeline output 

More details will be provided soon...

## Current limitations 

- So far, there are no nf-core modules for Sequenza processes `SEQUENZAUTILS_SEQZBINNING` and `SEQUENZA_R`. Therefore, these steps are implemented locally.  

## Roadmap 

Features that will be implemented in the future are listed here:

- [ ] Add [ascat](https://github.com/VanLoo-lab/ascat) as CNV calling tool  
- [ ] Add [FACETS](https://github.com/mskcc/facets) as CNV calling tool  
- [ ] Add [TITAN](https://github.com/gavinha/TitanCNA) as CNV calling tool  

## Authors & Acknowledgements 

The TronFlow Copy Number Calling pipeline was originally developed by Pablo Riesgo-Ferreiro at [TRON - Translational Oncology at the Medical Center of the Johannes Gutenberg University Mainz gGmbH (non-profit)](https://tron-mainz.de/). Julian T. Mohr, also at TRON, later joined the project and helped with further development and integration of additional CNV calling tools. Furthermore, Jonas Ibn-Salem and Matthias Peter, also at TRON, supported the project. 

Maintenance is now lead by Pablo Riesgo-Ferreiro and Julian T. Mohr. 

Main developers: 

- [Pablo Riesgo-Ferreiro](mailto:Pablo.RiesgoFerreiro@TRON-Mainz.DE)  
- [Julian T. Mohr](mailto:Julian.Mohr@TRON-Mainz.de)  

We thank the following people for their assistance and support in the development of this pipeline: 

- Jonas Ibn-Salem  
- Matthias Peter  

## Contributing & Support 

If you would like to contribute to this pipeline, please see the [contributing guidelines](CONTRIBUTING.md). 

Please report issues using the [issue tracker of GitHub](https://github.com/TRON-Bioinformatics/tronflow-copy-number-calling/issues). 

## Citations 

If you use `TronFlow Copy Number Calling` for your analysis, please cite the Zenodo record for a specific version using the following [doi: 10.5281/zenodo.7248131](https://doi.org/10.5281/zenodo.7248131)

An extensive list of references for the tools used by the pipeline can be found in the [`CITATIONS.md`](CITATIONS.md) file. 

## CHANGELOG 

- [CHANGELOG](CHANGELOG.md)
