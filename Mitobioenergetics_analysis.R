## Seahorse mitobioenergetics analysis ##

# Reference: Seahorse report generator User guide

### file = path of .csv file exported from wave software

### lbls<-c("before_olig","after_olig","after_FCCP","after_AA/R") ... labels correspond to the conditions of the readings

### blocks<-c(0,3,6,9,12) ... Blocks corresponds to the number of readings in each condition/ after inhibitor treatment

### acute = TRUE/FALSE ... boolean variable tells whether any readings were collected after an acute treatment given to the cells 

Mitobionergetics_analysis <- function(file,blocks,lbls,acute){
  library(dplyr)
  library(tidyr)
  select <- dplyr::select 
  data<- read.csv(file, skip = 6)
  data %>% select(-Time) %>% mutate(Well_Group = paste(Well,Group.Name,sep = "_&_"))-> dat
  dat_split<- split(dat,as.factor(dat$Well_Group))
  dat_split %>% lapply(function(a) {temp<- mutate(a, Measurement = as.factor(cut(Measurement,blocks, labels=lbls)));return(temp);}) -> subs_dat 
  
  ### Parameter estimation ###
  
  subs_dat %>% lapply(function(x) {nmr<- filter(x,Measurement=="after_AA/R"); return(min(nmr$OCR));}) -> After_AA_R
  subs_dat %>% lapply(function(b) {br<-filter(b,Measurement=="before_olig"); return(br$OCR[length(br$OCR)]);}) -> Before_olig
  subs_dat %>% lapply(function(d) {ao<-filter(d,Measurement=="after_olig"); return(min(ao$OCR));}) -> After_olig
  subs_dat %>% lapply(function(e) {mr<-filter(e,Measurement=="after_FCCP"); return(max(mr$OCR));}) -> After_FCCP
  if (acute==TRUE){
    subs_dat %>% lapply(function(f) {ar<-filter(f$Measurement=="before_acute_inj"); return(ar$OCR[length(ar$OCR)]);}) -> Before_acute_inj
  }
  
  Before_olig<- do.call(rbind,Before_olig)
  After_olig<- do.call(rbind,After_olig)
  After_FCCP<- do.call(rbind,After_FCCP)
  Non_mitochondrial_respiration<- do.call(rbind,After_AA_R)
  
  as.data.frame(Before_olig) %>% mutate(Well_Group = row.names(Before_olig)) %>% rename(BO = V1) -> Before_olig
  as.data.frame(After_olig) %>% mutate(Well_Group = row.names(After_olig)) %>% rename(AO = V1)  -> After_olig
  as.data.frame(After_FCCP) %>% mutate(Well_Group = row.names(After_FCCP)) %>% rename(AF = V1) -> After_FCCP
  as.data.frame(Non_mitochondrial_respiration) %>% mutate(Well_Group = row.names(Non_mitochondrial_respiration)) %>% rename(Non_mitochondrial_respiration = V1) -> NMR
  BO_AO <- inner_join(Before_olig,After_olig,by = "Well_Group")
  BO_AO_AF<- inner_join(BO_AO,After_FCCP,by = "Well_Group")
  data_final<- inner_join(BO_AO_AF,NMR,by = "Well_Group")
  
  data_final %>% mutate(Basal_respiration = BO-Non_mitochondrial_respiration, Maximal_respiration = AF-Non_mitochondrial_respiration, Proton_leak = AO-Non_mitochondrial_respiration, ATP_production = BO-AO) %>%
                mutate(Spare_respiratory_capacity = Maximal_respiration-Basal_respiration, Spare_respiratory_capacity_percen = ((Maximal_respiration/Basal_respiration)*100), Coupling_efficiency = ((ATP_production/Basal_respiration)*100)) -> result
  result %>% select(Well_Group,Basal_respiration,ATP_production,Maximal_respiration,Proton_leak,Spare_respiratory_capacity,Spare_respiratory_capacity_percen,Non_mitochondrial_respiration,Coupling_efficiency) %>%
             separate(Well_Group,c("Well","Group"),sep = "_&_") ->res
  out_file<- paste(file,"_result.csv")
  write.csv(res, out_file,row.names = FALSE)

 
  return(res) 
}
