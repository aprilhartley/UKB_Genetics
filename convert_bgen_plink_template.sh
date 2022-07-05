#!/bin/bash

#SBATCH -p mrcieu,mrcieu2,hmem,cpu
#SBATCH --job-name file_conversion_chrtemplate
#SBATCH -o file_conversion_chrtemplate.log
#SBATCH -e file_conversion_chrtemplate.err
#SBATCH --nodes=1 --tasks-per-node=14
#SBATCH --mem-per-cpu=8000
#SBATCH --time=2-00:00:00

module load apps/plink/2.00
awk 'NR>16 {print $2}' "/mnt/storage/private/mrcieu/data/ukbiobank/genetic/variants/arrays/imputed/released/2018-09-18/data/snp-stats/data.chr0template.snp-stats" >
  chrtemplate_snps
x=$(wc -l < "chrtemplate_snps")
y=$(($x/50))
awk -v var1=$y  'NR<=var1 {print $0}'  chrtemplate_snps > chrtemplate_snps_part1

for i in {1..50}; do
  j=$(($i+1))
  min=$(($y*$i))
  max=$(($y*$j))
  awk -v var1=$min -v var2=$max 'NR>=var1 && NR<=var2 {print $0}'  chrtemplate_snps > chrtemplate_snps_part${i}
done

for i in {1..50}; do
  plink2 \
  --bgen /mnt/storage/private/mrcieu/data/ukbiobank/genetic/variants/arrays/imputed/released/2018-09-18/data/dosage_bgen/data.chr0template.bgen \
  --id-delim ' ' \
  --sample /mnt/storage/private/mrcieu/data/ukbiobank/genetic/variants/arrays/imputed/released/2018-09-18/data/dosage_bgen/data.chr1-22.sample \
  --make-bed --extract chrtemplate_snps_part${i} \
  --out ukb_chrtemplate_part${i}
done
