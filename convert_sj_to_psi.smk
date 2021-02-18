import os
configfile: "config.yaml"

gtf = config["gtf"]
input_sj_folder = config["input_sj_folder"]
out_spot = config["out_spot"]
sj_suffix = config["pt2_sj_suffix"]




# =-------DON"T TOUCH ANYTHING PAST THIS POINT ----------------------------

def get_single_psi_parsed_files_dasper(SAMPLES):
    """
    return a list of files that will exist
    """

    parsed_psi_files = [os.path.join(output_dir,x + "_normalized_annotated.csv") for x in SAMPLES]

    return(parsed_psi_files)

output_dir = os.path.join(input_sj_folder,out_spot)
# print(bam_dir)
SAMPLES, = glob_wildcards(input_sj_folder + "{sample}" + sj_suffix)

rule all_normalize_annotate:
    input:
        expand(output_dir + "{sample}" + "_normalized_annotated.csv", sample = SAMPLES),
        expand(output_dir  + "beds/" + "{sample}" + "_normalized_annotated.bed", sample = SAMPLES),
        output_dir  + "beds/beds_dones"

        # os.path.join(output_dir, "normalized_annotated_combined_samples.csv"),
        # os.path.join(output_dir, "normalized_annotated_combined_samples.csv")



rule normalize_annotate:
    input:
        input_sj_folder + "{sample}" + sj_suffix

    output:
        output_dir + "{sample}" + "_normalized_annotated.csv"

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
        output_dir + "{sample}" + "_normalized_annotated.csv"

    output:
        output_dir  + "beds/" + "{sample}" + "_normalized_annotated.bed"

    group: "to_bed"

    params:
        bed_dir = output_dir + "beds/"

    shell:
        """
        mkdir -p {params.bed_dir}
        python3 splice_junction_psi_tobed.py -i {input} -o {output}
        """
rule dummy_agg_to_bed:
    input:
        expand(output_dir  + "beds/" + "{sample}" + "_normalized_annotated.bed",sample=SAMPLES)

    output:
        output_dir  + "beds/beds_dones"

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
