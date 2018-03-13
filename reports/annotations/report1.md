---
title: "Working with Bioconductor Annotation Databases"
author: "Peter Diakumis"
date: "Tue 2018-Mar-13"
output: 
  html_document: 
    keep_md: yes
---

<!-- vim-markdown-toc GFM -->

* [Introduction](#introduction)
* [GenomicFeatures](#genomicfeatures)
    * [Select](#select)
    * [Ranges](#ranges)
    * [Grouping](#grouping)
* [RSQLite](#rsqlite)
* [dbplyr](#dbplyr)

<!-- vim-markdown-toc -->

```r
library(dplyr)
library(dbplyr)
library(GenomicFeatures)
library(DBI)
library(RSQLite)
# databases
library(TxDb.Hsapiens.UCSC.hg19.knownGene)
library(org.Hs.eg.db)
library(ensembldb)
```

## Introduction
Here I'm trying out different strategies for interrogating Bioconductor
Annotation packages. THere are two main ways of doing so: 

1. Indirectly GenomicFeatures functions
2. Directly with database interrogation packages, such as:
    * RSQlite
    * dbplyr


## GenomicFeatures

### Select

```r
txdb <- TxDb.Hsapiens.UCSC.hg19.knownGene
seqlevels(txdb)[1:26]
```

```
 [1] "chr1"                 "chr2"                 "chr3"                
 [4] "chr4"                 "chr5"                 "chr6"                
 [7] "chr7"                 "chr8"                 "chr9"                
[10] "chr10"                "chr11"                "chr12"               
[13] "chr13"                "chr14"                "chr15"               
[16] "chr16"                "chr17"                "chr18"               
[19] "chr19"                "chr20"                "chr21"               
[22] "chr22"                "chrX"                 "chrY"                
[25] "chrM"                 "chr1_gl000191_random"
```

```r
seqlevels(txdb) <- "chr15"

# Find UCSC tx names that match gene IDs below
keys <- c("100033416", "100033417", "100033420")
columns(txdb)
```

```
 [1] "CDSCHROM"   "CDSEND"     "CDSID"      "CDSNAME"    "CDSSTART"  
 [6] "CDSSTRAND"  "EXONCHROM"  "EXONEND"    "EXONID"     "EXONNAME"  
[11] "EXONRANK"   "EXONSTART"  "EXONSTRAND" "GENEID"     "TXCHROM"   
[16] "TXEND"      "TXID"       "TXNAME"     "TXSTART"    "TXSTRAND"  
[21] "TXTYPE"    
```

```r
keytypes(txdb)
```

```
[1] "CDSID"    "CDSNAME"  "EXONID"   "EXONNAME" "GENEID"   "TXID"    
[7] "TXNAME"  
```

```r
select(txdb, keys = keys, columns = "TXNAME", keytype = "GENEID")
```

```
'select()' returned 1:1 mapping between keys and columns
```

```
     GENEID     TXNAME
1 100033416 uc001yxl.4
2 100033417 uc001yxo.3
3 100033420 uc001yxr.3
```

```r
select(txdb, keys = keys, columns = c("TXNAME", "TXSTRAND", "TXCHROM"), keytype = "GENEID")
```

```
'select()' returned 1:1 mapping between keys and columns
```

```
     GENEID     TXNAME TXCHROM TXSTRAND
1 100033416 uc001yxl.4   chr15        +
2 100033417 uc001yxo.3   chr15        +
3 100033420 uc001yxr.3   chr15        +
```


### Ranges

```r
gr <- transcripts(txdb)
gr
```

```
GRanges object with 3337 ranges and 2 metadata columns:
         seqnames                 ranges strand |     tx_id     tx_name
            <Rle>              <IRanges>  <Rle> | <integer> <character>
     [1]    chr15   [20362688, 20364420]      + |     53552  uc001yte.1
     [2]    chr15   [20487997, 20496811]      + |     53553  uc001ytf.1
     [3]    chr15   [20723929, 20727150]      + |     53554  uc001ytj.3
     [4]    chr15   [20739312, 20739342]      + |     53555  uc021sex.1
     [5]    chr15   [20742235, 20742263]      + |     53556  uc010tzb.1
     ...      ...                    ...    ... .       ...         ...
  [3333]    chr15 [102303024, 102303055]      - |     56884  uc021syy.1
  [3334]    chr15 [102462345, 102463262]      - |     56885  uc002cdf.1
  [3335]    chr15 [102516761, 102519296]      - |     56886  uc002cds.2
  [3336]    chr15 [102516761, 102519296]      - |     56887  uc010utv.1
  [3337]    chr15 [102516761, 102519296]      - |     56888  uc010utw.1
  -------
  seqinfo: 1 sequence from hg19 genome
```

```r
ex <- exons(txdb)
ex
```

```
GRanges object with 10771 ranges and 1 metadata column:
          seqnames                 ranges strand |   exon_id
             <Rle>              <IRanges>  <Rle> | <integer>
      [1]    chr15   [20362688, 20362858]      + |    192986
      [2]    chr15   [20362943, 20363123]      + |    192987
      [3]    chr15   [20364397, 20364420]      + |    192988
      [4]    chr15   [20487997, 20488227]      + |    192989
      [5]    chr15   [20488749, 20488912]      + |    192990
      ...      ...                    ...    ... .       ...
  [10767]    chr15 [102516761, 102517949]      - |    203752
  [10768]    chr15 [102518449, 102518557]      - |    203753
  [10769]    chr15 [102518449, 102518575]      - |    203754
  [10770]    chr15 [102518473, 102518524]      - |    203755
  [10771]    chr15 [102518943, 102519296]      - |    203756
  -------
  seqinfo: 1 sequence from hg19 genome
```

### Grouping

```r
# Not evaluating code
grl1 <- transcriptsBy(txdb, by = "gene")
grl1

grl2 <- exonsBy(txdb, by = "tx")
grl2
tx_ids <- names(grl2)
head(select(txdb, keys = tx_ids, columns = "TXNAME", keytype = "TXID"))
```


## RSQLite

```r
rm(list = ls())
con <- dbConnect(SQLite(),
                 system.file("extdata", "TxDb.Hsapiens.UCSC.hg19.knownGene.sqlite",
                             package = "TxDb.Hsapiens.UCSC.hg19.knownGene"))
dbListTables(con)
```

```
[1] "cds"        "chrominfo"  "exon"       "gene"       "metadata"  
[6] "splicing"   "transcript"
```

```r
# info
dbGetQuery(con, 'SELECT * FROM metadata')
```

```
                                       name
1                                   Db type
2                        Supporting package
3                               Data source
4                                    Genome
5                                  Organism
6                               Taxonomy ID
7                                UCSC Table
8                              Resource URL
9                           Type of Gene ID
10                             Full dataset
11                         miRBase build ID
12                          transcript_nrow
13                                exon_nrow
14                                 cds_nrow
15                            Db created by
16                            Creation time
17 GenomicFeatures version at creation time
18         RSQLite version at creation time
19                          DBSCHEMAVERSION
                                          value
1                                          TxDb
2                               GenomicFeatures
3                                          UCSC
4                                          hg19
5                                  Homo sapiens
6                                          9606
7                                     knownGene
8                       http://genome.ucsc.edu/
9                                Entrez Gene ID
10                                          yes
11                                       GRCh37
12                                        82960
13                                       289969
14                                       237533
15    GenomicFeatures package from Bioconductor
16 2015-10-07 18:11:28 +0000 (Wed, 07 Oct 2015)
17                                      1.21.30
18                                        1.0.0
19                                          1.1
```

```r
# cds chrom/start/end
dbGetQuery(con, 'SELECT * FROM cds') %>% glimpse()
```

```
Observations: 237,533
Variables: 6
$ `_cds_id`  <int> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, ...
$ cds_name   <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,...
$ cds_chrom  <chr> "chr1", "chr1", "chr1", "chr1", "chr1", "chr1", "ch...
$ cds_strand <chr> "+", "+", "+", "+", "+", "+", "+", "+", "+", "+", "...
$ cds_start  <int> 12190, 12595, 13403, 69091, 324343, 324439, 324515,...
$ cds_end    <int> 12227, 12721, 13639, 70008, 324345, 325605, 324686,...
```

```r
# chromosome name + length
dbGetQuery(con, 'SELECT * FROM chrominfo') %>% head()
```

```
  _chrom_id chrom    length is_circular
1         1  chr1 249250621          NA
2         2  chr2 243199373          NA
3         3  chr3 198022430          NA
4         4  chr4 191154276          NA
5         5  chr5 180915260          NA
6         6  chr6 171115067          NA
```

```r
# exon chrom/start/end
dbGetQuery(con, 'SELECT * FROM exon') %>% glimpse()
```

```
Observations: 289,969
Variables: 6
$ `_exon_id`  <int> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,...
$ exon_name   <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA...
$ exon_chrom  <chr> "chr1", "chr1", "chr1", "chr1", "chr1", "chr1", "c...
$ exon_strand <chr> "+", "+", "+", "+", "+", "+", "+", "+", "+", "+", ...
$ exon_start  <int> 11874, 12595, 12613, 12646, 13221, 13403, 69091, 3...
$ exon_end    <int> 12227, 12721, 12721, 12697, 14409, 14409, 70008, 3...
```

```r
# gene_id, tx_id
dbGetQuery(con, 'SELECT * FROM gene') %>% glimpse()
```

```
Observations: 73,432
Variables: 2
$ gene_id  <chr> "10772", "10772", "10772", "10772", "10772", "10772",...
$ `_tx_id` <int> 78830, 78831, 78832, 78829, 78833, 78835, 78836, 8294...
```

```r
# tx_name 'ucXXXX', chrom/start/end
dbGetQuery(con, 'SELECT * FROM transcript') %>% glimpse()
```

```
Observations: 82,960
Variables: 7
$ `_tx_id`  <int> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 1...
$ tx_name   <chr> "uc001aaa.3", "uc010nxq.1", "uc010nxr.1", "uc001aal....
$ tx_type   <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, ...
$ tx_chrom  <chr> "chr1", "chr1", "chr1", "chr1", "chr1", "chr1", "chr...
$ tx_strand <chr> "+", "+", "+", "+", "+", "+", "+", "+", "+", "+", "+...
$ tx_start  <int> 11874, 11874, 11874, 69091, 321084, 321146, 322037, ...
$ tx_end    <int> 14409, 14409, 14409, 70008, 321115, 321207, 326938, ...
```

```r
dbDisconnect(con)
```

## dbplyr

```r
rm(list = ls())
con <- dbConnect(SQLite(),
                 system.file("extdata", "TxDb.Hsapiens.UCSC.hg19.knownGene.sqlite",
                             package = "TxDb.Hsapiens.UCSC.hg19.knownGene"))
dbListTables(con)
```

```
[1] "cds"        "chrominfo"  "exon"       "gene"       "metadata"  
[6] "splicing"   "transcript"
```

```r
tx <- tbl(con, "transcript")
tx %>% 
  head()
```

```
# Source:   lazy query [?? x 7]
# Database: sqlite 3.19.3
#   [/Library/Frameworks/R.framework/Versions/3.4/Resources/library/TxDb.Hsapiens.UCSC.hg19.knownGene/extdata/TxDb.Hsapiens.UCSC.hg19.knownGene.sqlite]
  `_tx_id` tx_name    tx_type tx_chrom tx_strand tx_start tx_end
     <int> <chr>      <chr>   <chr>    <chr>        <int>  <int>
1        1 uc001aaa.3 <NA>    chr1     +            11874  14409
2        2 uc010nxq.1 <NA>    chr1     +            11874  14409
3        3 uc010nxr.1 <NA>    chr1     +            11874  14409
4        4 uc001aal.1 <NA>    chr1     +            69091  70008
5        5 uc001aaq.2 <NA>    chr1     +           321084 321115
6        6 uc001aar.2 <NA>    chr1     +           321146 321207
```

```r
dbDisconnect(con)
```
