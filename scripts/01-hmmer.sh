#!/bin/bash
set -e

SAMPLE="$1"
HMM="$2"
STAGING="$3"

ls -lh

echo "$SAMPLE $HMM $STAGING"

hmmsearch --cut_tc -A ${SAMPLE}_vs_${HMM}.sto ${HMM}.HMM ${SAMPLE}_scaffolds_proteins.faa

ls -lh

esl-reformat fasta ${SAMPLE}_vs_${HMM}.sto > ${SAMPLE}_vs_${HMM}.fasta

ls -lh

mkdir -p ${STAGING}/HiteLab/hmm_out
