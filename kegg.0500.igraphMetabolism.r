#!/usr/bin/env Rscript
library(dplyr, warn.conflicts=FALSE)
library(magrittr)
library(igraph)

args = commandArgs(T)
# output eg. ~/newMeta4j/misc/

relationships <- list.files(args[1])     %>%
grep("rels$", ., value=T)                            %>%
paste(args[1], ., sep="/")                           %>%
lapply(function(fileName) read.table(fileName, h=T)) %>%
do.call(rbind,.)                                     %>%
unique


## Creates IGRAPH OBJ
wholeMetabolism = graph.data.frame(relationships[,1:2], directed=T)
save(wholeMetabolism, file=sprintf("%s/wholeMetabolism.rda", args[1])

