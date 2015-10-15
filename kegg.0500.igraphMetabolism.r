#!/usr/bin/env Rscript
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(magrittr))
suppressPackageStartupMessages(library(igraph))

args = commandArgs(T)
#args = "~/newMeta4j2/misc/"

relationships <- list.files(args[1], pattern="rels$", full=T)    %>%
    lapply(read.table, h=T) %>%
    do.call(rbind,.)                                     %>%
    unique

relationships = lapply(1:nrow(relationships), function(x, df){
       if(df[x,"relationship"] == "produces") {
           df[x,]  %>% select(ko.ID, cpd.ID) %>% setNames(c("start", "end"))
       }else{
           df[x,]  %>% select(cpd.ID, ko.ID) %>% setNames(c("start", "end"))
       }
}, df = relationships) %>% do.call(rbind,.)

## Creates IGRAPH OBJ
wholeMetabolism = graph.data.frame(relationships, directed=TRUE)
save(wholeMetabolism, file=sprintf("%s/wholeMetabolism.rda", args[1]))
