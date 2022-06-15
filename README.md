# TronFlow CNVkit

![GitHub tag (latest SemVer)](https://img.shields.io/github/v/release/tron-bioinformatics/tronflow-cnvkit?sort=semver)
[![Run tests](https://github.com/TRON-Bioinformatics/tronflow-cnvkit/actions/workflows/automated_tests.yml/badge.svg?branch=master)](https://github.com/TRON-Bioinformatics/tronflow-cnvkit/actions/workflows/automated_tests.yml)
[![License](https://img.shields.io/badge/license-MIT-green)](https://opensource.org/licenses/MIT)
[![Powered by Nextflow](https://img.shields.io/badge/powered%20by-Nextflow-orange.svg?style=flat&colorA=E1523D&colorB=007D8A)](https://www.nextflow.io/)

The TronFlow CNVkit pipeline is part of a collection of computational workflows for tumor-normal pair somatic variant calling.

Find the documentation here [![Documentation Status](https://readthedocs.org/projects/tronflow-docs/badge/?version=latest)](https://tronflow-docs.readthedocs.io/en/latest/?badge=latest)


This workflow implements the CNVkit (Talevich, 2016) somatic copy number calling over tumor-normal pairs.
It reuses the modular Nextflow implementation of CNVkit from NF-core (Ewels, 2020).


## How to run it

Run it from GitHub as follows:
```
nextflow run tron-bioinformatics/tronflow-cnvkit -r v0.1.0 -profile conda --input_files $input --reference $fasta --intervals $bed
```

Otherwise download the project and run as follows:
```
nextflow main.nf -profile conda --input_files $input --reference $fasta --intervals $bed
```

Find the help as follows:
```
$ nextflow run tron-bioinformatics/tronflow-cnvkit --help

Usage:
    nextflow run tron-bioinformatics/tronflow-cnvkit -profile conda --input_files input_files --reference reference.fasta --intervals target_region.bed

Input:
    * input_files: the path to a tab-separated values file containing in each row the sample name, tumor bam and normal bam
    The input file does not have header!
    Example input file:
    name1	tumor_bam1	normal_bam1
    name2	tumor_bam2	normal_bam2
    * reference: path to the FASTA genome reference
    * intervals: path to the BED file with the targeted region
    
    
Optional input:
    * output: the output folder
    * cpus: number of reserved CPUs
    * memory: amount of reserved memory

Output:
    * *.antitarget.bed
    * *.target.bed
    * reference.cnn
    * *.tumor.targetcoverage.cnn : binned tumor coverage in target region
    * *.normal.targetcoverage.cnn : binned normal coverage in target region
    * *.tumor.antitargetcoverage.cnn : binned tumor coverage in anti-target region
    * *.normal.antitargetcoverage.cnn : binned normal coverage in ani-target region
    * *.tumor.cnr : copy number ratios
    * *.tumor.call.cns : copy number segments
```


### Input tables

The table with BAM files expects three tab-separated columns without a header.
Multiple tumor or normal BAMs can be provided separated by commas.

| Sample name          | Tumor BAMs                      | Normal BAMs                  |
|----------------------|---------------------------------|------------------------------|
| sample_1             | /path/to/sample_1_tumor.bam      |    /path/to/sample_1_normal.bam   |
| sample_2             | /path/to/sample_2_tumor_1.bam,/path/to/sample_2_tumor_2.bam      |    /path/to/sample_2_normal.bam,/path/to/sample_2_normal_2.bam   |


## References

- Ewels, P. A., Peltzer, A., Fillinger, S., Patel, H., Alneberg, J., Wilm, A., Garcia, M. U., Tommaso, P. Di, & Nahnsen, S. (2020). The nf-core framework for community-curated bioinformatics pipelines. Nature Biotechnology 2020 38:3, 38(3), 276–278. https://doi.org/10.1038/s41587-020-0439-x
- Di Tommaso, P., Chatzou, M., Floden, E. W., Barja, P. P., Palumbo, E., & Notredame, C. (2017). Nextflow enables reproducible computational workflows. Nature Biotechnology, 35(4), 316–319. https://doi.org/10.1038/nbt.3820
- Talevich, E., Shain, A. H., Botton, T., & Bastian, B. C. (2016). CNVkit: Genome-Wide Copy Number Detection and Visualization from Targeted DNA Sequencing. PLOS Computational Biology, 12(4), e1004873. https://doi.org/10.1371/JOURNAL.PCBI.1004873