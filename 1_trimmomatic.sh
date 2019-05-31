#!/bin/bash

#$ -q normal.q
#$ -N trimmomatic
#$ -M florentin.constancias@cirad.fr
#$ -pe parallel_smp 6
#$ -l mem_free=6G
#$ -V
#$ -cwd

module purge
module load system/conda/5.1.0

source activate trimmomatic

IN=raw/
OUT=trimmomatic/

mkdir -p ${OUT}

for NAME in `awk '{print $1}' sample_names.tsv`
do
ls ${IN}${NAME}*R1*gz ${IN}${NAME}*R2*gz

trimmomatic PE -phred33 \
	${IN}${NAME}*R1*gz ${IN}${NAME}*R2*gz \
	${OUT}${NAME}_L001_R1_001.fastq.gz ${OUT}${NAME}_L001_R1_001_unpaired.fastq.gz \
	${OUT}${NAME}_L001_R2_001.fastq.gz ${OUT}${NAME}_L001_R2_001_unpaired.fastq.gz \
	ILLUMINACLIP:/homedir/constancias/.conda/envs/trimmomatic/share/trimmomatic-0.39-1/adapters/TruSeq3-PE.fa:2:30:10 \
	LEADING:0 TRAILING:0 \
	SLIDINGWINDOW:4:15 MINLEN:50 \
	-threads ${NSLOTS} \
	-trimlog ${OUT}${NAME}_trimmomatic_log.txt

done


source deactivate trimgalore
source activate fastqc_multiqc

mkdir ${OUT}'QC/'
fastqc -t ${NSOLTS} ${OUT}*fastq* -o ${OUT}'QC/'
multiqc ${OUT}'QC/' -o ${OUT}'QC/'



# JOB END
date

exit 0


