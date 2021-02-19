#!/bin/bash
#Submit to the cluster, give it a unique name
#$ -S /bin/bash
#$ -N parse_star_junctions_nosub
#$ -cwd
#$ -V
#$ -l h_vmem=6G,tmem=6G,h_rt=24:00:00
#$ -pe smp 2
#$ -R y

# join stdout and stderr output
#$ -j y

if [ "$1" != "" ]; then
    RUN_NAME=$1
else
    RUN_NAME="run"
fi

FOLDER=submissions/$(date +"%Y%m%d%H%M")
mkdir -p ${FOLDER}


snakemake -s parse_star_junctions.smk \
--use-conda \
--nolock \
--rerun-incomplete \
--latency-wait 100 \
--cores 2
