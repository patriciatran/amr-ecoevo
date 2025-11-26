#!/bin/bash
set -e

SAMPLE="$1"
HMM="$2"
STAGING="$3"
CPU="$4"

ls -lh

echo "$SAMPLE $HMM $STAGING"

hmmsearch --cut_tc -A ${SAMPLE}_vs_${HMM}.sto --tblout ${SAMPLE}_vs_${HMM}.tsv --cpu ${CPU} ${HMM}.HMM ${SAMPLE}_renamed_scaffolds_proteins.faa

ls -lh

esl-reformat fasta ${SAMPLE}_vs_${HMM}.sto > ${SAMPLE}_vs_${HMM}.fasta

ls -lh

if [[ -s "${SAMPLE}_vs_${HMM}.fasta" ]]; then
    echo "${SAMPLE}_vs_${HMM}.fasta is not empty."
else
    echo "${SAMPLE}_vs_${HMM}.fasta is empty. Deleting..."
    rm ${SAMPLE}_vs_${HMM}.fasta
    rm ${SAMPLE}_vs_${HMM}.tsv
fi

ls -lh
mkdir -p ${STAGING}/HiteLab/hmm_out
