configfile: 'configsample.yaml'


# python


# ! python


rule start:
    output:
        '/home/ubuntu/private/snakemake-template/temp.done'
    script:
        """
        ls >> {output}
        """

rule end:
    input:
        '/home/ubuntu/private/snakemake-template/temp.done'
    script:
        """
        ls >> {output}
        """