#!/bin/bash
################################################################################
#### Defining variables for the Quality check of fastq files and pre-processing
################################################################################
main_dir=$1
n_proc=$2
input_path=$main_dir/analysis
output_path=$main_dir/output_qc
#mkdir $output_path
rawdata=$input_path/rawdata
paired=$input_path/rawdata/paired
single=$input_path/rawdata/single
trimfiles=$output_path/TrimmedFiles
pairtrimmed=$trimfiles/pairedtrim
singletrimmed=$trimfiles/singletrim
qc_report=$output_path/qc
qc_report_trim=$output_path/qc_after_trim
#######################installation commands ####################################
# conda install -c bioconda trim-galore
# conda install -c bioconda fastqc
# mkdir $trimfiles
# mkdir $pairtrimmed
# mkdir $singletrimmed
# mkdir $qc_report
# mkdir $qc_report_trim

function QC_analysis(){
    for i in `ls $paired`; do
        if [[ $i == *_1.fastq.gz ]]; then
            entry="${i%%_*}"
            echo $entry
            fastqc $paired/${entry}_1.fastq.gz  --o $qc_report/ -t $n_proc
            fastqc $paired/${entry}_2.fastq.gz  --o $qc_report/ -t $n_proc
            parallel --xapply trim_galore --paired -j $n_proc -o $trimfiles/pairedtrim ::: $paired/${entry}_1.fastq.gz ::: $paired/${entry}_2.fastq.gz
            fastqc $pairtrimmed/${entry}_1_val_1.fq.gz --o $qc_report_trim/ -t $n_proc
            fastqc $pairtrimmed/${entry}_2_val_2.fq.gz --o $qc_report_trim/ -t $n_proc
            rm $paired/${entry}*
        fi
    done
    for i in `ls $single`; do
       entry="${i%%.*}"
       echo $entry
       fastqc $single/${entry}* --o $qc_report/ -t $n_proc
       parallel --xapply trim_galore -j $n_proc -o $trimfiles/singletrim ::: $single/${entry}.fastq.gz
       fastqc $singletrimmed/${entry}_trimmed.fq.gz --o $qc_report_trim/ -t $n_proc
       rm $single/${entry}*
    done
echo "FastQC quality reports are generated"
}

QC_analysis
