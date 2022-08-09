### Code for analysis of AHR data ###
setwd("C:/Users/Naveen/Desktop")
col_names<- as.character(read.csv(file = file.choose(),header = FALSE,skip = 7,nrows = 1,as.is = TRUE ))
col_names<-make.unique(col_names)
dat<-read.csv(file = file.choose(),skip = 9,header = FALSE)
colnames(dat)<-col_names
dat_subset<- subset(dat,select = c("Subject","Concentration","Excluded.5","Rrs", "Ers"))
library(zoo)

first_nonNA<- min(which(!is.na(dat_subset$Concentration)))
rem_rows<- seq(1,first_nonNA-1,by = 1)
dat_subset<- dat_subset[-rem_rows,]
dat_subset$Concentration<-na.locf(dat_subset$Concentration)
dat_complete<- na.omit(dat_subset)
dat_pruned<- dat_complete[grep("No",dat_complete$Excluded.5),]
#dat_pruned<- dat_pruned[,setdiff(colnames(dat_pruned),"Excluded.5")]
library(dplyr)
select <- dplyr::select
dat_pruned %>% select(-Excluded.5) %>% group_by(Subject,Concentration) %>% summarise(Subjectwise_Mean_Rrs=mean(Rrs), Subjectwise_Mean_Ers = mean(Ers))-> dat_final
write.csv(dat_final,"Biomass_Chronic_model_compiled.csv",row.names = FALSE)
