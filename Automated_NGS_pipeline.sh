#!/bin/bash
Path=$1
nproc=$2
download=$Path/analysis
mkdir $download
rawdata=$download/rawdata
mkdir $rawdata
paired=$rawdata/paired
single=$rawdata/single
mkdir $paired
mkdir $single
trimfiles=$output_path/TrimmedFiles
pairtrimmed=$trimfiles/pairedtrim
singletrimmed=$trimfiles/singletrim
#cp GetQCPlotsData.py $Path
#cp picard.jar $Path
#unzip gatk-4.1.8.1.zip
#mv gatk-4.1.8.1 $Path
#conda install -c bioconda ensembl-vep #######Requires users input
#mkdir $Path/ensembl-vep
#mkdir $Path/ensembl-vep/cache_vep
#vep_install -a cf -s homo_sapiens -y GRCh38 -c $Path/ensembl-vep/cache_vep --CONVERT
#####QC
output_path_qc=$Path/output_qc
#mkdir $output_path_qc
trimfiles=$output_path_qc/TrimmedFiles
#mkdir $trimfiles
pairtrimmed=$trimfiles/pairedtrim
singletrimmed=$trimfiles/singletrim
qc_report=$output_path_qc/qc
qc_report_trim=$output_path_qc/qc_after_trim

###expression
output_path_expression=$Path/output_expression
mkdir $output_path_expression
transcripts_quant=$output_path_expression/expression_values


###mutation
output_path_mutations=$Path/output_mutations
mkdir $output_path_mutations
alignment=$output_path_mutations/alignment_files
variants=$output_path_mutations/variants

####prioritization
output_prioritize=$Path/output_mutations/final_vcf
mkdir $output_prioritize
tmp_output=$Path/output_mutations/tmp_output
mkdir $tmp_output
filteredSNP=$tmp_output/SNP/filtered
filteredINDEL=$tmp_output/INDEL/filtered



function make_dir(){
    mkdir $pairtrimmed
    mkdir $singletrimmed
    mkdir $qc_report
    mkdir $qc_report_trim
    mkdir $transcripts_quant
    mkdir $variants
    mkdir $alignment
	mkdir $tmp_output/SNP
    mkdir $tmp_output/INDEL
    mkdir $tmp_output/SNP/filtered
	mkdir $tmp_output/INDEL/filtered

    
}





function downloading_url(){
	local url=$1
	####loop for paired sample downloading
	if [[ $url == *_2.fastq.gz ]];then
		file1=`echo $url|rev|cut -d";" -f2|rev`
		file2=`echo $url|rev|cut -d";" -f1|rev`
		paired_1=`echo $file1|rev|cut -d"/" -f1|rev`
		paired_2=`echo $file2|rev|cut -d"/" -f1|rev`
		#####loop for checking the file, if absent then downloading
		if [[ -f "$download/$paired_1" || -f "$download/$paired_2" ]]; then
        	echo  "sample id $paired_id exist"
        else
        	echo "Downloading first pair" $paired_1
			wget ftp://$file1 -P $download
			echo "Now Downloading second pair" $paired_2
			wget ftp://$file2 -P $download
		fi
	#####loop for single sample downloading
	else
		single_file=`echo $url|rev|cut -d"/" -f1|rev`
		if [[ -f "$download/$single_file" ]]; then
        	echo  "sample id $single_file exist"
        else
        	wget ftp://${url} -P $download
		fi
		
	fi
}
function index_expression(){
    reffiles=$Path/reference_transcriptome
    transcripts_index=$reffiles/transcripts_index
    mkdir $reffiles
    mkdir $transcripts_index
    echo "downloading transcriptome fasta file.."
    wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/001/405/GCF_000001405.39_GRCh38.p13/GCF_000001405.39_GRCh38.p13_rna.fna.gz -P $reffiles
    gunzip $reffiles/GCF_000001405.39_GRCh38.p13_rna.fna.gz
    salmon index -t $reffiles/GCF_000001405.39_GRCh38.p13_rna.fna -i $transcripts_index -k 31 -p $nproc
    echo "Indexing transcriptome is done"
}
function index_mutation(){
	reffiles=$Path/reference_genome
	mkdir $reffiles
	genome_index_splice=$reffiles/genome_index_sample_wise
	genome_index=$reffiles/genome_index
	mkdir $genome_index
	mkdir $genome_index_splice
	echo "download genome hg38 fasta file.."
	wget http://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/hg38.fa.gz -P $reffiles
	gunzip $reffiles/hg38.fa.gz
	STAR --runMode genomeGenerate --genomeDir $genome_index --genomeFastaFiles $reffiles/hg38.fa  --runThreadN $nproc
	echo "Indexing genome is done"
	echo "Generating faidx...."
	samtools faidx $reffiles/hg38.fa
	echo "Creating genomic sequence disctionary..."
	java -jar $Path/picard.jar CreateSequenceDictionary R=$reffiles/hg38.fa
	echo "done"
}
function processing(){
	local url=$1
	if [[ $url == *_2.fastq.gz ]];then
		file1=`echo $url|rev|cut -d";" -f2|rev`
		file2=`echo $url|rev|cut -d";" -f1|rev`
		paired_1=`echo $file1|rev|cut -d"/" -f1|rev`
		paired_2=`echo $file2|rev|cut -d"/" -f1|rev`
		mv $download/${paired_1} $paired
		mv $download/${paired_2} $paired
		bash /data/users-workspace/komal.bhosle/NGS_pipeline/QC.sh $Path $nproc
		#######FOR EXPRESSION
		bash /data/users-workspace/komal.bhosle/NGS_pipeline/rna_seq_expression.sh $Path $nproc
		########FOR MUTATION
		bash /data/users-workspace/komal.bhosle/NGS_pipeline/variant_calling.sh $Path $nproc
		bash /data/users-workspace/komal.bhosle/NGS_pipeline/variant_prioritization.sh $Path $nproc
	else
		file1=`echo $url|rev|cut -d"/" -f1|rev`
		mv $download/${file1} $single
		bash /data/users-workspace/komal.bhosle/NGS_pipeline/QC.sh $Path $nproc
		#######FOR EXPRESSION
		bash /data/users-workspace/komal.bhosle/NGS_pipeline/rna_seq_expression.sh $Path $nproc
		########FOR MUTATION
		bash /data/users-workspace/komal.bhosle/NGS_pipeline/variant_calling.sh $Path $nproc
		bash /data/users-workspace/komal.bhosle/NGS_pipeline/variant_prioritization.sh $Path $nproc
	fi
	cd $qc_report/
    unzip "*_fastqc.zip"
    cd $Path
    python3 GetQCPlotsData.py $qc_report/
    cd $qc_report_trim/
    unzip "*_fastqc.zip"
    cd $Path
    python3 GetQCPlotsData.py $qc_report_trim/
    

}


