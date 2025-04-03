#!/bin/bash

# Set variables
CPUS="$1"

# Create folder to put all the genomes to be plotted on the tree
mkdir genomes

# Copy over all the refined MAGS
cp /staging/ptran5/MAGs/**/bins/refined/*_refine_bins_DASTool_bins/* genomes/.

# List contents
ls genomes/

# Set GTDBTK database path. This could be changed
GTDBTK_DATA_PATH=/projects/bacteriology_tran_data/gtdbtk_v220/
echo $GTDBTK_DATA_PATH

# run gtdbtk de novo workflow and write results in a folder named de_novo_wf (--out_dir)

gtdbtk de_novo_wf --genome_dir genomes/ \
	--outgroup_taxon p__Patescibacteria \
	--bacteria \
	--out_dir de_novo_wf_mag_only \
	--cpus ${CPUS} \
	--extension fa \
	--skip_gtdb_refs \
	--custom_taxonomy_file /staging/ptran5/MAGs/custom_bacteria_taxonomy.tsv

# convert the tree to itol format
gtdbtk convert_to_itol --input_tree de_novo_wf_mag_only/gtdbtk.bac120.decorated.tree --output_tree de_novo_wf_mag_only/gtdbtk.bac120.decorated.itol.tree

# Compress folder and move it to staging.
echo "compressing folder"
tar -czvf de_novo_wf_mag_only.tar.gz de_novo_wf_mag_only

echo "moving folder"
mv de_novo_wf_mag_only.tar.gz  /staging/ptran5/HiteLab/.

# done
