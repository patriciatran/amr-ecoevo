#!/bin/bash
set -e 
# Make the output folder:

# For example:
mkdir -p /staging/ptran5/binning_wf/LagoonManure-1_S2_L007/mobileOG

MAG="$1"
DB="$2"

echo "Running MobileOG-db identifier on MAG is: ${MAG}"
echo "Path to the diamond DB for MobileOG-db is: ${DB}"

echo "Download scripts"
wget https://github.com/clb21565/mobileOG-db/raw/refs/heads/main/mobileOG-pl/mobileOGs-pl-kyanite.sh
wget https://github.com/clb21565/mobileOG-db/raw/refs/heads/main/mobileOG-pl/mobileOGs-pl-kyanite.py

# change permissions
echo "Change permissions of scripts"
chmod +x mobileOGs-pl-kyanite.sh
chmod +x mobileOGs-pl-kyanite.py

# We don't need to run these lines because I downloaded & the prepped the db in /projects already
# download DB:
#echo "Download DB beatrix-1-6_v1_all"
#wget https://mobileogdb-downloads.s3.us-east-2.amazonaws.com/data-version-files/beatrix-1-6_v1_all.zip?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIA3AL4C2VS6QHGRAFU%2F20251205%2Fus-east-2%2Fs3%2Faws4_request&X-Amz-Date=20251205T195603Z&X-Amz-Expires=900&X-Amz-SignedHeaders=host&X-Amz-Signature=92f704f8227f72849396ad619deca4842662066af22bb9a5092f71c0f2fc2fa9
#unzip beatrix-1-6_v1_all.zip

# Make diamond DB:
#echo "Make diamond database: mobileOG-db-beatrix-1.6.dmnd"
#diamond makedb --in mobileOG-db_beatrix-1.6.All.faa -d mobileOG-db-beatrix-1.6.dmnd

# Run code (change settings as appropriate)
echo "Run code on ${MAG}"
./mobileOGs-pl-kyanite.sh -i ${MAG} -d  ${DB}/mobileOG-db-beatrix-1.6.dmnd -m ${DB}/mobileOG-db-beatrix-1.6-All.csv -k 15 -e 1e-20 -p 90 -q 90

echo "Done, created ${MAG}.faa and ${MAG}.tsv"

ls -lht ${MAG}*

# SETTINGS:
# -i, --input | Input Fasta File
# -k , --kvalue | Number of Diamond Alignments to Report
# -e, --escore | Maximum E-score
# -d, --db | Diamond Database
# -m, --metadata | mobileOG-db metadata (csv file) used to compare to samples
# -p, --pidentvalue | Percent of Identical Matches of samples to metadata
# -q, --queryscore | Percent of query coverage to sample
