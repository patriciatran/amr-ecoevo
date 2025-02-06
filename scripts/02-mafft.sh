#!/bin/bash
set -e

SAMPLE="$1"
STAGING="$2"
CPU="$3"

ls -lh

mafft --thread ${CPU} ${SAMPLE}.fasta > ${SAMPLE}.aln.fasta

mkdir -p ${STAGING}/aln
