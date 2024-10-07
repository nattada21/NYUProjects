#!/bin/bash -ue
module load samtools/intel/1.14
   module load picard/2.17.11

   mkdir FinalOutput

   for dir in NA*; do
       cd $dir
       sam_file=$(echo *.sam)
name="${sam_file::-4}"
echo $name
samtools view -bh *.sam > $name.bam

       java -Xmx15g -XX:ParallelGCThreads=1 -jar "${PICARD_JAR}" SortSam     	INPUT=$name.bam     	OUTPUT=$name.sorted.bam     	SORT_ORDER=coordinate     	TMP_DIR="${SLURM_JOBTMP}"     	MAX_RECORDS_IN_RAM=10000000     	VALIDATION_STRINGENCY=LENIENT

   	samtools index $name.sorted.bam

cd ../

       cp $dir/*.sorted.bam FinalOutput/

   done

   cp -r FinalOutput/ ../../../
