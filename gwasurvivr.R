setwd("/SurvivalGWAS_SV")
library("gwasurvivr")
sample<-"/sample_file_stroke_progression.txt"
data<-read.table(sample, header=T)
inclusion_list<-data$IID
data$outcome<-as.numeric(data$outcome)
data$follow_up_time<-as.numeric(data$time)
for (i in (1:50)) {
plinkCoxSurv(bed.file=paste0("/data/ukbiobank/genetic/variants/arrays/imputed/released/derived/2018-09-18/format/bfiles/chrtemplate/ukb_chrtemplate_part",i,".bed",sep=""),
        covariate.file=data,id.column="FID",sample.ids=inclusion_list,
        event="outcome",time.to.event="follow_up_time", 
        covariates=c("PC1","PC2","PC3","PC4","PC5","PC6","PC7","PC8","PC9","PC10","sex","chip","AGE"), 
        inter.term=NULL,print.covs="only",
        out.file=paste0("gwasurvivr_stroke_mace_ukb_filtered1y_chrtemplate_part",i,".txt",sep=""), 
        chunk.size=50, maf.filter=0.01, verbose=TRUE)
}
