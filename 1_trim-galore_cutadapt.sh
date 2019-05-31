#!/bin/bash

#$ -q normal.q
#$ -N trim-galore_cutadapt
#$ -M florentin.constancias@cirad.fr
#$ -pe parallel_smp 2
#$ -l mem_free=6G
#$ -V
#$ -cwd
#$ -V


module purge
module load system/conda/5.1.0

#conda create -y -n trimgalore
#conda install -c bioconda trim-galore -y -n trimgalore

source activate trimgalore


# JOB BEGIN

# get sample names
for IN in raw
do
ls ${IN}/*R1*gz | cut -d/ -f2 |cut -d_ -f1,2 >> sample_names.tsv
done

# run trimgalore

OUT=trimgalore_nextera/
mkdir -p  ${OUT}

for NAME in `awk '{print $1}' sample_names.tsv`
do

echo "###Trim galore Sample" $NAME "Start###"

ls */${NAME}*R1*fastq* */${NAME}*R2*fastq*

trim_galore --paired -q 0 --illumina \
	--length 0 \
	*/${NAME}*R1*fastq* */${NAME}*R2*fastq* \
	-o $OUT
done

rename _val_1.fq.gz .fastq.gz ${OUT}*gz
rename _val_2.fq.gz .fastq.gz ${OUT}*gz

# rename samples to get RUN info and respect qiime2 input format
# e.g., L2S357_15_L001_R1_001.fastq.gz

# run cutadapt
#https://github.com/LangilleLab/microbiome_helper/wiki/DADA2-16S-Chemerin-Tutorial
#https://github.com/LangilleLab/microbiome_helper/wiki/Amplicon-SOP-v2-(qiime2-2018.6)

IN=trimgalore_illumina/
OUT=trimmed_fastqs/

mkdir $OUT

for NAME in `awk '{print $1}' sample_names.tsv`
do
    ls $IN$NAME*R1*gz $IN$NAME*R2*gz
cutadapt \
    --trim-n \
    -q 30,30
    --minimum-length 50 \
    -o ${OUT}${NAME}"_L001_R1_001.fastq.gz" \
    -p ${OUT}${NAME}"_L001_R2_001.fastq.gz" \
    ${IN}${NAME}*R1*.fastq.gz ${IN}${NAME}*R2*.fastq.gz \
	> ${OUT}${NAME}"_cutadapt_log.txt"

source deactivate trimgalore
source activate fastqc_multiqc

mkdir ${OUT}'QC/'
fastqc -t ${NSOLTS} ${OUT}*fastq* -o ${OUT}'QC/'
multiqc ${OUT}'QC/' -o ${OUT}'QC/'



# JOB END
date

exit 0
