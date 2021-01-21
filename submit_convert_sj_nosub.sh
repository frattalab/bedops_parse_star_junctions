#!/bin/bash
#Submit to the cluster, give it a unique name
#$ -S /bin/bash
#$ -N convert_sj_to_psi_nosub
#$ -cwd
#$ -V
#$ -l h_vmem=4G,tmem=4G,h_rt=24:00:00
#$ -pe smp 4
#$ -R y

# join stdout and stderr output
#$ -j y
#$ -sync y

if [ "$1" != "" ]; then
    RUN_NAME=$1
else
    RUN_NAME="run"
fi

FOLDER=submissions/$(date +"%Y%m%d%H%M")
mkdir -p ${FOLDER}


snakemake -s convert_sj_to_psi.smk \
-j 4 \
--nolock \
--rerun-incomplete \
--latency-wait 100