function Downloading_and_processing(){
#	make_dir
	#####FOR EXPRESSION
#	echo "Creating index for expression Analysis"
#	index_expression
	#####FOR MUTATION
#	echo "Creating index for mutation Analysis"
#	index_mutation
#	echo "Starting analysis going in loop"
	for url in `cat $Path/sample_urls.txt`;do
			downloading_url $url
#			processing $url
    done
}

Downloading_and_processing



#######FOR REDIS IMPLEMENTATION ONLY###########


# #!/bin/bash
# main_dir=/data-nfs/COVID_project
# completion=$main_dir/completion
# n_proc=$1
# download=$main_dir/analysis
# rawdata=$download/rawdata
# paired=$rawdata/paired
# single=$rawdata/single
# output_path=$main_dir/output_qc
# qc_report=$output_path/qc
# qc_report_trim=$output_path/qc_after_trim
# for url in `redis-cli -h 10.0.1.159 lpop input_file_job3`; do
#     url1=`echo $url|cut -d"," -f1`	
#     url2=`echo $url|cut -d"," -f2`	
#     cd $download
#     wget ftp://${url1}
#     wget ftp://${url2}
#     FILE1=`echo ${url1}|cut -d"," -f1|rev|cut -d"/" -f1|rev`
#     FILE2=`echo ${url2}|cut -d"," -f1|rev|cut -d"/" -f1|rev`
#     FILE_ID="${FILE1%%_*}"
#     if [[ -f "$FILE1" ]]; then
#     	echo "$FILE1 successfully downloaded"
#     	if [[ $FILE1 == *_1.fastq.gz || $FILE2 == *_2.fastq.gz ]];then
#     		mv $download/$FILE_ID* $paired
#     	else
#     		mv $download/$FILE1 $single
#     	fi
# 	else 
#     	  echo $FILE_ID >> $completion/error_files.txt
# 	fi
# echo "QCstarted"
# bash /home/ruchika.sharma/NGS_Analysis/QC.sh ${main_dir} ${n_proc}
# echo "QCended"
# wait
# echo "rnaexpressionstarted"
# bash /home/ruchika.sharma/NGS_Analysis/rna_seq_expression_analysis.sh ${main_dir} ${n_proc}
# echo "rnaexpressionended"
# wait
# echo "variant_callingstarted"
# bash /home/ruchika.sharma/NGS_Analysis/variant_calling.sh ${main_dir} ${n_proc}
# echo "vc ended"
# wait
# echo "vp started"
# bash /home/ruchika.sharma/NGS_Analysis/variant_prioritization.sh ${main_dir} ${n_proc}
# echo "vp ended"
# wait
# echo $url >> $completion/completion.txt
# cd $qc_report/
# unzip "*_fastqc.zip"
# cd $main_dir
# python3 GetQCPlotsData.py $qc_report/
# cd $qc_report_trim/
# unzip "*_fastqc.zip"
# cd $main_dir
# python3 GetQCPlotsData.py $qc_report_trim/
# echo "FastQC quality reports are generated"

# done
# function downloading_one(){
# 	local url="$1"
# 	file=`echo $url|rev|cut -d"/" -f1|rev`
# 	FILE=$download/${file}
# 	if [[ -f "$FILE" ]]; then
#         echo "$FILE exist"
#             else
#             	if [[ $url == *_2.fastq.gz ]];then
# 					#echo $FILE
# 					file1=`echo $url|rev|cut -d";" -f2|rev`
# 					file2=`echo $url|rev|cut -d";" -f1|rev`
# 					wget ftp://$file1 -P $download
# 					wget ftp://$file2 -P $download
# 				else
# 					wget ftp://${url} -P $download
# 				fi
#     fi
#  	sleep 5m
#  	echo $FILE
#  }
