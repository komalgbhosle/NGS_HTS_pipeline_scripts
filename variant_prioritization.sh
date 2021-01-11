#!/bin/bash
main_dir=$1
nproc=$2
Input=$main_dir/output_mutations
Output=$main_dir/output_mutations/final_vcf
tmp_output=$main_dir/output_mutations/tmp_output
# mkdir $Output
# mkdir $tmp_output
reffiles=$var_utility
vcffiles=$Path/analysis/vcffiles
# mkdir $tmp_output/SNP
# mkdir $tmp_output/INDEL
filteredSNP=$tmp_output/SNP/filtered
filteredINDEL=$tmp_output/INDEL/filtered
# mkdir $filteredSNP
# mkdir $filteredINDEL


function prioritize_step1(){
    for file in `ls $vcffiles`; do
        #echo $file
        if [[ $file == *.vcf ]]; then
            vcfid="${file%%_variants.vcf}"
            for j in $vcfid; do
                echo $j
#SNP/INDEL calling
                java -jar $main_dir/gatk-4.1.8.1/gatk-package-4.1.8.1-local.jar SelectVariants -R $reffiles/hg38.fa -V $vcffiles/${j}_variants.vcf -select-type SNP -O $tmp_output/SNP/${j}_rawSNP.vcf
                java -jar $main_dir/gatk-4.1.8.1/gatk-package-4.1.8.1-local.jar SelectVariants -R $reffiles/hg38.fa -V $vcffiles/${j}_variants.vcf -select-type INDEL -O $tmp_output/INDEL/${j}_rawINDEL.vcf
                java -jar $main_dir/gatk-4.1.8.1/gatk-package-4.1.8.1-local.jar VariantFiltration -R $reffiles/hg38.fa -V $tmp_output/SNP/${j}_rawSNP.vcf --filter-expression 'QD < 2.0 || FS > 60.0 || MQ < 40.0 || MQRankSum < -12.5 || ReadPosRankSum < -8.0 || SOR > 4.0' --filter-name "basic_SNP_filter" -O $filteredSNP/${j}_filteredSNP.vcf
                java -jar $main_dir/gatk-4.1.8.1/gatk-package-4.1.8.1-local.jar VariantFiltration -R $reffiles/hg38.fa -V $tmp_output/INDEL/${j}_rawINDEL.vcf --filter-expression 'QD < 2.0 || FS > 200.0 || ReadPosRankSum < -20.0 || SOR > 10.0' --filter-name "basic_INDEL_filter" -O $filteredINDEL/${j}_filteredINDEL.vcf
                vep -i $filteredSNP/${j}_filteredSNP.vcf --cache -o $tmp_output/${j}_finalSNP.vcf --everything --force_overwrite --vcf --fork $nproc
                vep -i $filteredINDEL/${j}_filteredINDEL.vcf --cache -o $tmp_output/${j}_finalINDEL.vcf --everything --force_overwrite --vcf --fork $nproc
            done
        fi
    done
}














# function extract(){
#     echo "un tar"
#     mkdir $vcffiles
#     cp $Input/${Id}/${Id}*_variants.vcf $vcffiles
#     #mkdir $trimfiles
#     #tar -xvjf $Input -C $trimfiles
# }





























