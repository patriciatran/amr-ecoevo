#!/bin/bash

NETID="$1"

cat /staging/${NETID}/*renamed* >> all_samples_renamed_scaffolds_proteins.faa
