import os
import argparse
from pathlib import Path

def extract_sample_name(filename):
    """Extracts the sample name from a filename with the format sample_scaffolds_proteins.faa."""
    return filename.split("_")[0]  # Take the first part before the first underscore

def add_sample_to_fasta_headers(fasta_file, output_file):
    """Prepend the extracted sample name to each FASTA header."""
    sample_name = extract_sample_name(Path(fasta_file).stem)  # Extract sample name
    with open(fasta_file, "r") as infile, open(output_file, "w") as outfile:
        for line in infile:
            if line.startswith(">"):
                outfile.write(f">{sample_name}_{line[1:].strip()}\n")  # Prepend sample name
            else:
                outfile.write(line)

def main():
    parser = argparse.ArgumentParser(description="Prepend sample name (extracted from filename) to FASTA headers.")
    parser.add_argument("fasta_file", help="Input FASTA file")
    parser.add_argument("-o", "--output", help="Output file (default: input_filename_modified.fasta)", default=None)

    args = parser.parse_args()
    
    output_file = args.output if args.output else f"{Path(args.fasta_file).stem}_modified.fasta"
    
    add_sample_to_fasta_headers(args.fasta_file, output_file)
    print(f"Modified FASTA saved as: {output_file}")

if __name__ == "__main__":
    main()
