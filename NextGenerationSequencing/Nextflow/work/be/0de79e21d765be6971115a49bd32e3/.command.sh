#!/bin/bash -ue
ref=/scratch/work/courses/BI7653/hw3.2024/hg38/Homo_sapiens.GRCh38.dna_sm.primary_assembly.normalized.fa

table='bwaAlign.txt'
fqdir=../fq.processed

module load bwa/intel/0.7.17

while read -r line; do
    # Assign values to variables using awk
    sample=$(echo "$line" | awk '{print $1}')
    fq1=$(echo "$line" | awk '{print $2}')
    fq2=$(echo "$line" | awk '{print $3}')

    mkdir $sample
    cd $sample

    bwa mem -M     	 -t 15     	 -R "@RG\tID:${sample}.id\tSM:${sample}\tPL:ILLUMINA\tLB:${sample}.lb"     	 "${ref}"     	 $fqdir/$fq1     	 $fqdir/$fq2 > $sample.sam

    cd ../
done < "$table"
