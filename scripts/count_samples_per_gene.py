from collections import Counter
import sys
import os

def extract_gene_name(fasta_file):
    # Extract gene name from the file name
    base_name = os.path.basename(fasta_file)
    return base_name.split('_vs_')[-1].split('.')[0]

def count_sample_names(fasta_file):
    sample_counts = Counter()
    
    with open(fasta_file, 'r') as file:
        for line in file:
            if line.startswith('>'):
                sample_name = line[1:].split('_')[0]  # Extracting sample name
                sample_counts[sample_name] += 1
    
    return sample_counts

def main():
    if len(sys.argv) != 2:
        print("Usage: python count_fasta_samples.py <fasta_file>")
        sys.exit(1)
    
    fasta_file = sys.argv[1]
    gene_name = extract_gene_name(fasta_file)
    sample_counts = count_sample_names(fasta_file)
    
    with open(f"{gene_name}_counts.tsv", 'w') as out_file:
        out_file.write("Sample\tCount\tGene\n")
        for sample, count in sample_counts.items():
            out_file.write(f"{sample}\t{count}\t{gene_name}\n")

if __name__ == "__main__":
    main()
