process HIFIASM {
    tag "$meta"
    publishDir "${params.output_dir}/$meta", mode:'copy'

    errorStrategy { task.attempt <= 5 ? "retry" : "ignore" }
    maxRetries 5
    
    conda "${projectDir}/conda_environments/hifiasm.yml"
    
    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("*")                , emit: output_ch
    tuple val(meta), path("*.p_ctg.gfa")       , emit: primary_gfa_ch
    path("${meta}.log")
    path  "versions.yml"                      , emit: versions_ch

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    hifiasm -t 1 --ont --primary -o ${meta} $reads &> ${meta}.log
    

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        hifiasm: \$(hifiasm --version 2>&1)
    END_VERSIONS
    """
}

process GFA2FA {
    tag "$meta"
    publishDir "${params.output_dir}/hifiasm_gfa_to_fasta", mode:'copy'

    errorStrategy { task.attempt <= 2 ? "retry" : "ignore" }
    maxRetries 2
    
    conda "${projectDir}/conda_environments/gfatools.yml"
    
    input:
    tuple val(meta), path(gfa)

    output:
    tuple val(meta), path("*.fasta")           , emit: fasta_ch
    path  "versions.yml"                      , emit: versions_ch

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    
    gfatools gfa2fa ${gfa} > ${meta}.fasta
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gfatools: \$(gfatools version 2>&1 | grep 'gfatools' | cut -f2 -d':')
    END_VERSIONS
    """
}
