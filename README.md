# amr-ecoevo

# Purpose
Display genomic variance between AMR+ genes in assembled metagenomes.

# Workflow
Reads are first trimmed, host-removed, quality-checked and assembled into contigs. 
Then DNA contigs are translated into proteins (`_proteins.faa`) using a program such as pprodigal. 

This program runs HMM search using the reference catalogue of AMR genes (https://www.ncbi.nlm.nih.gov/pathogens/docs/HMM_catalog/)
The output is a FASTA file of the given genes in given assemblies.

## Input:
A faa file for each assembly.

## Output:
A folder containing .fasta file corresponding to each AMR. 

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

3. Create a software container or use a pre-made one

You can use the `build.sub` script under the `recipes/` folder to build an Apptainer SIF file, and move it to your `staging/netid` folder.
Otherwise, you can use the one located at `/projects/bacteriology_tran_data/apptainer/hmmer.sif`. 

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

7. Combine files (optional)

Depending on how many samples you have, you will multiple that number by 752 and then by 2 to tell you how many output files to expect. If that is beyond your CHTC items quota, you might want to combine all the `.faa` files into one before running the hmm search job.

```
condor_submit combined_fasta.sub
```

6. Perform HMM search
   
The repo already comes with a file called `all_hmm.txt` that will be used in the `queue` statement of the submit file. This will perform of HMM search of all the AMRFinder genes against all your metagenomic assemblies. Note, this only uses 2CPU. Even on a large file (e.g. 82GB) the search is relatively quick. Increasing beyond 2CPU does not improve performance (see hmmer documentation)

```
condor_submit 01-hmmer.sub
```

This will submit 752 jobs to CHTC.

6. Count how many hits are obtained for each sample
   
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
grep 'hits satisfying' logs/hmm_all_samples_* > ../table_hits_all_HMM.txt
```

7. Get a list of all FASTA files > size 0

`01-hmmer.sub` will write a `.fasta` file output even if there were no genes found. To only pick genes with hits for the alignment steps, we will filter the output files and create a list of samples with hits only.
Replace netid with yours

```
cd ..
find /staging/netid/hmm_out/ -type f -size +0c > AMR_found.txt
sed -i 's|/staging/netid/hmm_out/||g' AMR_found.txt 
sed -i 's|.fasta||g' AMR_found.txt
wc -l AMR_found.txt
```

8. Run the alignment for each protein

Here, we will run the program MAFFT to align proteins. We will obtain 1 alignment file per protein.
Edit the `02-mafft.sub` file with the netid as appropriate. 

```
condor_submit 02-mafft.sub
```

This takes less than 2 minutes, even on the full dataset.
You can sort the output files by size:

```
ll -lhS /staging/$USER/HiteLab/aln
```

9. Run a maximum likelihood tree with bootstrapping.

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



