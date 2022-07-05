#!/bin/bash
#SBATCH --job-name=filter-bgenix-morris-snps
#SBATCH --nodes=1
#SBATCH --tasks-per-node=28
#SBATCH --time=1:00:00
#SBATCH -e sbatch_error
#SBATCH --partition=veryshort

#script adapted from Sean Harrison's document on slack page
#creates a BGEN file with the 97 BMI SNPs identified by Locke et al (Nature, 2015)
#then extracts dosage data and merges it into a raw file which can be read into R

module load apps/bgen/1.1.4

bgen_pattern=/data/ukbiobank/genetic/variants/arrays/imputed/released/2018-09-18/data/dosage_bgen/data.chrCHROM.bgen

bgen_index_pattern=/data/ukbiobank/genetic/variants/arrays/imputed/released/2018-09-18/data/dosage_bgen/data.chrCHROM.bgen.bgi

snp_list=Locke_BMI_GWS_SNPs.txt
temp_geno_prefix=temp_genos
for chrom in {1..22}; do
  chrom_padd=$(printf "%0*d\n" 2 $chrom)
  inbgen=${bgen_pattern/CHROM/$chrom_padd}
  inbgenidx=${bgen_index_pattern/CHROM/$chrom_padd}
  bgenix -g $inbgen -i $inbgenidx -incl-rsids $snp_list > $temp_geno_prefix.$chrom_padd.bgen
done
cmd=""
for chrom in {01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,20,21,22}; do
  cmd="${cmd} ${temp_geno_prefix}.${chrom}.bgen"
done
cat-bgen -g ${cmd} -og instruments_bmi.bgen
# Remove temp genos
rm $temp_geno_prefix*

module add apps/plink/2.00
plink2 --bgen instruments_bmi.bgen --hard-call-threshold 0.4999 --export A --out instruments_bmi
rm instruments_bmi.bgen
