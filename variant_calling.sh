#!/bin/bash
echo "Mutation Analysis initiated"
main_dir=$1
n_proc=$2
input_path=$main_dir/output_qc
output_path=$main_dir/output_mutations
alignment=$output_path/alignment_files
trimfiles=$input_path/TrimmedFiles
pairtrimmed=$trimfiles/pairedtrim
singletrimmed=$trimfiles/singletrim
reffiles=$main_dir/reference_genome
genome_index_splice=$reffiles/genome_index_sample_wise
variants=$output_path/variants
genome_index=$reffiles/genome_index

#mkdir $output_path

function Mutation_calling(){
    for file in `ls $pairtrimmed`; do
        if [[ $file == *_1_val_1.fq.gz ]]; then
            idnames="${file%%_*}"  
            #echo $idnames
            for i in $idnames; do
                echo $i
                STAR --genomeDir $genome_index --readFilesIn <(gunzip -c $pairtrimmed/${i}_1_val_1.fq.gz)  <(gunzip -c $pairtrimmed/${i}_2_val_2.fq.gz) --runThreadN $n_proc --outFileNamePrefix $alignment/${i}_
                mkdir $genome_index_splice/${i}
                STAR --runMode genomeGenerate --genomeDir $genome_index_splice/${i} --genomeFastaFiles $reffiles/hg38.fa --sjdbFileChrStartEnd $alignment/${i}_SJ.out.tab --sjdbOverhang 100 --runThreadN $n_proc
                STAR --genomeDir $genome_index_splice/${i} --readFilesIn <(gunzip -c $pairtrimmed/${i}_1_val_1.fq.gz)  <(gunzip -c $pairtrimmed/${i}_2_val_2.fq.gz) --runThreadN  $n_proc --outFileNamePrefix $alignment/${i}_
                java -jar $main_dir/picard.jar SortSam INPUT=$alignment/${i}_Aligned.out.sam OUTPUT=$variants/${i}_sorted.out.bam SORT_ORDER=coordinate
                java -jar $main_dir/picard.jar AddOrReplaceReadGroups I=$variants/${i}_sorted.out.bam O=$alignment/${i}_rg.bam RGID=4 RGLB=lib1 RGPL=illumina RGPU=unit1 RGSM=${i}
                java -jar $main_dir/picard.jar MarkDuplicates I=$alignment/${i}_rg.bam O=$alignment/${i}_dedup.bam  CREATE_INDEX=true VALIDATION_STRINGENCY=SILENT M=$alignment/${i}_output.metrics
                java -jar $main_dir/gatk-4.1.8.1/gatk-package-4.1.8.1-local.jar SplitNCigarReads -R $reffiles/hg38.fa -I $alignment/${i}_dedup.bam --read-filter MappingQualityReadFilter -O $alignment/${i}_split.bam 
                java -jar $main_dir/gatk-4.1.8.1/gatk-package-4.1.8.1-local.jar HaplotypeCaller -R $reffiles/hg38.fa -I $alignment/${i}_dedup.bam -O $variants/${i}_variants.vcf
                rm -rf $pairtrimmed/${i}*
                rm -rf $alignment/${i}*
                rm -rf $genome_index_splice/${i}*
                
            done
        fi
    done
    for file in `ls $singletrimmed`; do
        if [[ $file == *_trimmed.fq.gz ]]; then
            idnames="${file%%_trimmed.fq.gz}"
            #echo $idnames
            for i in $idnames; do
                echo $i 
                STAR --genomeDir $genome_index --readFilesIn <(gunzip -c $singletrimmed/${i}_trimmed.fq.gz) --runThreadN $n_proc --outFileNamePrefix $alignment/${i}_
                mkdir $genome_index_splice/${i}
                STAR --runMode genomeGenerate --genomeDir $genome_index_splice/${i} --genomeFastaFiles $reffiles/hg38.fa --sjdbFileChrStartEnd $alignment/${i}_SJ.out.tab --sjdbOverhang 100 --runThreadN $n_proc
                STAR --genomeDir $genome_index/${i} --readFilesIn <(gunzip -c $trimfiles/${i}_trimmed.fq.gz) --runThreadN $n_proc --outFileNamePrefix $alignment/${i}_  
                java -jar $main_dir/picard.jar SortSam INPUT=$alignment/${i}_Aligned.out.sam OUTPUT=$variants/${i}_sorted.out.bam SORT_ORDER=coordinate
                java -jar $main_dir/picard.jar AddOrReplaceReadGroups I=$variants/${i}_sorted.out.bam O=$alignment/${i}_rg.bam RGID=4 RGLB=lib1 RGPL=illumina RGPU=unit1 RGSM=${i}
                java -jar $main_dir/picard.jar MarkDuplicates I=$alignment/${i}_rg.bam O=$alignment/${i}_dedup.bam  CREATE_INDEX=true VALIDATION_STRINGENCY=SILENT M=$alignment/${i}_output.metrics
                java -jar $main_dir/gatk-4.1.8.1/gatk-package-4.1.8.1-local.jar SplitNCigarReads -R $reffiles/hg38.fa -I $alignment/${i}_dedup.bam --read-filter MappingQualityReadFilter -O $alignment/${i}_split.bam 
                java -jar $main_dir/gatk-4.1.8.1/gatk-package-4.1.8.1-local.jar HaplotypeCaller -R $reffiles/hg38.fa -I $alignment/${i}_dedup.bam -O $variants/${i}_variants.vcf
                rm -rf $singletrimmed/${i}*
                rm -rf $alignment/${i}*
                rm -rf $genome_index_splice/${i}*
            done
        fi
    done
}

