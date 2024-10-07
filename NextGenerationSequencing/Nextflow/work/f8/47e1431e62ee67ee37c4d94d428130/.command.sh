#!/bin/bash -ue
file="/scratch/work/courses/BI7653/projectB.2024/projectB_fastqs.txt"
fqdir="/scratch/work/courses/BI7653/projectB.2024"

mkdir fq.processed

while read -r line; do
    # Assign values to variables using awk
    sample=$(echo "$line" | awk '{print $1}')
    fq1=$(echo "$line" | awk '{print $2}')
    fq2=$(echo "$line" | awk '{print $3}')

    # Do something with the variables
	mkdir $sample
    cd $sample

    fq1_fastp=$(basename $fq1 .fastq.gz).fP.fastq.gz
    fq2_fastp=$(basename $fq2 .fastq.gz).rP.fastq.gz

    module load fastp/intel/0.20.1

    fastp -i $fqdir/$fq1             -I $fqdir/$fq2             -o $fq1_fastp             -O $fq2_fastp             --length_required 76             --detect_adapter_for_pe             --n_base_limit 50             --html $sample.fastp.html             --json $sample.fastp.json

	mv *.gz ../fq.processed

	cd ../

	echo -e "$sample	$fq1_fastp	$fq2_fastp" >> bwaAlign.txt
    # You can perform any operation with $sample, $fq1, and $fq2 here
done < "$file"
