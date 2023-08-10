---
title: "101-diversity-loci"
output: html_document
date: "2023-08-08"
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE, warning=FALSE, message=FALSE)
```

```{r}
library(tidyverse)
```

     
Samples

_norm - normalized for sample sizes between basins 100-130

filtered - filtered based on 'populations' hybridization results in contract (low read counts, potential hybrids, removed)
norm- then reduced sample sizes for each 'population' to be more consistent across populations    

LCT_norm.bamlist   467 samples -> distributed across Truckee, Walker, Carson 

Diversity loci for each location with thetas.     
Walker, Carson, Truckee, Independence Lake, Heenan Lake (use Heenan Lake fish with better sample sizes)          

There are several   

_1_ We have Walker, Carson, Truckee, Independence Lake from 2016 and Heenan Lake from 2016     
_2_ Should examine readcounts/average coverage across all samples in these bamlists
_3_ Identify top_n samples from each group Walker -> Mix up , Carson -> Mix up , Truckee- Mix up, separate Independence Lake and Heenan Lake   
_4_ Call SNPs and filter for HWE/Missingness/MAF > 0.1-0.4
_5_ Do PCA for funsies
_6_ Theta/Tajima's D for larger groups (from called SNPs)    

Macklin Does not go in Truckee because it is in the Yuba
Do not include Oharell

```{r}
meta<-read_csv("meta/LCT_norm_meta-08092023.csv")
meta
```

```{r}
bamlist<-read_tsv(file="bamlists/LCT_norm.bamlist", col_names = c("Path"))
bamlist$SampleID<-gsub(".sort.flt.bam","",bamlist$Path)
bamlist$SampleID<-gsub("/home.+/","",bamlist$SampleID)
bamlist<-bamlist %>% select(SampleID, Path)
bamlist
```

```{r}
m2<-meta %>% left_join(bamlist)
write_csv(m2, file="meta/lct-norm-with-path.csv")
```

note mismatch with byday samples at line 295, editing those 

Ok, so we don't know the coverage of these samples. I'd like to compute read counts and coverage.    


