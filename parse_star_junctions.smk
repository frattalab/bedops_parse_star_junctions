import os
# a top level folder where the bams reside
project_dir = "/home/annbrown/data/buratti_new_shsy5y/"
out_spot = "splicejunctions/"
bam_spot = "STAR_aligned/"
bam_suffix = ".Aligned.sorted.out.bam"
bed_file = "/SAN/vyplab/alb_projects/data/sinai_splice_junctions/beds/stmn2_cryptics.bed"

# =-------DON"T TOUCH ANYTHING PAST THIS POINT ----------------------------

output_dir = os.path.join(project_dir,out_spot)
bam_dir = os.path.join(project_dir,bam_spot)


SAMPLES, = glob_wildcards(bam_dir + "{sample}" + bam_suffix)
print(SAMPLES)

rule all_output:
    input:
        expand(output_dir + "{sample}.bed", sample = SAMPLES)


rule sj_to_bed:
    input:
        bam_dir + "{sample}.SJ.out.tab"
    output:
        output_dir + "{sample}.bed"
    shell:
        """
        python3 splicejunction2bed.py --name --input {input} --output {output}
        """


# rule_sort_beds
#
# rule_rename_bed
#
# rule_call_element:
