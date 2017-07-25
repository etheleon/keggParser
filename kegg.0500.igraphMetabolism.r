#!/usr/bin/env Rscript
suppressPackageStartupMessages({
    library(dplyr)
    library(magrittr)
    library(igraph)
})

message("Building igraph obj of metabolism")

args = commandArgs(T)
#args = "~/newMeta4j2/misc/"



relationships <- list.files(args[1], pattern="rels$", full=T)    %>%
    lapply(read.table, h=T) %>%
    do.call(rbind,.)                                     %>%
    unique

message("## Generating edgelist")

relationships = lapply(1:nrow(relationships), function(x, df){
       if(df[x,"relationship"] == "produces") {
           df[x,]  %>% select(ko.ID, cpd.ID) %>% setNames(c("start", "end"))
       }else{
           df[x,]  %>% select(cpd.ID, ko.ID) %>% setNames(c("start", "end"))
       }
}, df = relationships) %>% do.call(rbind,.)

## Creates IGRAPH OBJ
message("## Converting edgelist to igraph obj")
wholeMetabolism = graph.data.frame(relationships, directed=TRUE)

message("## Saving igraph object to %s/wholeMetabolism.rda", args[1]))
save(wholeMetabolism, file=sprintf("%s/wholeMetabolism.rda", args[1]))
