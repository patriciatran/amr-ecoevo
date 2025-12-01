# amr-ecoevo

# Purpose
The purpose of this workflow is to identify variants of AMR genes among assembled metagenome-assembled-genomes. 

# Workflow
Reads are first trimmed, host-removed, quality-checked and assembled into contigs. 
Then DNA contigs are translated into proteins (`_proteins.faa`) using a program such as pprodigal. 

This program runs HMM search using the reference catalogue of AMR genes (https://www.ncbi.nlm.nih.gov/pathogens/docs/HMM_catalog/)
The output is a FASTA file of the given genes in given assemblies.

## Input:
A faa file for each assembly.

## Output:
- A folder containing .fasta file corresponding to each AMR. 
- Newick-formatted file for single-gene phylogenies for each AMR gene
- A phylogenetic tree for all the MAGs
- A table with the Resistance Gene Identifier software results

# Step-by-Step instructions

1. Clone the directory to CHTC:
```
ssh netid@ap2002.chtc.wisc.edu
# enter your password
git clone https://github.com/patriciatran/amr-ecoevo.git
```

2. Download a copy of the NCBI AMR gene HMM profile.
We will download a copy of the HMM profile from AMRFinder, somewhere in your staging folder.
To read more about HMM profiles, and why they are use, I recommend: https://www.ebi.ac.uk/training/online/courses/pfam-creating-protein-families/what-are-profile-hidden-markov-models-hmms/

```
cd /staging/netid/
wget NCBIfam-AMRFinder.HMM.tar.gz
# unzip
tar -xzvf NCBIfam-AMRFinder.HMM.tar.gz
```

You will now have a folder labelled `HMM/` with over 700 files with the extension `.HMM`. 

3. Create a software container or use a pre-made one (optional)

These script submit files already link to the containers located at `/projects/bacteriology_tran_data/apptainer/hmmer.sif`. 

If you want to build your own containers, you can use the `build.sub` script under the `recipes/` folder to build an Apptainer SIF file, and move it to your `staging/netid` folder.
The steps for that would be:
```
cd ~/amr-ecoevo
cd recipes
condor_submit -i build.sub
apptainer build hmmer.sif hmmer.def
# test container
apptainer shell -e hmmer.sif
which hmmsearch
which esl-reformat
exit
# move your SIF file to staging
mv hmmer.sif /staging/netid/.
exit
```

4. Modify the `.sh` and `.sub` file as necessary
   
Open the files located under `scripts` using a terminal text editor such as nano and edit the file paths as necessary. Likely you will need to modify the path to the container image sif, the staging folder path at least.

5. Rename fasta headers

Each proteins.faa file only starts with NODE_#, but when we make the phylogenetic tree, it would be helpful to have an identifier to say where the sample comes from. Therefore, I wrote the `add_sample_to_fasta.py` python script to append the sample name before the word NODE_#.

```
condor_submit 00-add-sample-to-fasta.sub
```

7. Combine files (recommenaded)

Depending on how many samples you have, you will multiple that number by 752 and then by 2 to tell you how many output files to expect. If that is beyond your CHTC items quota, you might want to combine all the `.faa` files into one before running the hmm search job.

```
condor_submit combined_fasta.sub
```

If you run this script, this will create a file named `all_samples_renamed_scaffolds_proteins.faa` in your staging folder.

6. Perform HMM search 
   
The repo already comes with a file called `sample_hmm_combinations.csv` that will be used in the `queue` statement of the submit file. This will perform of HMM search of all the AMRFinder genes against all your metagenomic assemblies. Note, this only uses 2CPU. Even on a large file (e.g. 82GB) the search is relatively quick. Increasing beyond 2CPU does not improve performance (see hmmer documentation)

```
condor_submit 01-hmmer.sub
```

This will submit 752 jobs to CHTC.

6. Move to your logs folder and count how many hits are obtained for each sample
   
```
cd logs
grep 'hits satisfying' hmm_all_samples*
```
You might see something like this:
```
[ptran5@ap2002 logs]$ grep 'hits satisfying' * | head
hmm_SampleA_AAC_6p_group_E-NCBIFAM_3954240_44.out:# Alignment of 57 hits satisfying inclusion thresholds saved to: SampleA_vs_AAC_6p_group_E-NCBIFAM.sto
hmm_SampleA_AAC_6p_Ia_fam-NCBIFAM_3954240_46.out:# Alignment of 1 hits satisfying inclusion thresholds saved to: SampleA_vs_AAC_6p_Ia_fam-NCBIFAM.sto
hmm_SampleA_ABCF_CplR-NCBIFAM_3954240_67.out:# Alignment of 1 hits satisfying inclusion thresholds saved to: SampleA_vs_ABCF_CplR-NCBIFAM.sto
hmm_SampleA_ABCF_Lsa_all-NCBIFAM_3954240_68.out:# Alignment of 2 hits satisfying inclusion thresholds saved to: SampleA_vs_ABCF_Lsa_all-NCBIFAM.sto
hmm_SampleA_ABCF_Msr_all-NCBIFAM_3954240_69.out:# Alignment of 3 hits satisfying inclusion thresholds saved to: SampleA_vs_ABCF_Msr_all-NCBIFAM.sto
hmm_SampleA_ANT_3pp_I-NCBIFAM_3954240_84.out:# Alignment of 5 hits satisfying inclusion thresholds saved to: SampleA_vs_ANT_3pp_I-NCBIFAM.sto
hmm_SampleA_ANT_4p_II-NCBIFAM_3954240_87.out:# Alignment of 1 hits satisfying inclusion thresholds saved to: SampleA_vs_ANT_4p_II-NCBIFAM.sto
hmm_SampleA_ANT_6_aadS-NCBIFAM_3954240_90.out:# Alignment of 3 hits satisfying inclusion thresholds saved to: SampleA_vs_ANT_6_aadS-NCBIFAM.sto
hmm_SampleA_ANT_6-NCBIFAM_3954240_92.out:# Alignment of 7 hits satisfying inclusion thresholds saved to: SampleA_vs_ANT_6-NCBIFAM.sto
hmm_SampleA_ANT_9-NCBIFAM_3954240_95.out:# Alignment of 2 hits satisfying inclusion thresholds saved to: SampleA_vs_ANT_9-NCBIFAM.sto
```

You can pipe this to a file, and use it for plotting later one. Essentially, you have a table on how many variants exist in each samples.

```
grep 'hits satisfying' hmm_all_samples_* > ../table_hits_all_HMM.txt
```

7. Get a list of all FASTA files > size 0

In the previous submit file, `01-hmmer.sub` will write a `.fasta` file output even if there were no genes found. To only pick genes with hits for the alignment steps, we will filter the output files and create a list of samples with hits only.
Replace netid with yours

```
# cd back to where the 01-, 02-, 03, etc. submit files are
cd ..
find /staging/netid/hmm_out/ -type f -size +0c > AMR_found.txt
sed -i 's|/staging/netid/hmm_out/||g' AMR_found.txt 
sed -i 's|.fasta||g' AMR_found.txt
wc -l AMR_found.txt
```
The `AMR_found.txt` file should now be in the same folder as the 02-mafft.sub file, because the last line for the queue statement is looking for the `AMR_found.txt` file. You should also head or cat the AMR_found.txt file. It should be a 1 column file with the list of AMR with positive (non-zero) hits.

8. Run the alignment for each protein

Here, we will run the program MAFFT to align proteins. We will obtain 1 alignment file per protein.
Edit the `02-mafft.sub` file with the netid as appropriate. 

```
condor_submit 02-mafft.sub
```

This takes less than 2 minutes, even on the full dataset.
You can sort the output files by size:

```
ll -lhS /staging/netid/HiteLab/aln
```

9. Run a maximum likelihood tree with bootstrapping for each individual AMR gene

The goal here is a to create a single-gene phylogeny for each of the AMR found. 
In the `03-raxml.sub` script, we set bootstrap values to be 100, but you can easily edit that to say 500, 1000, etc. as appropriate. 
Once again change file paths to `staging` as necessary. This reuses the sample list `AMR_found.txt` for the queue statement.

>[!NOTE]
>RAxML as many settings, but here we use the protein gamma automatic model (-m). To make it reproducible, we also added a seed # and -b for any steps that would otherwise use a randomly generated seed.

```
condor_submit 03-raxml.sh
```

10. You will now have a Newick-formatted tree file for each gene

11. Plot
You can use R and the example code to create a figure showing the number of genomic variants for each gene in your samples.

# Other things to do:

This repo contains 3 additional scripts to:
1) Generating a phylogenetic tree based on pre-computed GTDB-tk results (not included in this repo)
2) Running the RGI software and obtaining a table of results and a heatmap
Together, these analyses can be combined into a ITOL tree figure.



12. Run gtdbtk-tk de_novo to create the ITOL tree backbone.
For this script, you will need a folder containing all your MAGs, and a custom_bacteria_taxonomy file.
You can obtain these files by running GTDB-tk. 

>[!NOTE] If you have ran the [binning_wf](https://github.com/UW-Madison-Bacteriology-Bioinformatics/binning_wf/tree/main), you will have those files in the taxonomy folder already.

```
condor_submit 04-mag-tree1.sub
```
This will create the ITOL formatted tree that you can use in the https://itol.embl.de/ tree editor.

>[!WARNING] For steps 13 and 14, pay attention to all the file paths! the example in this folder was for a single sample example. If you'd like to run this on multiple samples, edit the queue statement to iterate through your samples.

13. To run the RGI script

```
condor_submit 05-rgi.sub
```
For each MAG in each sample folder, you will get an json and rgi_out.txt output file. 

14. To create a heatmap (optional)

```
condor_submit 06-rgi-heatmap.sub
```


# Notes

This workflow was designed by Dr. Patricia Tran for a collaboration with Dr. Colette Nickodem and Dr. Jessica Hite. 
