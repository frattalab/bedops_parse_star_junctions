import os
configfile: "config.yaml"


project_dir = config["project_dir"]
out_spot = config["out_spot"]
bam_spot = config["bam_spot"]
bam_suffix = config["bam_suffix"]
sj_suffix = config["pt1_sj_suffix"]
bed_file = config["bed_file"]
final_output_name = config["final_output_name"]

output_dir = os.path.join(project_dir, out_spot)

if os.path.isabs(bam_spot):
    bam_dir = bam_spot
else:
    # expect to find bam_dir under provided project dir
    bam_dir = os.path.join(project_dir, bam_spot, '')


# empty comma unpacks the tuple (so get sample wildcards as a list)
SAMPLES, = glob_wildcards(os.path.join(bam_dir, "{sample}" + bam_suffix))

print(output_dir)
print(f"Number of Input Samples {len(SAMPLES)}")


localrules: all_output, copy_config

rule all_output:
    input:
        expand(os.path.join(output_dir, "{sample}.sorted.bed"), sample = SAMPLES),
        os.path.join(output_dir, final_output_name + ".aggregated.clean.annotated.bed")


rule sj_to_bed:
    input:
        os.path.join(bam_dir, "{sample}" + sj_suffix)

    output:
        temp(os.path.join(output_dir, "{sample}.bed"))

    group:
        "prepare_sample_beds"

    shell:
        """
        python3 splicejunction2bed.py --name --input {input} --output {output}
        """


rule sort_beds:
    input:
        rules.sj_to_bed.output

    output:
        os.path.join(output_dir, "{sample}.sorted.bed")

    conda:
        "bedops_parse_star.yaml"

    group:
        "prepare_sample_beds"

    shell:
        """
        sort-bed {input} > {output}
        """

rule call_element:
    input:
        rules.sort_beds.output

    output:
        temp(os.path.join(output_dir, final_output_name + ".{sample}.bedops.element"))

    conda:
        "bedops_parse_star.yaml"

    group:
        "prepare_sample_beds"

    shell:
        """
        bedtools intersect -b {bed_file} -a {input} -wa > {output}
        """


# an aggregation over all produced clusters
rule aggregate:
    input:
        expand(os.path.join(output_dir, final_output_name + ".{sample}.bedops.element"), sample = SAMPLES)

    output:
        os.path.join(output_dir, final_output_name + ".aggregated.bed")

    params:
        cat_call = os.path.join(output_dir, final_output_name + "*.bedops.element")

    group:
        "get_aggregate_bed"

    shell:
        """
        cat {params.cat_call} > {output}
        """


rule clean_aggregate:
    input:
        rules.aggregate.output

    output:
        temp(os.path.join(output_dir, final_output_name + ".aggregated.clean.bed"))

    conda:
        "bedops_parse_star.yaml"

    group:
        "get_aggregate_bed"

    shell:
        """
        bedtools intersect -f 1 -wa -r -a {input} -b {bed_file} > {output}
        """

rule annotate_clean:
    input:
        rules.clean_aggregate.output

    output:
        os.path.join(output_dir, final_output_name + ".aggregated.clean.annotated.bed")

    conda:
        "bedops_parse_star.yaml"

    group:
        "get_aggregate_bed"

    shell:
        """
        bedtools intersect -f 1 -r -a {input} -b {bed_file} -wb | awk -v OFS="\t" '{{print $1,$2,$3,$4,$5,$6,$10}}' > {output}.tmp
        cat {output}.tmp | uniq > {output}
        rm {output}.tmp
        """

