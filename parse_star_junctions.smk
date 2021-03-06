import os
####Folders and all the other stuff
####humans
project_dir = "/SAN/vyplab/alb_projects/data/sinai_splice_junctions/"
out_spot = "parsed_splice_junctions/"
bam_spot = "/SAN/vyplab/alb_projects/data/sinai_splice_junctions/sinai_als_sj/"
bam_suffix = "SJ.out.tab"
sj_suffix = "SJ.out.tab"
####humans - as PSI
# project_dir = "/SAN/vyplab/alb_projects/data/sinai_splice_junctions/sinai_all_samples_renamed_sj_tabs/"
# out_spot = "normalized_annotated/beds/"
# bam_spot = "normalized_annotated/"
# bam_suffix = ".csv"
# sj_suffix = "_normalized_annotated.csv"
####cell lines
# a top level folder where the bams reside
# project_dir = "/SAN/vyplab/alb_projects/data/sinai_splice_junctions/"
# out_spot = "parsed_splice_junctions_cellines/"
# bam_spot = "all_bams_kds_linked/"
# bam_suffix = ".Aligned.sorted.out.bam"
# sj_suffix = ".SJ.out.tab"


####Which bed file, and what you want to name it

bed_file = "/SAN/vyplab/alb_projects/data/sinai_splice_junctions/beds/stmn2_and_unc13a_atxn1.sorted.bed"
final_output_name = "atxn1_and_aars"

#### Where do bedtools and bedops live on your system? ####
bedops_path = "/SAN/vyplab/alb_projects/tools/bedops/bin/"
bedtools_path = "/SAN/vyplab/alb_projects/tools/bedtools"

# =-------DON"T TOUCH ANYTHING PAST THIS POINT ----------------------------


output_dir = os.path.join(project_dir,out_spot)
bam_dir = os.path.join(project_dir,bam_spot)
# print(bam_dir)
SAMPLES, = glob_wildcards(bam_dir + "{sample}" + bam_suffix)

print(output_dir)
print("Number of Input Samples")
print(len(SAMPLES))


rule all_output:
    input:
        expand(output_dir + "{sample}.sorted.bed", sample = SAMPLES),
        output_dir + final_output_name + "aggregated.clean.annotated.bed"


rule sj_to_bed:
    input:
        bam_dir + "{sample}" + sj_suffix
    output:
        temp(output_dir + "{sample}.bed")
    shell:
        """
        python3 splicejunction2bed.py --name --input {input} --output {output}
        """


rule sort_beds:
    input:
        output_dir + "{sample}.bed"
    output:
        output_dir + "{sample}.sorted.bed"
    shell:
        """
        {bedops_path}sort-bed {input} > {output}
        """

rule call_element:
    input:
        output_dir + "{sample}.sorted.bed"
    output:
        temp(output_dir + final_output_name + ".{sample}.bedops.element")
    params:
        bedtools = bedtools_path
    shell:
        """
        {params.bedtools} intersect -b {bed_file} -a {input} -wa > {output}
        """
# an aggregation over all produced clusters
rule aggregate:
    input:
        expand(output_dir + final_output_name + ".{sample}.bedops.element", sample = SAMPLES)
    output:
        output_dir + final_output_name + "aggregated.bed"
    params:
        cat_call = output_dir + final_output_name + "*.bedops.element"
    shell:
        """
        cat {params.cat_call} > {output}
        """
rule clean_aggregate:
    input:
        output_dir + final_output_name + "aggregated.bed"
    output:
        temp(output_dir + final_output_name + "aggregated.clean.bed")
    shell:
        """
        bedtools intersect -f 1 -wa -r -a {input} -b {bed_file} > {output}
        """
rule annotate_clean:
    input:
        output_dir + final_output_name + "aggregated.clean.bed"
    output:
        output_dir + final_output_name + "aggregated.clean.annotated.bed"
    shell:
        """
        bedtools intersect -f 1 -r -a {input} -b {bed_file} -wb | awk -v OFS="\t" '{{print $1,$2,$3,$4,$5,$6,$10}}' > {output}.tmp
        cat {output}.tmp | uniq > {output}
        rm {output}.tmp
        """
