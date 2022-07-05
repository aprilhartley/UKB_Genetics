#!/bin/bash
#SBATCH --job-name=jackknife-prs
#SBATCH --nodes=1
#SBATCH --tasks-per-node=28
#SBATCH --time=2-00:00:00
#SBATCH -e prs_error
#SBATCH --partition=mrcieu,mrcieu2

module load apps/plink/2.00
module load apps/bgen/1.1.4

bgen_pattern=/data/ukbiobank/genetic/variants/arrays/imputed/released/2018-09-18/data/dosage_bgen/data.chrCHROM.bgen

bgen_index_pattern=/data/ukbiobank/genetic/variants/arrays/imputed/released/2018-09-18/data/dosage_bgen/data.chrCHROM.bgen.bgi

snp_list=bmi_snps.txt
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
cat-bgen -g ${cmd} -og bmi_dosage.bgen


plink2 \
  --bgen bmi_dosage.bgen  \
  --score locke_bmi_weights.txt cols=+scoresums \
  --out bmi_score_ukbb
