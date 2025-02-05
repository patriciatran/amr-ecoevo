ls
apptainer build hmmer.sif hmmer.def 
ls
apptainer shell -e hmmer.sif
ls
mv hmmer.sif /projects/bacteriology_tran_data/apptainer/.
exit
