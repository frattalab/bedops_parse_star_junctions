#!/bin/bash


FOLDER=$1
BED=$2
OUTPUT=$3

FILES=$FOLDER*.renamed.bed


for file in $FILES
do
  ~/tools/bedops/bin/bedops --element-of 1 \
  $file \
  $BED
done >> $OUTPUT
