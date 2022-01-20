rule ont_featureCounts_genes:
    input:
        bam=BAM_BC_CORR_UMI_UNCORR,
    output:
        featureCounts=temp(FC_READ_ASSIGNS_TMP),
        featureCounts_final=FC_READ_ASSIGNS,
        gene_assigned=FC_GENES,
        summary=FC_SUMMARY,
    params:
        rpath=str(FC_DIR),
        gtf=config["REF_GTF"],
        minQV=config["FEATURECOUNTS"]["MINQV"],
    threads: config["MAX_THREADS"]
    conda:
        "../envs/feature_counts.yml"
    shell:
        "featureCounts "
        "-T {threads} "
        "-a {params.gtf} "
        "-g gene_name "
        "-t gene "
        "-o {output.gene_assigned} -L "
        "-R CORE --primary "
        "--Rpath {params.rpath} "
        "-F GTF "
        "-Q {params.minQV} "
        "--largestOverlap "
        "{input.bam} "
        "&& cp {output.featureCounts} {output.featureCounts_final}"


rule add_gene_tags_to_bam:
    input:
        bam=BAM_BC_CORR_UMI_UNCORR,
        fc=FC_READ_ASSIGNS,
    output:
        bam=temp(BAM_BC_CORR_UMI_UNCORR_GENE),
        bai=temp(BAM_BC_CORR_UMI_UNCORR_GENE_BAI),
    conda:
        "../envs/umis.yml"
    shell:
        "python {SCRIPT_DIR}/add_gene_tags.py "
        "--output {output.bam} "
        "{input.bam} {input.fc}"
