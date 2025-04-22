# MultiType Variant Pipeline (NGS, Docker, Nextflow)

A full-featured variant analysis pipeline for WGS data using Docker + Nextflow. It detects SNPs, Indels, CNVs, SVs, and annotates variants using ANNOVAR. Generates an interactive HTML report.

## 📦 Requirements
- Docker
- Nextflow
- ANNOVAR (user-registered download)
- R + RMarkdown + tidyverse

## 🚀 Run the Pipeline
```bash
nextflow run MultiType_variant.nf -with-docker


Data Structure
MultiTypeVariantPipeline/
├── Dockerfile
├── MultiType_variant.nf
├── nextflow.config
├── report_template.Rmd
├── data/                    # (optional) 示例数据位置
├── bin/                     # 预处理脚本、引用资源
├── README.md
├── LICENSE
├── .gitignore
└── .github/
    └── workflows/
        └── test_pipeline.yml   # GitHub Actions 自动测试



📄 Output
SNP/Indel: *.g.vcf.gz

CNV: *_cnv.cns

SV: *_manta.vcf.gz

Annotation: *_annotated.txt

Report: report.html

📁 Input Structure
Place your raw FASTQ files in data/, named as:
Sample1_R1.fastq.gz
Sample1_R2.fastq.gz





