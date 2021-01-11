#!/bin/bash
echo "RNAseq Expression Analysis initiated"
main_dir=$1
n_proc=$2
input_path=$main_dir/output_qc
output_path=$main_dir/output_expression
#mkdir $output_path
paired_fastq_files=$input_path/TrimmedFiles/pairedtrim
single_fastq_files=$input_path/TrimmedFiles/singletrim
transcripts_quant=$output_path/expression_values
#mkdir transcripts_quant
reffiles=$main_dir/reference_transcriptome
transcripts_index=$reffiles/transcripts_index
#conda install -c bioconda salmon

function index(){
   
    mkdir $reffiles
    mkdir $transcripts_index
    cd $reffiles
    wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/001/405/GCF_000001405.39_GRCh38.p13/GCF_000001405.39_GRCh38.p13_rna.fna.gz
    gunzip GCF_000001405.39_GRCh38.p13_rna.fna.gz
    salmon index -t $reffiles/GCF_000001405.39_GRCh38.p13_rna.fna -i $transcripts_index -k 31 -p $n_proc
}
#salmon mapping and quantification
function salmon_mapNquant(){
    echo "Mapping and quantification using Salmon"

    for file in `ls $paired_fastq_files`; do
        if [[ $file == *_val_1.fq.gz ]]; then
            idnames="${file%%_*}"
            for i in $idnames; do
                salmon quant -i $transcripts_index/ -l A -p $n_proc -1 <(gunzip -c $paired_fastq_files/${i}_1_val_1.fq.gz) -2 <(gunzip -c $paired_fastq_files/${i}_2_val_2.fq.gz) -o $transcripts_quant/${i}
                if [[ -s "$transcripts_quant/${i}/quant.sf" ]]; then
                    echo "Analysis successfully completed for sample ${i}"
                fi
            done
        fi
    done
    for file in `ls $single_fastq_files`; do
        if [[ $file == *_trimmed.fq.gz ]]; then
            idnames="${file%%_*}"
            for i in $idnames; do
                salmon quant -i $transcripts_index/ -l A -p $n_proc -r <(gunzip -c $single_fastq_files/${i}_trimmed.fq.gz) -o $transcripts_quant/${i}
                if [[ -s "$transcripts_quant/${i}/quant.sf" ]]; then
                    echo "Analysis successfully completed for sample ${i}" 
                fi
            done
        fi
    done
}

#index
salmon_mapNquant

# function extract(){
#     echo "un tar"
#     mkdir $trimfiles
#     cp $Input/${Id}*.fq.gz $trimfiles
#     #mkdir $trimfiles
#     #tar -xvjf $Input -C $trimfiles
# }