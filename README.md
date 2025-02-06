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

6. Submit your job
   
The repo already comes with a file called `all_hmm.txt` that will be used in the `queue` statement of the submit file.

```
condor_submit hmmer.sub
```

This will submit 752 jobs to CHTC.

6. Count how many hits are obtained for each sample
   
```
cd ~/amr-ecoevo/scripts/logs
grep 'hits satisfying' *
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

# What's next

You can export the aligned fasta file corresponding to each gene (e.g. all `vanR`) and align them, then build multiple phylogenetic trees.



