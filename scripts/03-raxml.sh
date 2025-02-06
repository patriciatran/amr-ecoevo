#!/bin/bash

SAMPLE="$1"
STAGING="$2"

# Arguments
#s is the input alignment file
#m is the protein matrix model
# is the number of parsimony tree to go over
#n is the output file name
#p is a seed (non random) so that the analysis can be reproducible
#T is the CPU

raxmlHPC -s ${STAGING}/aln/${SAMPLE}.aln.fasta \
	-m PROTGAMMAWAG \
	-# 20 \
	-n ${SAMPLE} \
	-p 123 \
	-T 4

# All output will begin with the word
#RAxML_*

ls -lht

tar -czvf RAxML_${SAMPLE}.tar.gz RAxML_*

mkdir -p ${STAGING}/raxml
