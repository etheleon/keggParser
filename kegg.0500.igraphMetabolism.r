#!/usr/bin/env Rscript
suppressPackageStartupMessages({
    library(tidyverse)
    library(igraph)
})

message("Building igraph obj of metabolism")

args = commandArgs(T)
#args = "~/newMeta4j2/misc/"

message("## Generating edgelist")
suppressMessages({
    relationships =  Sys.glob(sprintf("%s/*rels", args[1])) %>%
        map(read_tsv) %>% bind_rows %>%
        rowwise %>% transmute( start = ifelse(relationship == 'produces', `ko:ID`, `cpd:ID`), end = ifelse(relationship == 'produces', `cpd:ID`, `ko:ID`))
})


message("## Converting edgelist to igraph obj")
wholeMetabolism = graph.data.frame(relationships, directed=TRUE)

message(sprintf("## Saving igraph object to %s/wholeMetabolism.rda", args[1]))
save(wholeMetabolism, file=sprintf("%s/wholeMetabolism.rda", args[1]))
