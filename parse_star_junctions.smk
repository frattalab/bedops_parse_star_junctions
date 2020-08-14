import os
# a top level folder where the bams reside
project_dir = "/home/annbrown/data/buratti_new_shsy5y/"
out_spot = "splicejunctions/"
bam_spot = "STAR_aligned/"
bam_suffix = ".Aligned.sorted.out.bam"
bed_file = "/SAN/vyplab/alb_projects/data/sinai_splice_junctions/beds/stmn2_cryptics.bed"
bedops_path = "/SAN/vyplab/alb_projects/tools/bedops/bin/"
# =-------DON"T TOUCH ANYTHING PAST THIS POINT ----------------------------

output_dir = os.path.join(project_dir,out_spot)
bam_dir = os.path.join(project_dir,bam_spot)


SAMPLES, = glob_wildcards(bam_dir + "{sample}" + bam_suffix)
print(SAMPLES)

rule all_output:
    input:
        expand(output_dir + "{sample}.sorted.bed", sample = SAMPLES),
        output_dir + "aggregated.clean.annotated.bed"



rule sj_to_bed:
    input:
        bam_dir + "{sample}.SJ.out.tab"
    output:
        output_dir + "{sample}.bed"
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
        temp(output_dir + "{sample}.bedops.element")
    shell:
        """
        {bedops_path}bedops --element-of 1 {input} {bed_file} > {output}
        """
# an aggregation over all produced clusters
rule aggregate:
    input:
        expand(output_dir + "{sample}.bedops.element", sample = SAMPLES)
    output:
        output_dir + "aggregated.bed"
    shell:
        """
        cat {input} > {output}
        """
rule clean_aggregate:
    input:
        output_dir + "aggregated.bed"
    output:
        output_dir + "aggregated.clean.bed"
    shell:
        """
        bedtools intersect -f 1 -wa -r -a {input} -b {bed_file} > {output}
        """
rule annotate_clean:
    input:
        output_dir + "aggregated.clean.bed"
    output:
        output_dir + "aggregated.clean.annotated.bed"
    shell:
        """
        bedtools intersect -f 1 -r -a {input} -b {bed_file} -wb | awk -v OFS="\t" '{print $1,$2,$3,$4,$5,$6,$10}' > {output}
        """
