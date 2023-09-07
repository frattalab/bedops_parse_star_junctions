localrules: all_normalize_annotate, normalize_annotate
import os
configfile: "config.yaml"


def get_single_psi_parsed_files_dasper(SAMPLES):
    """
    return a list of files that will exist
    """

    parsed_psi_files = [os.path.join(output_dir,x + "_normalized_annotated.csv") for x in SAMPLES]

    return(parsed_psi_files)


gtf = config["gtf"]
input_sj_folder = config["input_sj_folder"]
output_dir = config["out_spot"]
sj_suffix = config["pt2_sj_suffix"]

# empty comma unpacks the tuple (so get sample wildcards as a list)
SAMPLES, = glob_wildcards(os.path.join(input_sj_folder, "{sample}" + sj_suffix))


rule all_normalize_annotate:
    input:
        expand(os.path.join(output_dir, "{sample}" + "_normalized_annotated.csv"), sample = SAMPLES),
        expand(os.path.join(output_dir, "beds", "{sample}" + "_normalized_annotated.bed"), sample = SAMPLES),
        os.path.join(output_dir, "beds", "beds_dones")

rule normalize_annotate:
    input:
        os.path.join(input_sj_folder, "{sample}" + sj_suffix)

    output:
        os.path.join(output_dir, "{sample}" + "_normalized_annotated.csv")

    params:
        gtf = gtf,
        sample_name = "{sample}",
        output_folder = output_dir,
        mincount = 1

    conda:
        "bedops_parse_star.yaml"

    shell:
        """
        mkdir -p {output_dir}
        Rscript convert_sj_to_psi.R \
        --sample_name {params.sample_name} \
        --sample_file {input} \
        --gtf {params.gtf} \
        --output_folder {params.output_folder} -m {params.mincount}
        """

rule to_bed:
    input:
        rules.normalize_annotate.output

    output:
        os.path.join(output_dir, "beds", "{sample}" + "_normalized_annotated.bed")

    group: "to_bed"

    params:
        bed_dir = os.path.join(output_dir, "beds", "")

    shell:
        """
        mkdir -p {params.bed_dir}
        python3 splice_junction_psi_tobed.py -i {input} -o {output}
        """

rule dummy_agg_to_bed:
    input:
        expand(os.path.join(output_dir, "beds", "{sample}" + "_normalized_annotated.bed"), sample=SAMPLES)

    output:
        os.path.join(output_dir, "beds", "beds_dones")

    group: "to_bed"

    shell:
        """
        touch {output}
        """


# rule squashed_normalize_annotate:
#     input:
#         all_parsed_csvs = get_single_psi_parsed_files_dasper(SAMPLES)
#     output:
#         os.path.join(output_dir, "normalized_annotated_combined_samples.csv")
#     params:
#         dir_of_normed = output_dir
#     shell:
#         """
#         Rscript scripts/combine_annotated_psi.R \
#         --folder {params.dir_of_normed} \
#         --out {output}
#         """
# rule squashed_normalize_annotate:
#     input:
#         all_parsed_csvs = get_single_psi_parsed_files_dasper(SAMPLES)
#     output:
#         os.path.join(output_dir, "normalized_annotated_combined_samples.RDS")
#     params:
#         dir_of_normed = output_dir
#     shell:
#         """
#         Rscript scripts/combine_annotated_psi.R \
#         --folder {params.dir_of_normed} \
#         --out {output}
#         """
