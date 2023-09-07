#!/usr/bin/env bash

# create minimal empty files for testing pipeline plumbing

# required dirs
mkdir -p testdata_empty/aligned_bams
mkdir -p testdata_empty/star_sj_tabs

# required input files
touch testdata_empty/input_junctions.bed
touch testdata_empty/annotation.gtf
touch testdata_empty/aligned_bams/control_1.Aligned.sortedByCoord.out.bam
touch testdata_empty/aligned_bams/treatment_1.Aligned.sortedByCoord.out.bam
touch testdata_empty/aligned_bams/control_1.SJ.out.tab
touch testdata_empty/aligned_bams/treatment_1.SJ.out.tab
touch testdata_empty/star_sj_tabs/control_1.SJ.out.tab
touch testdata_empty/star_sj_tabs/treatment_1.SJ.out.tab