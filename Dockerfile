# Dockerfile for NGS pipeline
FROM ubuntu:20.04

# Prevent interactive prompt
ENV DEBIAN_FRONTEND=noninteractive

# Install base dependencies
RUN apt update && apt install -y \
    wget unzip git openjdk-8-jdk python3 python3-pip perl \
    fastqc bwa samtools curl nano build-essential zlib1g-dev \
    default-jre bc

# Install Trimmomatic
RUN wget -O /opt/Trimmomatic-0.39.zip https://github.com/timflutre/trimmomatic/archive/refs/tags/v0.39.zip && \
    unzip /opt/Trimmomatic-0.39.zip -d /opt && \
    ln -s /opt/trimmomatic-0.39 /opt/trimmomatic

# Install GATK
RUN wget -O /opt/gatk.zip https://github.com/broadinstitute/gatk/releases/download/4.5.0.0/gatk-4.5.0.0.zip && \
    unzip /opt/gatk.zip -d /opt

# Install CNVkit (optional CNV detection)
RUN pip3 install cnvkit

# Install Manta for structural variants
RUN wget -qO- https://github.com/Illumina/manta/releases/download/v1.6.0/manta-1.6.0.centos6_x86_64.tar.bz2 | tar xj -C /opt

# Set PATH
ENV PATH="/opt/gatk-4.5.0.0:/opt/trimmomatic:/opt/manta-1.6.0.centos6_x86_64/bin:$PATH"

# Create working directory
WORKDIR /data

# Copy pipeline script
COPY run_pipeline.sh /data/run_pipeline.sh
RUN chmod +x /data/run_pipeline.sh

CMD ["/bin/bash"]



