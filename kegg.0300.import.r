#!/usr/bin/env Rscript

suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(magrittr))
suppressPackageStartupMessages(library(XML))
suppressPackageStartupMessages(library(parallel))

#args=c(
#"~/KEGG/KEGG_SEPT_2014", #KEGG root FTP directory
#"~/db/neo4j/misc",       #cpd and node data directory
#1
#)
#args = c("~/simulationDB", "~/simulationDB/misc")
args=commandArgs(T)

kegg.directory = args[1]
root           = args[2]
mccores        = args[3]

pathwayListing=sprintf("%s/xml/kgml/metabolic/ko/", kegg.directory) %>% list.files(full.names=T)

#' linker_ko2rxn links reactions with their respective KOs
#' only processes entries in the XML with graphics as one of the names
#' @param x each entry in the KEGG xml for that pathway

linker_ko2rxn = function(x){
    isGraphics = "graphics" %in% names(x)
    if(isGraphics){
        isOrtholog = x$.attrs[which(names(x$.attrs)=='type')]=='ortholog'
        if(isOrtholog){
            reactions  =  x$.attrs[names(x$.attrs) == 'reaction'] %>% strsplit(" ") %>% unlist
            name       =  x$.attrs[names(x$.attrs) == 'name']     %>% strsplit(" ") %>% unlist
            do.call(rbind,lapply(reactions, function(rxn) { 
            do.call(rbind,lapply(name, function(naa){
                data.frame(reaction=rxn,name=naa)
            })) }))
        }else{"not ortholog"}
    }else{warning("not graphic")}
}

#' makeEdges the
#' returns all edges
#' @param x reactions
#' @param ko2rxn the output from linker_ko2rxn 
#' @param listing pathway name
makeEdges = function(x, ko2rxn, listing){
    rxnID          = x$.attrs["name"] %>% strsplit(" ") %>% unlist # name
    rxnDIR = x$.attrs["type"]                                      # reaction type
    kos.in.pathway = ko2rxn %>% filter(reaction %in% rxnID) %$% as.character(name)
    isAReaction = sum(c("substrate", "product") %in% names(x)) == 2
    if(isAReaction){
        list(substrates = x[["substrate"]][["name"]] %>% strsplit(" ") %>% unlist,
             products   = x[["product"]][["name"]] %>% strsplit(" ") %>% unlist) %>%
        lapply(function(cpdS){
                   lapply(cpdS, function(cpd){
                              lapply(kos.in.pathway, function (ko) data.frame(cpd, ko, rxnID, rxnDIR,stringsAsFactors=F)) %>%
                                  do.call(rbind,.)
            }) %>% do.call(rbind,.)
             })
    }else{warning(sprintf("%s has no valid reactions with substrates and products", listing)); NULL}
}

#' writeEdges
#' @param sub2ko in the reaction of substrate to ko
#' @param ko2pdt opposite direction
#' @param root the root directory
#' @param pathway.info dataframe containing the neccessary information
#' output

writeEdges <- function(sub2ko, ko2pdt, root, pathway.info){
    rbind(
        sub2ko %>% select(-rxnDIR),
        ko2pdt %>% filter(rxnDIR == 'reversible') %>% select(-rxnDIR)
    ) %>% mutate(relationship='substrateof') %>%
    write.table(sprintf("%s/%s_cpd2ko.rels",root, pathway.info$name),
        quote = F, row.names = F, sep = "\t",
        col.names = c("cpd:ID","ko:ID","rxnID","relationship"))

    rbind(
            ko2pdt %>% select(-rxnDIR),
            sub2ko %>% filter(rxnDIR == 'reversible') %>% select(-rxnDIR)
    ) %>% mutate(relationship='produces') %>% select(ko, cpd, rxnID, relationship) %>%
    write.table(sprintf("%s/%s_ko2cpd.rels",root, pathway.info$name),
        quote = F, row.names = F,sep = "\t",
        col.names = c("ko:ID","cpd:ID","rxnID","relationship"))
}

#' writeNodes
#' @param sub2ko in the reaction of substrate to ko
#' @param ko2pdt opposite direction
#' @param root the root directory
#' @param pathway.info dataframe containing the neccessary information
#' output
writeNodes <- function(sub2ko, ko2pdt, root, pathway.info){
    nodesdf = sprintf("%s/ko_nodedetails",root)        %>%
        read.csv(sep="\t",h=F,quote="")              %>%
        setNames(c("ko","name","definition"))          %>%
        filter(ko %in% unique(c(sub2ko$ko,ko2pdt$ko))) %>%
        mutate(label='ko')                             %>%
        cbind(select(pathway.info, name,title))
    sprintf("%s/%s_konodes",root,pathway.info$name) %>%
    write.table(nodesdf, ., quote=F, row.names=F, sep="\t",
        col.names = c("ko:ID", "name","definition","l:label","pathway","pathway.name")
    )

    sprintf("%s/cpd_nodedetails",root)                                %>%
    read.csv(sep="\t",h=F,quote="")                         %>%
    filter(V1 %in% unique(c(sub2ko$cpd,ko2pdt$cpd)))                 %>%
    mutate(label='cpd')                                               %>%
    setNames(c("cpd:ID","name", "exactMass", "molWeight", "l:label")) %>%
    write.table(file=sprintf("%s/%s_cpdnodes",root,pathway.info$name), sep="\t", quote=F, row.names=F)
}


#' writeNodes
#' @param sub2ko in the reaction of substrate to ko
#' @param ko2pdt opposite direction
#' @param root the root directory
#' @param pathway.info dataframe containing the neccessary information
#' output
writeOutput = function(sub2ko, ko2pdt, root, pathway.info){
    rxnsExist = length(sub2ko)+length(ko2pdt) > 0
    if(rxnsExist){  #some rxns do not have substrates and pdts eg. ko00270 (depreciated)
        writeEdges(sub2ko, ko2pdt, root, pathway.info)
        writeNodes(sub2ko, ko2pdt, root, pathway.info)
    }else{
        warning("No reactions")
    }
}

pathwayListing %>% mclapply(function(listing){
    message(sprintf("INFO: Processing pathway XML: %s", listing))
    xml_data = xmlParse(listing) %>% xmlToList 
    pathway.info =  data.frame(t(xml_data$.attrs)) %>% setNames(names(xml_data$.attrs))
    numReactions = xml_data %>% names %>% sapply(function(name) name == 'reaction') %>% sum
    hasRxn = numReactions > 0
    if(hasRxn){
        xml_data     = xml_data[-length(xml_data)] #Removes the last row (w/c is the pathway information)
        ko2rxn = sapply(xml_data, linker_ko2rxn) %>% do.call(rbind,.) %>% .[complete.cases(.),]

        rxns =  xml_data[which(names(xml_data) %in% "reaction")]
        edges = rxns %>% lapply(makeEdges, ko2rxn = ko2rxn, listing = pathway.info$name)
        sub2ko = edges %>% lapply(function(reaction) reaction$substrates) %>% do.call(rbind,.)
        ko2pdt = edges %>% lapply(function(reaction) reaction$products) %>% do.call(rbind,.)
        writeOutput(sub2ko, ko2pdt, root, pathway.info)
    }else{
        warning(sprintf("%s does not contain reactions", pathway.info$name))
    }
}, mc.cores = mccores)
