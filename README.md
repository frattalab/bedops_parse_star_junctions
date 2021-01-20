# bedops_parse_star_junctions
Pipeline for taking STAR's SJ.out files and parsing the counts for a given bed of named spliced junctions

Edit the top lines of the .smk file to run correctly


There's two independent parts to the analysis, one will turn STAR's splice junction into bed files, sort them,
and then use bedtools plus some awk to give a final output file that looks like this(without the header)

| chromosome | start | end | filename_this_count_comes_from         | count | strand | name_of_junction_in_your_input |
|-------|---------|---------|------------------------------|----|---|----------------|
| chr19 | 7168094 | 7170537 | Cont-B_S2.SJ.out             | 49 | - | INSR_annotated |
| chr19 | 7168094 | 7170537 | Cont-C_S3.SJ.out             | 30 | - | INSR_annotated |
| chr19 | 7168094 | 7170537 | Cont-D_S4.SJ.out             | 35 | - | INSR_annotated |
| chr19 | 7168094 | 7170537 | control_fluorescent_2.SJ.out | 9  | - | INSR_annotated |
| chr19 | 7168094 | 7170537 | control_fluorescent_3.SJ.out | 5  | - | INSR_annotated |
| chr19 | 7168094 | 7170537 | control_none_1.SJ.out        | 20 | - | INSR_annotated |


To use that part properly you'll want to edit `parse_star_junctions.smk`
And tweak the following input

`project_dir` - this is a top level folder where the sorted beds, and outputs are going to end up

`out_spot` - a folder underneath `project_dir` that will be created, and sorted beds are output is going to appear

`bam_spot` - pipeline is fairly lazy, it's going to glob wild cards from this folder, so make sure all the samples you want to are in
the same folder, (symlinks are fine!)

`bam_suffix` - suffix of the bams for pattern matching to work

`sj_suffix` - suffix of your splice junction tables for pattern matching to work

`bed_file` - a bed file of junctions you want to compare against

`final_output_name` - a name for your file. the final output file will be located in

`{project_dir}/{out_spot}/{final_output_name}.aggregated.clean.annotated.bed"


This will contain only the junctions in `bed_file` and with the names of the junction and the names of the file it was found it

You'll also have a file called
`{project_dir}/{out_spot}/{final_output_name}.aggregated.bed`

This is all the junctions which overlapped the ones in `bed_file`, useful to check
if you expected junctions that weren't present because you might have an a one-off error.

Basic work flow is that the first rule will convert a SJ.out.tab to a bed file, and
put the 'name' of each entry as the name of the file it's in

e.g. if I input a folder with samples called `sample01.SJ.out.tab` and `sample02.SJ.out.tab`

I'll get 2 beds that look like this

chrY	57208979	57209532	sample01.SJ.out	0	+
chrY	57209059	57209219	sample01.SJ.out	0	+

chrY	57208979	57209532	sample02.SJ.out	0	+
chrY	57209059	57209219	sample02.SJ.out	0	+


The second part uses Dasper to annotate relative to a GTF and convert STAR's splice junction counts to percent spliced in
