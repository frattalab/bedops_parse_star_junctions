import os
configfile: "config.yaml"

# =-------DON"T TOUCH ANYTHING PAST THIS POINT ----------------------------
project_dir = config["project_dir"]
out_spot = config["out_spot"]
bam_spot = config["bam_spot"]
bam_suffix = config["bam_suffix"]
sj_suffix = config["pt1_sj_suffix"]
bed_file = config["bed_file"]
final_output_name = config["final_output_name"]

bedtools_path = config["bedtools_path"]
bedops_path = config["bedops_path"]


output_dir = os.path.join(project_dir,out_spot)

if os.path.isabs(bam_spot):

    if bam_spot.endswith('/'):
        bam_dir = bam_spot
    else:
        bam_dir = bam_spot + "/"

else:
     os.path.join(project_dir, bam_spot, '')


# bam_dir = os.path.join(project_dir,bam_spot)
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

    conda:
        "bedops_parse_star.yaml"

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

    conda:
        "bedops_parse_star.yaml"

    shell:
        """
        bedtools intersect -b {bed_file} -a {input} -wa > {output}
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

    conda:
        "bedops_parse_star.yaml"

    shell:
        """
        bedtools intersect -f 1 -wa -r -a {input} -b {bed_file} > {output}
        """
rule annotate_clean:
    input:
        output_dir + final_output_name + "aggregated.clean.bed"

    output:
        output_dir + final_output_name + "aggregated.clean.annotated.bed"

    conda:
        "bedops_parse_star.yaml"

    shell:
        """
        bedtools intersect -f 1 -r -a {input} -b {bed_file} -wb | awk -v OFS="\t" '{{print $1,$2,$3,$4,$5,$6,$10}}' > {output}.tmp
        cat {output}.tmp | uniq > {output}
        rm {output}.tmp
        """
