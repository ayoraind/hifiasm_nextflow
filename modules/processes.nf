process HIFIASM {
    tag "$meta"
    publishDir "${params.output_dir}/$meta", mode:'copy'

    errorStrategy { task.attempt <= 2 ? "retry" : "ignore" }
    maxRetries 2
    
    conda "${projectDir}/conda_environments/hifiasm.yml"
    
    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("*")                , emit: output_ch
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
