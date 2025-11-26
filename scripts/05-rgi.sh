#!/bin/bash

echo "Showing variables..."
MAG="$1"
CPU="$2"

echo "DEBUG: print contents"
ls -lht 

echo "DEBUG: printing help page"
rgi -h

echo "DEBUG: Running code"
rgi load --card_json /projects/bacteriology_tran_data/CARD/card.json --local

rgi database --version --local


rgi main -i ${MAG} \
	-o ${MAG}_rgi.out \
	-t contig \
	-n ${CPU} \
	--local \
	--clean

echo "DEBUG done...listing files...."

ls -lht
