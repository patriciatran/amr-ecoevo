#!/bin/bash

FOLDER="$1"

rgi -h

rgi heatmap --input ${FOLDER}/rgi/ \
    --output ${FOLDER}/rgi/heatmap 
