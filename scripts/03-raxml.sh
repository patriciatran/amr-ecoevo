#!/bin/bash

SAMPLE="$1"
STAGING="$2"
CPU="$3"
BOOTSTRAP="$4"

echo "SAMPLE: ${SAMPLE}"
echo "STAGING: ${STAGING}"
echo "CPU: ${CPU}"
echo "BOOTSTRAP: ${BOOTSTRAP}"

# Arguments
#s is the input alignment file
#m is the protein matrix model (PROTGAMMAAUTO)
# -x 12345 Bootstrap random number (can also use -b , but -x is rapid boostrap and is faster)
# -# is the number of boostrap searched (in this example, it's 100)
#n is the output file name
#p is a seed (non random) so that the analysis can be reproducible
#T is the CPU
# This will do 20 Maximum Likelihood searches (ML search)

raxmlHPC -s ${STAGING}/aln/${SAMPLE}.aln.fasta \
        -m PROTGAMMAAUTO \
        -x 12345 \
        -# ${BOOTSTRAP} \
        -n ${SAMPLE}_${BOOTSTRAP} \
        -p 123 \
        -T ${CPU}

# All output will begin with the word
#RAxML_*

ls -lht

tar -czvf RAxML_${SAMPLE}_${BOOTSTRAP}.tar.gz RAxML_*

mkdir -p ${STAGING}/raxml
