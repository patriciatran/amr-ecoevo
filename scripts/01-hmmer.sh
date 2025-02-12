#!/bin/bash
set -e

SAMPLE="$1"
HMM="$2"
STAGING="$3"

ls -lh

echo "$SAMPLE $HMM $STAGING"

hmmsearch --cut_tc -A ${SAMPLE}_vs_${HMM}.sto --tblout ${SAMPLE}_vs_${HMM}.tsv ${HMM}.HMM ${SAMPLE}_renamed_scaffolds_proteins.faa

ls -lh

esl-reformat fasta ${SAMPLE}_vs_${HMM}.sto > ${SAMPLE}_vs_${HMM}.fasta

ls -lh

# delete data file if it's empty so it doesn't get written to staging:
[ -s ${SAMPLE}_vs_${HMM}.fasta ] || rm ${SAMPLE}_vs_${HMM}.fasta
[ -s ${SAMPLE}_vs_${HMM}.tsv ] || rm ${SAMPLE}_vs_${HMM}.tsv

ls -lh
mkdir -p ${STAGING}/HiteLab/hmm_out
