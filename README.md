# Scripts for manipulation and analysis of UK Biobank genotype data
<br>

**extracting_snps_ukbb_bmi.sh** <br>
Code for extracting SNPs from UK Biobank bgen files. Requires a .txt file with the list of SNPs to extract (Locke_BMI_GWS_SNPs.txt). Generates a file instruments_bmi.raw hat can be read into R/Stata for One sample MR etc. Very quick to run, normally completes within minutes.

**prs_script_bmi.sh** <br>
Code for generating a BMI PRS based on genome-wide significant SNPs in UK Biobank. Requires a score file containing three columns: SNP A1 BETA. Can include extra columns with the inclusion of  --score locke_bmi_weights.txt 1 2 3 header to specify the columns to read the SNP Ids, effect alleles and weightes from respectively. The cols=+scoresums adds a summed score column (default is the average).  

**convert_bgen_plink_template.sh** <br>
code to convert plink .bgen files to Plink files required for GWASurvivR package. Generates files in 50 chunks per chromosome (larger chunks generated file write failures). Runs much quicker than bcftools. Generate a script per chromosome using the code:

```
for i in {1..9}; do cp convert_bgen_plink_template.sh convert_bgen_plink_chr${i}.sh; sed -i 's/template/{$i}/g'  convert_bgen_plink_chr${i}.sh;done
for i in {10..22}; do cp convert_bgen_plink_template.sh convert_bgen_plink_chr${i}.sh; sed -i 's/0template/{$i}/g'  convert_bgen_plink_chr${i}.sh; sed -i 's/template/{$i}/g'  convert_bgen_plink_chr${i}.sh;done
```

**gwasurvivr.R** <br>
Script to run survival (cox proportional hazards) GWAS in R using the gwasurvivr package. Runs on Plink files in 50 chunks per chromosome. Need to specific maximum memory from the node in the bash script to ensure the job completes. Output files can be combined using the code:

```
for i in {1..22} ; do
cat OUTPUT_FILE_chr${i}_part*.txt.coxph > OUTPUT_FILE_chr${i}.coxph
awk 'NR==1 || $1!="RSID" {print $0}'  OUTPUT_FILE_chr${i}.coxph > temp
mv temp OUTPUT_FILE_chr${i}.coxph
gzip OUTPUT_FILE_chr${i}.coxph
rm OUTPUT_FILE_chr${i}_part*.txt.coxph
done
```
