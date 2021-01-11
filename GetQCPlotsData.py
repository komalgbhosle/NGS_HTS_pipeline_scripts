#Description: This script generates data for plots using qc report for RNA-seq data.
import pandas as pd
from io import StringIO
import os, sys, glob
import argparse
path, filename = os.path.split(os.path.abspath('GetQCPlotsData.py'))
#
def getMod(filePart, sampPath):
    filePart = "\n".join(filePart.split("\n")[1:]) #Strip first line
    filePart = filePart.split("#")
    header_fastqc, mod_res = (filePart[0].split("\t")[0]).strip(">"), (filePart[0].split("\t")[1]).strip() #Get header and result
    if (len(filePart) > 2):
        filePart[1] = filePart[2] #Remove first line
    df_fastqc = (pd.read_csv(StringIO(filePart[1]), sep='\t', header=None))
    df_fastqc = df_fastqc.rename(columns=df_fastqc.iloc[0]).drop(df_fastqc.index[0])
    filename = os.path.join(sampPath,header_fastqc+"_"+mod_res)
    df_fastqc.to_csv(filename, sep="\t", index=False)
#
def getPlotFile(qcPath):
    sampPath = os.path.join(path,qcPath)
    qcFile = os.path.join(sampPath,"fastqc_data.txt")
    with open(qcFile) as f_fastqc:
        data_fastqc = f_fastqc.read()
    f_fastqc.close()
    parts_fastqc = data_fastqc.split(">>END_MODULE")[:-1]
    for i in parts_fastqc:
        getMod(i,sampPath)


def getplots():
    parser = argparse.ArgumentParser()
    parser.add_argument('--qc')
    args = parser.parse_args()
    return args
#
if __name__ == "__main__":
    args = getplots()
    qc_path = args["--qc"]

    for qcPath in glob.glob(qc_path + "*_fastqc"):
        getPlotFile(qcPath)
#