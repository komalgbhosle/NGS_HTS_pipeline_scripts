
NGS Pipeline – RNASEQ AND VARIANT CALLING

Installing required dependencies
1. Downloading and Installing Anaconda
curl -O https://repo.anaconda.com/archive/Anaconda3-2019.03-Linux-x86_64.sh
sha256sum Anaconda3-2019.03-Linux-x86_64.sh
bash Anaconda3-2019.03-Linux-x86_64.sh
source ~/.bashrc
2. Installing Cutadapt(conda)
conda install -c bioconda cutadapt
3. Installing Fastqc(conda)
conda install -c bioconda fastqc
4. Installing trim galore(conda)
conda install -c bioconda trim-galore
5. Installing parallel(conda)
conda install -c conda-forge parallel
6. Installing star(conda)
conda install -c bioconda star
7. Installing bcftools(conda)
conda install -c bioconda bcftools
8. Installing  unzip
conda install -c conda-forge unzip
9. Installing tabix
conda install -c bioconda tabix
10. Installing salmon
conda install -c bioconda salmon
11.  Installing samtools
conda install -c bioconda samtools
12. Installing libcurl
conda install -c anaconda libcurl



STEPS
1.Make an empty folder for results
mkdir Project_name{i.e Project1}
2.Copy the path of the created project folder
pwd 
3. Prepared list of urls, for fastq files and paste them in a text file and save that file as sample_urls.txt
4.Keep this sample_urls.txt file inside the created folder
mv sample_urls.txt  /path/to/Project1
5.Copy NGS_Pipeline.zip and unzip it (outside the created folder only), to separate scripts with result data.
6.go inside the NGS_Pipeline folder and run the Automated_NGS_Pipeline.sh 
./Automated_NGS_Pipeline.sh {/path/to/Project1} {no.of cores(16)}






FOR DEVELOPERS
Picard is downloaded from wget https://github.com/broadinstitute/picard/releases/download/2.20.5/picard.jar
Gatk is downloaded from 
wgethttps://github.com/broadinstitute/gatk/releases/download/4.1.8.1/gatk-4.1.8.1.zip
unzip gatk-4.1.8.1.zip
JAVA8 required and must be there on systems to run this pipeline
###to install vep cache following commands are used, which are already included in automated script
vep_install -a cf -s homo_sapiens -y GRCh38 -c (copy_path_here)/ensembl-vep/cache_vep --CONVERT



Sample_urls.txt (sample file format)
ftp.sra.ebi.ac.uk/vol1/fastq/ERR201/009/ERR2019709/ERR2019709.fastq.gz
ftp.sra.ebi.ac.uk/vol1/fastq/ERR201/003/ERR2019713/ERR2019713_1.fastq.gz;ftp.sra.ebi.ac.uk/vol1/fastq/ERR201/003/ERR2019713/ERR2019713_2.fastq.gz
Note: use the desired text file name to avoid error.


Folder location on magenta 
/data/users-workspace/ruchika.sharma/zipped_folder/NGS_Pipeline.zip

