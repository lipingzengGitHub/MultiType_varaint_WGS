params.reads = "data/*_R{1,2}.fastq.gz"
params.ref   = "data/hg38.fa"

workflow {
    fastqc()
    trim()
    align()
    sort_index()
    call_variants()
    call_sv()
    call_cnv()
    annotate_variants()
    generate_report()
}

process fastqc {
    tag "$sample"
    input:
    tuple val(sample), path(reads)
    output:
    path("${sample}_fastqc.html"), emit: fastqc_report
    script:
    """
    fastqc ${reads[0]} ${reads[1]} -o .
    """
}

process trim {
    tag "$sample"
    input:
    tuple val(sample), path(reads)
    output:
    tuple val(sample), path("${sample}_trimmed_R1.fastq.gz"), path("${sample}_trimmed_R2.fastq.gz")
    script:
    """
    trimmomatic PE -phred33 \
      ${reads[0]} ${reads[1]} \
      ${sample}_trimmed_R1.fastq.gz unpaired_R1.fastq.gz \
      ${sample}_trimmed_R2.fastq.gz unpaired_R2.fastq.gz \
      ILLUMINACLIP:/opt/trimmomatic/adapters/TruSeq3-PE.fa:2:30:10 SLIDINGWINDOW:4:20 MINLEN:50
    """
}

process align {
    tag "$sample"
    input:
    tuple val(sample), path(r1), path(r2)
    output:
    tuple val(sample), path("${sample}.sam")
    script:
    """
    bwa index ${params.ref}
    bwa mem ${params.ref} $r1 $r2 > ${sample}.sam
    """
}

process sort_index {
    tag "$sample"
    input:
    tuple val(sample), path(sam)
    output:
    tuple val(sample), path("${sample}.sorted.bam"), path("${sample}.sorted.bam.bai")
    script:
    """
    samtools view -bS $sam | samtools sort -o ${sample}.sorted.bam
    samtools index ${sample}.sorted.bam
    """
}

process call_variants {
    tag "$sample"
    input:
    tuple val(sample), path(bam), path(bai)
    output:
    path("${sample}.g.vcf.gz")
    script:
    """
    gatk HaplotypeCaller \
      -R ${params.ref} \
      -I ${bam} \
      -O ${sample}.g.vcf.gz \
      -ERC GVCF
    """
}

process call_sv {
    tag "$sample"
    input:
    tuple val(sample), path(bam), path(bai)
    output:
    path("${sample}_manta.vcf.gz")
    script:
    """
    configManta.py --bam ${bam} --referenceFasta ${params.ref} --runDir manta_run_${sample}
    manta_run_${sample}/runWorkflow.py -m local -j 4
    cp manta_run_${sample}/results/variants/diploidSV.vcf.gz ${sample}_manta.vcf.gz
    """
}

process call_cnv {
    tag "$sample"
    input:
    tuple val(sample), path(bam), path(bai)
    output:
    path("${sample}_cnv.cns")
    script:
    """
    cnvkit.py batch ${bam} --normal ${bam} --output-reference ${sample}_reference.cnn --output-dir ./ --diagram --scatter
    cp ${sample}.cns ${sample}_cnv.cns
    """
}

process annotate_variants {
    tag "$sample"
    input:
    path(vcf)
    output:
    path("${vcf.simpleName}_annotated.txt")
    script:
    """
    table_annovar.pl ${vcf} /annovar/humandb/ \
      -buildver hg38 \
      -out ${vcf.simpleName}_annotated \
      -remove -protocol refGene,clinvar_20210501,cosmic70 \
      -operation g,f,f -nastring . -vcfinput
    """
}

process generate_report {
    input:
    path(annotated) from annotate_variants.out
    output:
    path("report.html")
    script:
    """
    Rscript -e "rmarkdown::render('report_template.Rmd', params = list(annot_file='${annotated}'), output_file='report.html')"
    """
}


