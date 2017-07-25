#!/usr/bin/env Rscript
library(tidyverse)

args=commandArgs(T)

root = args[1]

K00000 = data.frame('ko:K00000', "Unassigned", "Unassigned", "ko", NA) %>% 
    setNames(c("ko:ID", "name", "definition", "l:label", "pathway"))

suppressMessages({
    redun =  Sys.glob(sprintf("%s/misc/*_konodes", root)) %>% 
        map(read_tsv) %>% bind_rows
})
merged = redun %>% group_by(`ko:ID`) %>% 
    summarise(pathway=paste(pathway, collapse="|"))

redun %>% select(`ko:ID`:`l:label`) %>% unique %>% merge(merged) %>% rbind(K00000) %>%
    write_tsv(sprintf("%s/out/nodes/newkonodes", root))