Mutation_calling


 





































# function extract(){
#     echo "un tar"
#     mkdir $trimfiles
#     cp $Input/${Id}*.fq.gz $trimfiles
#     #mkdir $trimfiles
#     #tar -xvjf $Input -C $trimfiles
# }





# function STAR2pass_align(){
# # paired=""
# # lastfile=""
# # for file in `ls $trimfiles`; do
# #  if [[ $file == *_1_val_1.fq.gz ]] || [[ $file == *_2_val_2.fq.gz ]];  then
# #      mv $file $pairtrimmed
# #  elif [[ $file == *_trimmed.fq.gz ]]; then
# #      mv $file $singletrimmed
# #  fi
# #     lastfile=$file
# # done 
# reffiles=$var_utility
# alignfiles=$file_path/aligngenome
# mkdir $var_utility/genomedir
# genomedir=$var_utility/genomedir
# #mkdir $lastfiles
# for file in `ls $pairtrimmed`; do
#     if [[ $file == *_1_val_1.fq.gz ]]; then
#         idnames="${file%%_*}"  
#         echo $idnames   
#     #   mkdir $alignfiles/${i}
#         for i in $idnames; do
#             echo $i
#             STAR --genomeDir $genomedir/ --readFilesIn <(gunzip -c $pairtrimmed/${i}_1_val_1.fq.gz)  <(gunzip -c $pairtrimmed/${i}_2_val_2.fq.gz) --runThreadN $nproc --outFileNamePrefix $alignfiles/${i}_
#         done
#     fi
# done
# for file in `ls $singletrimmed`; do
#     if [[ $file == *_trimmed.fq.gz ]]; then
#         idnames="${file%%_trimmed.*}"
#         echo $idnames
# #   mkdir $alignfiles/${i}
#         for i in $idnames; do
#             echo $i 
#             STAR --genomeDir $genomedir --readFilesIn <(gunzip -c $singletrimmed/${i}_trimmed.fq.gz) --runThreadN $nproc --outFileNamePrefix $alignfiles/${i}_
#         done
#     fi
# done
# }





# function STAR2pass_spliceindex(){
# paired=""
# lastfile=""
# for file in `ls $pairtrimmed`; do
#     if [[ $file == *_1_val_1.fq.gz ]] || [[ $file == *_2_val_2.fq.gz ]];  then
#         paired="yes" 
#     fi
# done
# for file in `ls $singletrimmed`; do
#     if [[ $file == *_trimmed.fq.gz ]]; then
#         paired="no"
#     fi
#     lastfile=$file
# done
# for file in `ls $alignfiles`; do
#     echo $file
#     if [[ $file == *_SJ.out.tab ]]; then
#         splice="${file%%_*SJ.out.tab}"
#         for i in $splice; do
#              mkdir $genomedir/$i
#             $var_utility/STAR-2.7.1a/source/STAR --runMode genomeGenerate --genomeDir $genome_index/${i} --genomeFastaFiles $reffiles/hg38.fa --sjdbFileChrStartEnd $alignfiles/${i}_SJ.out.tab --sjdbOverhang 75 --runThreadN $nproc
#             alignfiles=$Path/aligngenome/spliced
#             mkdir $alignfiles
#             if [[ $paired == "yes" ]]; then
#                 $var_utility/STAR-2.7.1a/source/STAR --genomeDir $genome_index/${i} --readFilesIn <(gunzip -c $trimfiles/${i}_1_val_1.fq.gz)  <(gunzip -c $trimfiles/${i}_2_val_2.fq.gz) --runThreadN  $nproc --outFileNamePrefix $alignfiles/${i}_
#             elif [[ $paired == "no" ]]; then
#                 $var_utility/STAR-2.7.1a/source/STAR --genomeDir $genome_index/${i} --readFilesIn <(gunzip -c $trimfiles/${i}_trimmed.fq.gz) --runThreadN $nproc --outFileNamePrefix $alignfiles/${i}_  
#             fi
#             alignfiles=$file_path/aligngenome
#         done
#     fi
# done
# }



