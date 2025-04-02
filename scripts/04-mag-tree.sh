#!/bin/bash

CPUS="$1"

mkdir genomes
#cp /staging/ptran5/MAGs/**/bins/ genomes/.

cp /staging/ptran5/MAGs/**/bins/refined/*_refine_bins_DASTool_bins/* genomes/.

gtdbtk de_novo_wf --genome_dir genomes/ \
	--outgroup_taxon p__Patescibacteria \
	--bacteria \
	--out_dir de_novo_wf \
	--cpus ${CPUS}

tar -czvf de_novo_wf.tar.gz

mv de_novo_wf.tar.gz  /staging/ptran5/HiteLab/.