function clean_up(){
   rm -r tmp_output/*
   rm -r vcffiles/*
}
function extract(){
    echo "un tar"
    mkdir $vcffiles
    cp $Input/${Id}/${Id}*_variants.vcf $vcffiles
    #mkdir $trimfiles
    #tar -xvjf $Input -C $trimfiles
}

function prioritize_step1(){
    for file in `ls $vcffiles`; do
        echo $file
        if [[ $file == *.vcf ]]; then
            vcfid="${file%%_variants.vcf}"
            for j in $vcfid; do
                echo $j
#SNP/INDEL calling
                java -jar $var_utility/GenomeAnalysisTK-3.8-1-0-gf15c1c3ef/GenomeAnalysisTK.jar -T SelectVariants -R $reffiles/hg38.fa -V $vcffiles/${j}_variants.vcf -selectType SNP -o $tmp_output/SNP/${j}_rawSNP.vcf
                java -jar $var_utility/GenomeAnalysisTK-3.8-1-0-gf15c1c3ef/GenomeAnalysisTK.jar -T SelectVariants -R $reffiles/hg38.fa -V $vcffiles/${j}_variants.vcf -selectType INDEL -o $tmp_output/INDEL/${j}_rawINDEL.vcf
            done
        fi
    done
}
#In the above function: prioritize step 1 we are selecting output by type SNP and INDELS


function prioritize_step2(){
for file in `ls $vcffiles`; do
    echo $file
    if [[ $file == *.vcf ]]; then
        vcfid="${file%%_variants.vcf}"
        for j in $vcfid; do
            echo $j
#SNP/INDEL calling
            #filtering SNP by threshold
            java -jar $var_utility/GenomeAnalysisTK-3.8-1-0-gf15c1c3ef/GenomeAnalysisTK.jar -T VariantFiltration -R $reffiles/hg38.fa -V $tmp_output/SNP/${j}_rawSNP.vcf --filterExpression 'QD < 2.0 || FS > 60.0 || MQ < 40.0 || MQRankSum < -12.5 || ReadPosRankSum < -8.0 || SOR > 4.0' --filterName "basic_snp_filter" -o $filteredSNP/${j}_filteredSNP.vcf
#filtering indel by threshold
            java -jar $var_utility/GenomeAnalysisTK-3.8-1-0-gf15c1c3ef/GenomeAnalysisTK.jar -T VariantFiltration -R $reffiles/hg38.fa -V $tmp_output/INDEL/${j}_rawINDEL.vcf --filterExpression 'QD < 2.0 || FS > 200.0 || ReadPosRankSum < -20.0 || SOR > 10.0' --filterName "basic_snp_filter" -o $filteredINDEL/${j}_filteredINDEL.vcf
        done
    fi
done
#In the above function: prioritize step2 we are filtering SNP and INDELS by a threshold
#       java -jar /data/GenomeAnalysisTK-3.8-1-0-gf15c1c3ef/GenomeAnalysisTK.jar -T VariantFiltration -R reffiles/hg38.fa -V $tmp_output/rawSNP.vcf --filterExpression 'QD < 2.0 || FS > 60.0 || MQ < 40.0 || MQRankSum < -12.5 || ReadPosRankSum < -8.0 || SOR > 4.0' --filterName "basic_snp_filter" -o $filteredSNP/_filtered.vcf
#       java -jar /data/GenomeAnalysisTK-3.8-1-0-gf15c1c3ef/GenomeAnalysisTK.jar -T VariantFiltration -R reffiles/hg38.fa -V $tmp_output/rawINDEL.vcf --filterExpression'QD<2.0 || FS>200.0 || ReadPosRankSum<-20.0 || SOR > 10' --filterName "basic_snp_filter" -o $filteredINDEL/_filtered.vcf
#we have to perform VQSR(for genomic samples, not for rnaseq)
#       java -jar /data/GenomeAnalysisTK-3.8-1-0-gf15c1c3ef/GenomeAnalysisTK.jar -T VariantRecalibrator -resource:hapmap,known=false,training=true,truth=true,prior=15.0 hapmap_3.3.b37.sites.vcf -resource:omni,known=false,training=true,truth=false,prior=12.0 1000G_omni2.5.b37.sites.vcf -resource:1000G,known=false,training=true,truth=false,prior=10.0 1000G_phase1.snps.high_confidence.vcf -resource:dbsnp,known=true,training=false,truth=false,prior=2.0 dbsnp_135.b37.vcf -an QD -an MQ -an MQRankSum -an ReadPosRankSum -an FS -an SOR -an InbreedingCoeff -mode SNP -recalFile output.recal -tranchesFile output.tranches -rscriptFile output.plots.R
}
function vep(){
for file in `ls $filteredSNP`; do
    echo $file
    if [[ $file == *_filteredSNP.vcf ]]; then
        vcfid="${file%%_filteredSNP.vcf}"
        for j in $vcfid; do
            echo $j
            $var_utility/ensembl-vep/vep -i $filteredSNP/${j}_filteredSNP.vcf --cache --dir_cache /data/utility/cache_vep -o $tmp_output/${j}_finalSNP.vcf --everything --force_overwrite --vcf --fork $nproc
        done
    fi
done  
for file in `ls $filteredINDEL`; do
    echo $file
    if [[ $file == *_filteredINDEL.vcf ]]; then
        vcfid="${file%%_filteredINDEL.vcf}"
        for j in $vcfid; do
            echo $j
            $var_utility/ensembl-vep/vep -i $filteredINDEL/${j}_filteredINDEL.vcf --cache --dir_cache /data/utility/cache_vep -o $tmp_output/${j}_finalINDEL.vcf --everything --force_overwrite --vcf --fork $nproc
        done
    fi
done    
}
#In the above function: vep, we are predicting output for their effect on protein, giving scores for each variant
#utility
#./variant_calling.sh $Id $Input $tmp_output
#clean_up
#extract
prioritize_step1
prioritize_step2
vep
#rm -r $filteredINDEL
#rm -r $filteredSNP
cp -r $tmp_output/* $tmp_output
clean_up
