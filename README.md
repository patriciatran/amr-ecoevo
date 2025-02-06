# amr-ecoevo

# Purpose
Display genomic variance between AMR+ genes in assembled metagenomes.

# Workflow
Reads are first trimmed, host-removed, quality-checked and assembled into contigs. 
Then DNA contigs are translated into proteins (`_proteins.faa`) using a program such as pprodigal. 
This program runs HMM search using the reference catalogue of AMR genes (https://www.ncbi.nlm.nih.gov/pathogens/docs/HMM_catalog/)
The output is a FASTA file of the given genes in given assemblies.

To count how many hits are obtained for each sample:
```
grep 'hits satisfying' *
```

Scaffolds are then aligned (e.g. using MAFFT), then can be used to make a phylogenetic tree.
You will get an individual phylogenetic tree for each gene.