# ###Next: Run picard.sh ####Script for three steps of analysis: 1. sorting, 2. adding groups and 3. marking duplicates######## 
# function picard(){
# alignfiles=$file_path/aligngenome/spliced
# varfiles=$Path/variants
# reffolder=$var_utility
# #sort sam by coordinate##### optional step because adding read groups step also provides option that sorts sam to bam by coordinate
# for file in `ls $alignfiles`; do
#     if [[ $file == *_Aligned.out.sam ]]; then
#         sam="${file%%_Aligned.out.sam}"
#         for i in $sam; do
#             echo $i
#             java -jar $var_utility/picard.jar SortSam INPUT=$alignfiles/${i}_Aligned.out.sam OUTPUT=$alignfiles/${i}_sorted.out.bam SORT_ORDER=coordinate
#             rm $alignfiles/${i}_Aligned.out.sam
#         done
#     fi
# done
# #adding read groups to the alignment file
# for file in `ls $alignfiles`; do
#     if [[ $file == *_sorted.out.bam ]]; then
#         sorted="${file%%_sorted.out.bam}"
#         for i in $sorted; do
#             java -jar $var_utility/picard.jar AddOrReplaceReadGroups I=$alignfiles/${i}_sorted.out.bam O=$alignfiles/${i}_rg.bam RGID=4 RGLB=lib1 RGPL=illumina RGPU=unit1 RGSM=20
#             rm $alignfiles/${i}_sorted.out.bam 
#         done
#     fi
# done
# #marking duplicated reads found after alignment
# for file in `ls $alignfiles`; do
#     if [[ $file == *_rg.bam ]]; then
#         groupedfile="${file%%_rg.bam}"
#         for i in $groupedfile; do
#             java -jar $var_utility/picard.jar MarkDuplicates I=$alignfiles/${i}_rg.bam O=$alignfiles/${i}_dedup.bam  CREATE_INDEX=true VALIDATION_STRINGENCY=SILENT M=$alignfiles/${i}_output.metrics
#             rm $alignfiles/${i}_rg.bam
#         done
#     fi
# done
# }  



# function split(){
# alignfiles=$Path/aligngenome/spliced
# varfiles=$Path/variants
# reffolder=$var_utility
# for file in `ls $alignfiles`; do
#     if [[ $file == *_dedup.bam ]]; then
#         split_align="${file%%_dedup.bam}"
#         for i in $split_align; do
#             java -jar $var_utility/GenomeAnalysisTK-3.8-1-0-gf15c1c3ef/GenomeAnalysisTK.jar -T SplitNCigarReads -R $reffolder/hg38.fa -I $alignfiles/${i}_dedup.bam -o $alignfiles/${i}_split.bam -rf ReassignOneMappingQuality -RMQF 255 -RMQT 60 -U ALLOW_N_CIGAR_READS
#             rm $alignfiles/${i}_dedup.bam
#         done
#     fi
# done
# }  



# function HC(){
# alignfiles=$Path/aligngenome/spliced
# varfiles=$Path/variants
# reffolder=$var_utility
# for file in `ls $alignfiles`; do
#     if [[ $file == *_split.bam ]]; then
#         final_align="${file%%_split.bam}"
#         for i in $final_align; do
#             mkdir $varfiles/${i}
#             java -jar $var_utility/GenomeAnalysisTK-3.8-1-0-gf15c1c3ef/GenomeAnalysisTK.jar -T HaplotypeCaller -R $reffolder/hg38.fa -I $alignfiles/${i}_split.bam -dontUseSoftClippedBases -stand_call_conf 20.0 -o $varfiles/${i}_variants.vcf
#             rm $alignfiles/${i}_split.bam
#         done
#     fi
# done
# }


# function variant_analysis(){
# #STAR 2 pass alignment for RNAseq files, comment out STAR functions for doing alignment before variant calling"####(BWA in case of whole genome files)
# STAR2pass_align
# genomedir=$Path/genomeindex2
# STAR2pass_spliceindex
# # Running picard for converting sam to bam and marking duplicates
# picard
# #splitN cigar reads 
# split
# #gatk haplotype caller
# HC
# echo "Completed variant calling, vcf files ave been genrated for all samples successfully"
# }



# ####calling functions
# #extract
# #variant_analysis