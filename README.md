Parser for KEGG ftp files
====

4 files scripts to parse and create a node and edge flat file for import into R/neo4j.

mkdir a output dir
`mkdir misc`

## Parsing for CPD and KO details
1. [kegg.0100.ko_nodedetails.pl](./kegg.0100.ko_nodedetails.pl)
2. [kegg.0200.cpd_nodedetails.pl](./kegg.0200.cpd_nodedetails.pl) 


```
#Parse KOs
$ kegg.0100.ko_nodedetails.pl ~/KEGG/KEGG_SEPT_2014/genes/ko/ko > misc/ko_nodedetails
#Parse CPDs
$ kegg.0200.cpd_nodedetails.pl ~/KEGG/KEGG_SEPT_2014/ligand/compound/compound ~/KEGG/KEGG_SEPT_2014/ligand/glycan/glycan > misc/cpd_nodedetails
```

## Parsing each Pathway’s reactions
3. [kegg.0300.import.r](./kegg.0300.import.r)

```
$ kegg.0300.import.r </path/to/keggFTP/root/folder> <misc> <# of threads>
# misc directory be where the ko_nodes cpd_nodes files be stored
```

## Dependencies

### R

| Package  | version  |
| ----     | ----     |
| dplyr    | 0.3.0.2  |
| magrittr | 1.5      |
| XML      | 3.98-1.1 |
| parallel |          |

### Perl

At least perl 5.10

| Package | version |
| ----    | ----    |
| autodie |         |
