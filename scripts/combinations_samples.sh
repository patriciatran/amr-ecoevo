#!/bin/bash

# Check for correct number of arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <samples_file> <hmm_file>"
    exit 1
fi

SAMPLES_FILE="$1"
HMM_FILE="$2"
OUTPUT_FILE="sample_hmm_combinations.csv"

# Check if files exist
if [ ! -f "$SAMPLES_FILE" ] || [ ! -f "$HMM_FILE" ]; then
    echo "Error: One or both input files do not exist."
    exit 1
fi

# Create the output file and add a header
touch "$OUTPUT_FILE"

# Generate all combinations
while IFS= read -r sample; do
    while IFS= read -r hmm; do
        echo "$sample,$hmm" >> "$OUTPUT_FILE"
    done < "$HMM_FILE"
done < "$SAMPLES_FILE"

echo "Combinations written to $OUTPUT_FILE"
