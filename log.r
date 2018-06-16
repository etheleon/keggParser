#--try and read in the entire 'module' file from KEGG into R!!!!

read.textfile.using.readLines<-function(file)
{
 #--read in a .tax file, named as 'file'
 filecon<-file(description=file,open="rt")
 taxScan<-readLines(con=filecon,n=-1)
 close(filecon)
 return(taxScan)
}

module<-read.textfile.using.readLines("module")

> str(module)
chr [1:10653158] "ENTRY       M00001            Pathway   Module" ...

> system("wc -l module")
10653158 module

#--we only need the KO related entries...
#--from inspection using grep, the last "KO" entry is at line 16571

module.kocut<-module[1:16571]

#--the ENTRY,NAME and DEFINITION rows seem to contain all the information we need!
#--note: have confirmed these are consecutive rows using grep :)
module.kocut.ENTRY<-module.kocut[grep("ENTRY",module.kocut,fixed=T)]
module.kocut.NAME<-module.kocut[grep("NAME",module.kocut,fixed=T)]
module.kocut.DEFINITION<-module.kocut[grep("DEFINITION",module.kocut,fixed=T)]

#--process each row for essential data...
library(gdata)

filter.KO.strings<-function(x)
{
 res<-strsplit(x,"")[[1]]
 res<-res[res!=","]
 res<-res[res!="("]
 res<-res[res!=")"]
 res<-res[res!=" "]
 res<-res[res!="+"]
 res<-res[res!="-"]

 res<-paste(res,collapse="")
 res<-strsplit(res,"K",fixed=T)[[1]][-1]
 res<-paste("K",res,sep="")
 
 return(res)
}

#--prep DEFINITION data
module.kocut.DEFINITION.filtered<-sapply(strsplit(module.kocut.DEFINITION,"DEFINITION"),FUN=function(x){trim(x[2])})
module.kocut.DEFINITION.clean<-sapply(module.kocut.DEFINITION.filtered,filter.KO.strings)

module.kocut.NAME.clean<-sapply(strsplit(module.kocut.NAME,"NAME"),FUN=function(x){trim(x[2])})

module.kocut.ENTRY.filtered<-strsplit(module.kocut.ENTRY," ",fixed=T)
module.kocut.ENTRY.filtered<-lapply(module.kocut.ENTRY.filtered,FUN=function(x){x[x!=""]})
module.kocut.ENTRY.tag<-sapply(module.kocut.ENTRY.filtered,FUN=function(x){x[2]})
module.kocut.ENTRY.type<-sapply(module.kocut.ENTRY.filtered,FUN=function(x){x[3]})

#--make a list containing whose elements are the KO memberships ofeach module, name the list with the tags, and make a summary table that contains metadata
module2koList<-module.kocut.DEFINITION.filtered.clean
names(module2koList)<-module.kocut.ENTRY.tag

#--make table...
module2koSummTable<-data.frame(mid=module.kocut.ENTRY.tag,type=module.kocut.ENTRY.type,numko=sapply(module2koList,length),name=module.kocut.NAME.clean,stringsAsFactors=F)

#--save module2ko related objects...
save(module2koList,module2koSummTable,file="module2koObjects.RData")


