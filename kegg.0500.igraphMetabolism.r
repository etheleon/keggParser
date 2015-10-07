#!/usr/bin/env Rscript
suppressMessages(library(dplyr, warn.conflicts=FALSE))
suppressMessages(library(magrittr))
suppressMessages(library(igraph))

args = commandArgs(T)
#args = "~/newMeta4j2/misc/"

relationships <- list.files(args[1])                                  %>%
    grep("rels$", ., value=T)                            %>%
    paste(args[1], ., sep="/")                           %>%
    lapply(function(fileName) read.table(fileName, h=T)) %>%
    do.call(rbind,.)                                     %>%
    unique

relationships = lapply(1:nrow(relationships), function(x, df){
       if(df[x,"relationship"] == "produces") {
           df[x,]  %>% select(ko.string.koid, cpd.string.cpdid) %>% setNames(c("start", "end"))
       }else{
           df[x,]  %>% select(cpd.string.cpdid, ko.string.koid) %>% setNames(c("start", "end"))
       }
}, df = relationships) %>% do.call(rbind,.)

## Creates IGRAPH OBJ
wholeMetabolism = graph.data.frame(relationships, directed=TRUE)
save(wholeMetabolism, file=sprintf("%s/wholeMetabolism.rda", args[1]))
