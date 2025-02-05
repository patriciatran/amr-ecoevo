#!/bin/bash

SAMPLE="$1"
HMM="$2"
STAGING="$3"


hmmsearch --cut_tc -A ${SAMPLE}_vs_${HMM}.sto ${STAGING}/HMM/${hmm}.hmm > ${SAMPLE}_scaffolds_proteins.faa

esl-reformat fasta ${SAMPLE}_vs_${HMM}.sto > ${SAMPLE}_vs_${HMM}.fasta

mkdir -p ${STAGING}/hmm_out
