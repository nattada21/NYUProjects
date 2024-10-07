process fastp {
    output:
    path 'bwaAlign.txt', emit: bwaAlign 
    path 'fq.processed'

    '''
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
    
        fastp -i $fqdir/$fq1 \
            -I $fqdir/$fq2 \
            -o $fq1_fastp \
            -O $fq2_fastp \
            --length_required 76 \
            --detect_adapter_for_pe \
            --n_base_limit 50 \
            --html $sample.fastp.html \
            --json $sample.fastp.json
    
    	mv *.gz ../fq.processed
    
    	cd ../
    
    	echo -e "$sample\t$fq1_fastp\t$fq2_fastp" >> bwaAlign.txt
        # You can perform any operation with $sample, $fq1, and $fq2 here
    done < "$file"
    '''
}
process bwaAlign {
    input:
    path 'bwaAlign.txt'
    path 'fq.processed'
    
    output:
    path 'NA*'
    
    '''
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
    
        bwa mem -M \
    	 -t 15 \
    	 -R "@RG\\tID:${sample}.id\\tSM:${sample}\\tPL:ILLUMINA\\tLB:${sample}.lb" \
    	 "${ref}" \
    	 $fqdir/$fq1 \
    	 $fqdir/$fq2 > $sample.sam
    
        cd ../
    done < "$table"
    '''
}
process sam2bam {
    input:
    path 'NA'
    
    output:
    path 'FinalOutput'
    
    '''
    
    module load samtools/intel/1.14
    module load picard/2.17.11
    
    mkdir FinalOutput
    
    for dir in NA*; do
        cd $dir
        sam_file=$(echo *.sam)
	name="${sam_file::-4}"
	echo $name
	samtools view -bh *.sam > $name.bam
    
        java -Xmx15g -XX:ParallelGCThreads=1 -jar "${PICARD_JAR}" SortSam \
    	INPUT=$name.bam \
    	OUTPUT=$name.sorted.bam \
    	SORT_ORDER=coordinate \
    	TMP_DIR="${SLURM_JOBTMP}" \
    	MAX_RECORDS_IN_RAM=10000000 \
    	VALIDATION_STRINGENCY=LENIENT
    	
    	samtools index $name.sorted.bam
    	
	cd ../

        cp $dir/*.sorted.bam FinalOutput/
    
    done

    cp -r FinalOutput/ ../../../

    '''
}
workflow {
    output = fastp()
    bwaOut = bwaAlign(output)
    samOut = sam2bam(bwaOut)

}



