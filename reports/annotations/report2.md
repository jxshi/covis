---
title: "Exploring Bioconductor Annotation Databases"
author: "Peter Diakumis"
date: "Wed 2018-Mar-14"
output: 
  html_document: 
    keep_md: yes
---

<!-- vim-markdown-toc GFM -->

* [Introduction](#introduction)
* [TxDb](#txdb)
* [OrgDb](#orgdb)
* [EnsDb](#ensdb)
* [Organism.dplyr](#organismdplyr)

<!-- vim-markdown-toc -->

Introduction
------------
Here I'll look at the raw contents of a few Bioconductor Annotation packages:

* `TxDb.Hsapiens.UCSC.hg19.knownGene`
* `org.Hs.eg.db`
* `EnsDb.Hsapiens.v86`

The `Organism.dplyr` package provides a nice combination
of the `org` and `TxDb` databases.


```r
library(dplyr)
library(dbplyr)
library(DBI)
library(RSQLite)
library(Organism.dplyr)
# databases
library(TxDb.Hsapiens.UCSC.hg19.knownGene)
library(org.Hs.eg.db)
library(EnsDb.Hsapiens.v86)
```


```r
options(width = 100)
txdb_fname <- system.file("extdata", "TxDb.Hsapiens.UCSC.hg19.knownGene.sqlite",
                          package = "TxDb.Hsapiens.UCSC.hg19.knownGene")
orgdb_fname <- system.file("extdata", "org.Hs.eg.sqlite",
                           package = "org.Hs.eg.db")
ensdb_fname <- system.file("extdata", "EnsDb.Hsapiens.v86.sqlite",
                           package = "EnsDb.Hsapiens.v86")
```


TxDb
----


```r
db <- dbConnect(SQLite(), txdb_fname)
dbListTables(db)
```

```
## [1] "cds"        "chrominfo"  "exon"       "gene"       "metadata"   "splicing"   "transcript"
```

```r
tbl(db, "metadata") %>% collect()
```

```
## # A tibble: 19 x 2
##    name                                     value                                       
##    <chr>                                    <chr>                                       
##  1 Db type                                  TxDb                                        
##  2 Supporting package                       GenomicFeatures                             
##  3 Data source                              UCSC                                        
##  4 Genome                                   hg19                                        
##  5 Organism                                 Homo sapiens                                
##  6 Taxonomy ID                              9606                                        
##  7 UCSC Table                               knownGene                                   
##  8 Resource URL                             http://genome.ucsc.edu/                     
##  9 Type of Gene ID                          Entrez Gene ID                              
## 10 Full dataset                             yes                                         
## 11 miRBase build ID                         GRCh37                                      
## 12 transcript_nrow                          82960                                       
## 13 exon_nrow                                289969                                      
## 14 cds_nrow                                 237533                                      
## 15 Db created by                            GenomicFeatures package from Bioconductor   
## 16 Creation time                            2015-10-07 18:11:28 +0000 (Wed, 07 Oct 2015)
## 17 GenomicFeatures version at creation time 1.21.30                                     
## 18 RSQLite version at creation time         1.0.0                                       
## 19 DBSCHEMAVERSION                          1.1
```

```r
# tx name 'ucx.y', chrom/start/end
tbl(db, "transcript") %>% glimpse()
```

```
## Observations: ??
## Variables: 7
## $ `_tx_id`  <int> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22...
## $ tx_name   <chr> "uc001aaa.3", "uc010nxq.1", "uc010nxr.1", "uc001aal.1", "uc001aaq.2", "uc001a...
## $ tx_type   <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N...
## $ tx_chrom  <chr> "chr1", "chr1", "chr1", "chr1", "chr1", "chr1", "chr1", "chr1", "chr1", "chr1...
## $ tx_strand <chr> "+", "+", "+", "+", "+", "+", "+", "+", "+", "+", "+", "+", "+", "+", "+", "+...
## $ tx_start  <int> 11874, 11874, 11874, 69091, 321084, 321146, 322037, 323892, 324288, 327546, 3...
## $ tx_end    <int> 14409, 14409, 14409, 70008, 321115, 321207, 326938, 328581, 325896, 328439, 3...
```

```r
# exon chrom/start/end
tbl(db, "exon") %>% glimpse()
```

```
## Observations: ??
## Variables: 6
## $ `_exon_id`  <int> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, ...
## $ exon_name   <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,...
## $ exon_chrom  <chr> "chr1", "chr1", "chr1", "chr1", "chr1", "chr1", "chr1", "chr1", "chr1", "ch...
## $ exon_strand <chr> "+", "+", "+", "+", "+", "+", "+", "+", "+", "+", "+", "+", "+", "+", "+", ...
## $ exon_start  <int> 11874, 12595, 12613, 12646, 13221, 13403, 69091, 321084, 321146, 322037, 32...
## $ exon_end    <int> 12227, 12721, 12721, 12697, 14409, 14409, 70008, 321115, 321207, 322228, 32...
```

```r
# cds chrom/start/end
tbl(db, "cds") %>% glimpse()
```

```
## Observations: ??
## Variables: 6
## $ `_cds_id`  <int> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 2...
## $ cds_name   <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, ...
## $ cds_chrom  <chr> "chr1", "chr1", "chr1", "chr1", "chr1", "chr1", "chr1", "chr1", "chr1", "chr...
## $ cds_strand <chr> "+", "+", "+", "+", "+", "+", "+", "+", "+", "+", "+", "+", "+", "+", "+", "...
## $ cds_start  <int> 12190, 12595, 13403, 69091, 324343, 324439, 324515, 324719, 325383, 327746, ...
## $ cds_end    <int> 12227, 12721, 13639, 70008, 324345, 325605, 324686, 325124, 325605, 328213, ...
```

```r
# gene Entrez_ID '1234', tx_id
tbl(db, "gene") %>% glimpse()
```

```
## Observations: ??
## Variables: 2
## $ gene_id  <chr> "10772", "10772", "10772", "10772", "10772", "10772", "10772", "653545", "2294...
## $ `_tx_id` <int> 78830, 78831, 78832, 78829, 78833, 78835, 78836, 82940, 82941, 82942, 82943, 8...
```

```r
# let's check out that first transcript
tbl(db, "transcript") %>% dplyr::filter(`_tx_id` == 78830) %>% collect()
```

```
## # A tibble: 1 x 7
##   `_tx_id` tx_name    tx_type tx_chrom             tx_strand tx_start tx_end
##      <int> <chr>      <chr>   <chr>                <chr>        <int>  <int>
## 1    78830 uc021vde.1 <NA>    chr1_gl000191_random -            36273  50281
```

```r
dbDisconnect(db)
```

OrgDb
-----


```r
db <- dbConnect(SQLite(), orgdb_fname)
dbListTables(db) # 36 tables -- ouch
```

```
##  [1] "accessions"            "alias"                 "chrlengths"            "chromosome_locations" 
##  [5] "chromosomes"           "cytogenetic_locations" "ec"                    "ensembl"              
##  [9] "ensembl2ncbi"          "ensembl_prot"          "ensembl_trans"         "gene_info"            
## [13] "genes"                 "go"                    "go_all"                "go_bp"                
## [17] "go_bp_all"             "go_cc"                 "go_cc_all"             "go_mf"                
## [21] "go_mf_all"             "kegg"                  "map_counts"            "map_metadata"         
## [25] "metadata"              "ncbi2ensembl"          "omim"                  "pfam"                 
## [29] "prosite"               "pubmed"                "refseq"                "sqlite_stat1"         
## [33] "sqlite_stat4"          "ucsc"                  "unigene"               "uniprot"
```

```r
foo <- c("accessions", "alias", "chrlengths", "chromosome_locations", 
         "chromosomes", "cytogenetic_locations", "ec", "ensembl", "ensembl2ncbi", 
         "ensembl_prot", "ensembl_trans", "gene_info", "genes", "go", 
         "go_all", "go_bp", "go_bp_all", "go_cc", "go_cc_all", "go_mf", 
         "go_mf_all", "kegg", "map_counts", "map_metadata", "metadata", 
         "ncbi2ensembl", "omim", "pfam", "prosite", "pubmed", "refseq", 
         "sqlite_stat1", "sqlite_stat4", "ucsc", "unigene", "uniprot")

tbl(db, "metadata") %>% collect()
```

```
## # A tibble: 29 x 2
##    name               value                               
##    <chr>              <chr>                               
##  1 DBSCHEMAVERSION    2.1                                 
##  2 Db type            OrgDb                               
##  3 Supporting package AnnotationDbi                       
##  4 DBSCHEMA           HUMAN_DB                            
##  5 ORGANISM           Homo sapiens                        
##  6 SPECIES            Human                               
##  7 EGSOURCEDATE       2017-Nov6                           
##  8 EGSOURCENAME       Entrez Gene                         
##  9 EGSOURCEURL        ftp://ftp.ncbi.nlm.nih.gov/gene/DATA
## 10 CENTRALID          EG                                  
## # ... with 19 more rows
```

```r
tbl(db, "map_metadata") %>% collect()
```

```
## # A tibble: 32 x 4
##    map_name source_name source_url                           source_date
##    <chr>    <chr>       <chr>                                <chr>      
##  1 ENTREZID Entrez Gene ftp://ftp.ncbi.nlm.nih.gov/gene/DATA 2017-Nov6  
##  2 GENENAME Entrez Gene ftp://ftp.ncbi.nlm.nih.gov/gene/DATA 2017-Nov6  
##  3 SYMBOL   Entrez Gene ftp://ftp.ncbi.nlm.nih.gov/gene/DATA 2017-Nov6  
##  4 CHR      Entrez Gene ftp://ftp.ncbi.nlm.nih.gov/gene/DATA 2017-Nov6  
##  5 ACCNUM   Entrez Gene ftp://ftp.ncbi.nlm.nih.gov/gene/DATA 2017-Nov6  
##  6 MAP      Entrez Gene ftp://ftp.ncbi.nlm.nih.gov/gene/DATA 2017-Nov6  
##  7 OMIM     Entrez Gene ftp://ftp.ncbi.nlm.nih.gov/gene/DATA 2017-Nov6  
##  8 REFSEQ   Entrez Gene ftp://ftp.ncbi.nlm.nih.gov/gene/DATA 2017-Nov6  
##  9 PMID     Entrez Gene ftp://ftp.ncbi.nlm.nih.gov/gene/DATA 2017-Nov6  
## 10 PMID2EG  Entrez Gene ftp://ftp.ncbi.nlm.nih.gov/gene/DATA 2017-Nov6  
## # ... with 22 more rows
```

```r
tbl(db, "map_counts") %>% collect()
```

```
## # A tibble: 38 x 2
##    map_name   count
##    <chr>      <int>
##  1 SYMBOL2EG  60048
##  2 GENENAME   60118
##  3 SYMBOL     60118
##  4 CHR        59942
##  5 ACCNUM2EG 843021
##  6 ACCNUM     40951
##  7 MAP        56744
##  8 MAP2EG      2039
##  9 OMIM       15759
## 10 OMIM2EG    20740
## # ... with 28 more rows
```

```r
tbl(db, "sqlite_stat1") %>% collect()
```

```
## # A tibble: 38 x 3
##    tbl          idx              stat       
##    <chr>        <chr>            <chr>      
##  1 ensembl      Fensembl         29140 2    
##  2 ncbi2ensembl Fncbi2ensembl    25504 2    
##  3 ensembl2ncbi Fensembl2ncbi    28444 2    
##  4 ec           Fec              2444 2     
##  5 go_mf_all    Fgo_mf_all_go_id 360895 79  
##  6 go_mf_all    Fgo_mf_all       360895 21  
##  7 go_bp_all    Fgo_bp_all_go_id 2114456 134
##  8 go_bp_all    Fgo_bp_all       2114456 122
##  9 pfam         Fpfam            64323 4    
## 10 go_mf        Fgo_mf_go_id     65467 16   
## # ... with 28 more rows
```

```r
# EGID + genbank accession numbers
tbl(db, "accessions") %>% collect()
```

```
## # A tibble: 843,841 x 2
##    `_id` accession
##    <int> <chr>    
##  1     1 AA484435 
##  2     1 AAH35719 
##  3     1 AAL07469 
##  4     1 AB073611 
##  5     1 ACJ13639 
##  6     1 AF414429 
##  7     1 AI022193 
##  8     1 AK055885 
##  9     1 AK056201 
## 10     1 AK289417 
## # ... with 843,831 more rows
```

```r
# EGID + gene alias
tbl(db, "alias") %>% collect()
```

```
## # A tibble: 126,486 x 2
##    `_id` alias_symbol
##    <int> <chr>       
##  1     1 A1B         
##  2     1 ABG         
##  3     1 GAB         
##  4     1 HYST2477    
##  5     1 A1BG        
##  6     2 A2MD        
##  7     2 CPAMD5      
##  8     2 FWP007      
##  9     2 S863-7      
## 10     2 A2M         
## # ... with 126,476 more rows
```

```r
# b37 chr lengths
tbl(db, "chrlengths") %>% collect()
```

```
## # A tibble: 455 x 2
##    chromosome    length
##    <chr>          <int>
##  1 1          248956422
##  2 2          242193529
##  3 3          198295559
##  4 4          190214555
##  5 5          181538259
##  6 6          170805979
##  7 7          159345973
##  8 X          156040895
##  9 8          145138636
## 10 9          138394717
## # ... with 445 more rows
```

```r
# EGID 1 is on chr 19, with location foo
tbl(db, "chromosome_locations") %>% collect()
```

```
## # A tibble: 45,093 x 4
##    `_id` seqname start_location end_location
##    <int> <chr>            <int>        <int>
##  1     1 19           -58346805    -58353499
##  2     2 12            -9067707     -9116229
##  3     3 12            -9228532     -9234207
##  4     4 8             18210102     18223689
##  5     4 8             18221667     18223689
##  6     4 8             18170461     18223689
##  7     5 8             18391244     18401213
##  8     7 14            94612376     94624053
##  9     8 3            151814072    151828488
## 10     9 2           -218264128   -218270209
## # ... with 45,083 more rows
```

```r
# EGID 1 is on chr 19
tbl(db, "chromosomes") %>% collect()
```

```
## # A tibble: 60,013 x 2
##    `_id` chromosome
##    <int> <chr>     
##  1     1 19        
##  2     2 12        
##  3     3 12        
##  4     4 8         
##  5     5 8         
##  6     6 8         
##  7     7 14        
##  8     8 3         
##  9     9 2         
## 10    10 17        
## # ... with 60,003 more rows
```

```r
# EGID cytogenetic location 
tbl(db, "cytogenetic_locations") %>% collect()
```

```
## # A tibble: 56,873 x 2
##    `_id` cytogenetic_location
##    <int> <chr>               
##  1     1 19q13.43            
##  2     2 12p13.31            
##  3     3 12p13.31            
##  4     4 8p22                
##  5     5 8p22                
##  6     6 8p22                
##  7     7 14q32.13            
##  8     8 3q25.1              
##  9     9 2q35                
## 10    10 17q25.1             
## # ... with 56,863 more rows
```

```r
# Enzyme commission numbers
tbl(db, "ec") %>% collect()
```

```
## # A tibble: 2,444 x 2
##    `_id` ec_number
##    <int> <chr>    
##  1     4 2.3.1.5  
##  2     5 2.3.1.5  
##  3    10 2.3.1.87 
##  4    11 6.1.1.7  
##  5    13 2.6.1.22 
##  6    13 2.6.1.19 
##  7    20 2.7.10.2 
##  8    21 1.4.3.22 
##  9    22 2.7.10.2 
## 10    23 2.4.1.37 
## # ... with 2,434 more rows
```

```r
# Ensembl/NCBI Gene ID
tbl(db, "ensembl") %>% collect()
```

```
## # A tibble: 29,140 x 2
##    `_id` ensembl_id     
##    <int> <chr>          
##  1     1 ENSG00000121410
##  2     2 ENSG00000175899
##  3     3 ENSG00000256069
##  4     4 ENSG00000171428
##  5     5 ENSG00000156006
##  6     7 ENSG00000196136
##  7     8 ENSG00000114771
##  8     9 ENSG00000127837
##  9    10 ENSG00000129673
## 10    11 ENSG00000090861
## # ... with 29,130 more rows
```

```r
# Ensembl Protein ID
tbl(db, "ensembl_prot") %>% collect()
```

```
## # A tibble: 24,792 x 2
##    `_id` prot_id        
##    <int> <chr>          
##  1     5 ENSP00000286479
##  2     5 ENSP00000428416
##  3     9 ENSP00000248450
##  4     9 ENSP00000403343
##  5     9 ENSP00000416394
##  6     9 ENSP00000396295
##  7     9 ENSP00000393818
##  8    10 ENSP00000250615
##  9    10 ENSP00000376282
## 10    10 ENSP00000468239
## # ... with 24,782 more rows
```

```r
# Ensembl Transcript ID
tbl(db, "ensembl_trans") %>% collect()
```

```
## # A tibble: 38,035 x 2
##    `_id` trans_id       
##    <int> <chr>          
##  1     3 ENST00000543404
##  2     3 ENST00000566278
##  3     3 ENST00000545343
##  4     3 ENST00000544183
##  5     5 ENST00000286479
##  6     5 ENST00000520116
##  7     9 ENST00000248450
##  8     9 ENST00000444053
##  9     9 ENST00000475678
## 10     9 ENST00000420660
## # ... with 38,025 more rows
```

```r
# Full gene name + symbol (60118)
tbl(db, "gene_info") %>% collect()
```

```
## # A tibble: 60,118 x 3
##    `_id` gene_name                               symbol  
##    <int> <chr>                                   <chr>   
##  1     1 alpha-1-B glycoprotein                  A1BG    
##  2     2 alpha-2-macroglobulin                   A2M     
##  3     3 alpha-2-macroglobulin pseudogene 1      A2MP1   
##  4     4 N-acetyltransferase 1                   NAT1    
##  5     5 N-acetyltransferase 2                   NAT2    
##  6     6 N-acetyltransferase pseudogene          NATP    
##  7     7 serpin family A member 3                SERPINA3
##  8     8 arylacetamide deacetylase               AADAC   
##  9     9 angio associated migratory cell protein AAMP    
## 10    10 aralkylamine N-acetyltransferase        AANAT   
## # ... with 60,108 more rows
```

```r
# Gene ID connecting to above (60118)
tbl(db, "genes") %>% collect()
```

```
## # A tibble: 60,118 x 2
##    `_id` gene_id
##    <int> <chr>  
##  1     1 1      
##  2     2 2      
##  3     3 3      
##  4     4 9      
##  5     5 10     
##  6     6 11     
##  7     7 12     
##  8     8 13     
##  9     9 14     
## 10    10 15     
## # ... with 60,108 more rows
```

```r
# UCSC transcript IDs
tbl(db, "ucsc") %>% collect()
```

```
## # A tibble: 164,134 x 2
##    `_id` ucsc_id   
##    <int> <chr>     
##  1     1 uc061drj.1
##  2     1 uc002qsd.5
##  3     1 uc061drk.1
##  4     1 uc061drl.1
##  5     1 uc061drm.1
##  6     1 uc061drs.1
##  7     1 uc061drt.1
##  8     1 uc061drv.1
##  9     2 uc058kzm.1
## 10     2 uc058kzn.1
## # ... with 164,124 more rows
```

```r
dbDisconnect(db)
```

EnsDb
-----

```r
# This is for GRCh38
db <- dbConnect(SQLite(), ensdb_fname)
dbListTables(db)
```

```
##  [1] "chromosome"     "entrezgene"     "exon"           "gene"           "metadata"      
##  [6] "protein"        "protein_domain" "tx"             "tx2exon"        "uniprot"
```

```r
foo <- c("chromosome", "entrezgene", "exon", "gene", "metadata", "protein",
         "protein_domain", "tx", "tx2exon", "uniprot")
tbl(db, "metadata") %>% collect()
```

```
## # A tibble: 12 x 2
##    name               value                              
##    <chr>              <chr>                              
##  1 Db type            EnsDb                              
##  2 Type of Gene ID    Ensembl Gene ID                    
##  3 Supporting package ensembldb                          
##  4 Db created by      ensembldb package from Bioconductor
##  5 script_version     0.3.0                              
##  6 Creation time      Thu May 18 16:32:27 2017           
##  7 ensembl_version    86                                 
##  8 ensembl_host       localhost                          
##  9 Organism           homo_sapiens                       
## 10 taxonomy_id        9606                               
## 11 genome_build       GRCh38                             
## 12 DBSCHEMAVERSION    2.0
```

```r
# b38 chromosome lengths
tbl(db, "chromosome") %>% collect()
```

```
## # A tibble: 357 x 3
##    seq_name seq_length is_circular
##    <chr>         <int>       <int>
##  1 X         156040895           0
##  2 20         64444167           0
##  3 1         248956422           0
##  4 6         170805979           0
##  5 3         198295559           0
##  6 7         159345973           0
##  7 12        133275309           0
##  8 11        135086622           0
##  9 4         190214555           0
## 10 17         83257441           0
## # ... with 347 more rows
```

```r
# Ensembl 'ENSG000' + Entrez '123' Gene ID
tbl(db, "entrezgene") %>% collect()
```

```
## # A tibble: 29,003 x 2
##    gene_id         entrezid
##    <chr>              <int>
##  1 ENSG00000000003     7105
##  2 ENSG00000000005    64102
##  3 ENSG00000000419     8813
##  4 ENSG00000000457    57147
##  5 ENSG00000000460    55732
##  6 ENSG00000000938     2268
##  7 ENSG00000000971     3075
##  8 ENSG00000001036     2519
##  9 ENSG00000001084     2729
## 10 ENSG00000001167     4800
## # ... with 28,993 more rows
```

```r
# Ensembl exon ID 'ENSE000', start, end
tbl(db, "exon") %>% collect()
```

```
## # A tibble: 748,400 x 3
##    exon_id         exon_seq_start exon_seq_end
##    <chr>                    <int>        <int>
##  1 ENSE00001855382      100636608    100636806
##  2 ENSE00003662440      100635558    100635746
##  3 ENSE00003654571      100635178    100635252
##  4 ENSE00003658810      100633931    100634029
##  5 ENSE00003554016      100633405    100633539
##  6 ENSE00000401072      100632485    100632568
##  7 ENSE00000868868      100630759    100630866
##  8 ENSE00001459322      100628670    100629986
##  9 ENSE00001886883      100636191    100636689
## 10 ENSE00003512331      100635558    100635746
## # ... with 748,390 more rows
```

```r
# Ensembl gene ID 'ENSG000', gene name/start/end, chromosome
#-------- Important --------#
# 63,970 rows
tbl(db, "gene") %>% collect()
```

```
## # A tibble: 63,970 x 8
##    gene_id  gene_name gene_biotype gene_seq_start gene_seq_end seq_name seq_strand seq_coord_system
##    <chr>    <chr>     <chr>                 <int>        <int> <chr>         <int> <chr>           
##  1 ENSG000… TSPAN6    protein_cod…      100627109    100639991 X                -1 chromosome      
##  2 ENSG000… TNMD      protein_cod…      100584802    100599885 X                 1 chromosome      
##  3 ENSG000… DPM1      protein_cod…       50934867     50958555 20               -1 chromosome      
##  4 ENSG000… SCYL3     protein_cod…      169849631    169894267 1                -1 chromosome      
##  5 ENSG000… C1orf112  protein_cod…      169662007    169854080 1                 1 chromosome      
##  6 ENSG000… FGR       protein_cod…       27612064     27635277 1                -1 chromosome      
##  7 ENSG000… CFH       protein_cod…      196651878    196747504 1                 1 chromosome      
##  8 ENSG000… FUCA2     protein_cod…      143494811    143511690 6                -1 chromosome      
##  9 ENSG000… GCLC      protein_cod…       53497341     53616970 6                -1 chromosome      
## 10 ENSG000… NFYA      protein_cod…       41072945     41099976 6                 1 chromosome      
## # ... with 63,960 more rows
```

```r
# Ensembl Tx/Gene IDs 'ENST000/ENSG000', start, end
tbl(db, "tx") %>% collect()
```

```
## # A tibble: 216,741 x 7
##    tx_id           tx_biotype     tx_seq_start tx_seq_end tx_cds_seq_start tx_cds_seq_end gene_id  
##    <chr>           <chr>                 <int>      <int>            <int>          <int> <chr>    
##  1 ENST00000373020 protein_coding    100628670  100636806        100630798      100636694 ENSG0000…
##  2 ENST00000496771 processed_tra…    100632541  100636689               NA             NA ENSG0000…
##  3 ENST00000494424 processed_tra…    100633442  100639991               NA             NA ENSG0000…
##  4 ENST00000612152 protein_coding    100627109  100637104        100630798      100635569 ENSG0000…
##  5 ENST00000614008 protein_coding    100632063  100637104        100632063      100635569 ENSG0000…
##  6 ENST00000373031 protein_coding    100584802  100599885        100585019      100599717 ENSG0000…
##  7 ENST00000485971 processed_tra…    100593624  100597531               NA             NA ENSG0000…
##  8 ENST00000371588 protein_coding     50934867   50958550         50935132       50958523 ENSG0000…
##  9 ENST00000466152 processed_tra…     50934867   50958550               NA             NA ENSG0000…
## 10 ENST00000371582 protein_coding     50934867   50958555         50935132       50958523 ENSG0000…
## # ... with 216,731 more rows
```

```r
# Ensembl tx/exon IDs
tbl(db, "tx2exon") %>% collect()
```

```
## # A tibble: 1,297,863 x 3
##    tx_id           exon_id         exon_idx
##    <chr>           <chr>              <int>
##  1 ENST00000373020 ENSE00001855382        1
##  2 ENST00000373020 ENSE00003662440        2
##  3 ENST00000373020 ENSE00003654571        3
##  4 ENST00000373020 ENSE00003658810        4
##  5 ENST00000373020 ENSE00003554016        5
##  6 ENST00000373020 ENSE00000401072        6
##  7 ENST00000373020 ENSE00000868868        7
##  8 ENST00000373020 ENSE00001459322        8
##  9 ENST00000496771 ENSE00001886883        1
## 10 ENST00000496771 ENSE00003512331        2
## # ... with 1,297,853 more rows
```

```r
dbDisconnect(db)
```

Organism.dplyr
--------------


```r
rm(list = ls())
src <- src_organism("TxDb.Hsapiens.UCSC.hg19.knownGene")
src_tbls(src)
```

```
##  [1] "id_accession"  "id_transcript" "id"            "id_omim_pm"    "id_protein"    "id_go"        
##  [7] "id_go_all"     "ranges_gene"   "ranges_tx"     "ranges_exon"   "ranges_cds"
```

```r
foo <- c("id_accession", "id_transcript", "id", "id_omim_pm", "id_protein", 
         "id_go", "id_go_all", "ranges_gene", "ranges_tx", "ranges_exon", 
         "ranges_cds")

# entID, accNum
tbl(src, "id_accession") %>% collect()
```

```
## # A tibble: 843,841 x 3
##    entrez accnum   refseq
##    <chr>  <chr>    <chr> 
##  1 1      AA484435 <NA>  
##  2 1      AAH35719 <NA>  
##  3 1      AAL07469 <NA>  
##  4 1      AB073611 <NA>  
##  5 1      ACJ13639 <NA>  
##  6 1      AF414429 <NA>  
##  7 1      AI022193 <NA>  
##  8 1      AK055885 <NA>  
##  9 1      AK056201 <NA>  
## 10 1      AK289417 <NA>  
## # ... with 843,831 more rows
```

```r
# entID, unigene, ENST
tbl(src, "id_transcript") %>% collect()
```

```
## # A tibble: 101,436 x 3
##    entrez unigene   ensembltrans   
##    <chr>  <chr>     <chr>          
##  1 1      Hs.529161 <NA>           
##  2 1      Hs.709582 <NA>           
##  3 10     Hs.2      ENST00000286479
##  4 10     Hs.2      ENST00000520116
##  5 100    Hs.654536 <NA>           
##  6 1000   Hs.464829 ENST00000269141
##  7 1000   Hs.464829 ENST00000399380
##  8 1000   Hs.464829 ENST00000418492
##  9 1000   Hs.464829 ENST00000430882
## 10 1000   Hs.464829 ENST00000413878
## # ... with 101,426 more rows
```

```r
# entID, ENSG, symbol, genename, alias
tbl(src, "id") %>% collect()
```

```
## # A tibble: 139,958 x 6
##    entrez map      ensembl         symbol genename               alias   
##    <chr>  <chr>    <chr>           <chr>  <chr>                  <chr>   
##  1 1      19q13.43 ENSG00000121410 A1BG   alpha-1-B glycoprotein A1B     
##  2 1      19q13.43 ENSG00000121410 A1BG   alpha-1-B glycoprotein ABG     
##  3 1      19q13.43 ENSG00000121410 A1BG   alpha-1-B glycoprotein GAB     
##  4 1      19q13.43 ENSG00000121410 A1BG   alpha-1-B glycoprotein HYST2477
##  5 1      19q13.43 ENSG00000121410 A1BG   alpha-1-B glycoprotein A1BG    
##  6 10     8p22     ENSG00000156006 NAT2   N-acetyltransferase 2  AAC2    
##  7 10     8p22     ENSG00000156006 NAT2   N-acetyltransferase 2  NAT-2   
##  8 10     8p22     ENSG00000156006 NAT2   N-acetyltransferase 2  PNAT    
##  9 10     8p22     ENSG00000156006 NAT2   N-acetyltransferase 2  NAT2    
## 10 100    20q13.12 ENSG00000196839 ADA    adenosine deaminase    ADA     
## # ... with 139,948 more rows
```

```r
# entID, gene start/end/chrom
tbl(src, "ranges_gene") %>% collect()
```

```
## # A tibble: 24,826 x 5
##    gene_chrom gene_start  gene_end gene_strand entrez   
##    <chr>           <int>     <int> <chr>       <chr>    
##  1 chr19        58858172  58874214 -           1        
##  2 chr8         18248755  18258723 +           10       
##  3 chr20        43248163  43280376 -           100      
##  4 chr18        25530930  25757445 -           1000     
##  5 chr1        243651535 244006886 -           10000    
##  6 chrX         49217763  49233491 +           100008586
##  7 chr3        101395274 101398057 +           100009676
##  8 chr14        71050957  71067384 -           10001    
##  9 chr15        72102894  72110597 +           10002    
## 10 chr11        89867818  89925779 +           10003    
## # ... with 24,816 more rows
```

```r
# tx chrom, start, end, entID, UCSC name
tbl(src, "ranges_tx") %>% collect()
```

```
## # A tibble: 82,960 x 8
##    tx_chrom tx_strand tx_start tx_end entrez    tx_id tx_name    tx_type
##    <chr>    <chr>        <int>  <int> <chr>     <int> <chr>      <chr>  
##  1 chr1     +            11874  14409 100287102     1 uc001aaa.3 <NA>   
##  2 chr1     +            11874  14409 100287102     2 uc010nxq.1 <NA>   
##  3 chr1     +            11874  14409 100287102     3 uc010nxr.1 <NA>   
##  4 chr1     +            69091  70008 79501         4 uc001aal.1 <NA>   
##  5 chr1     +           321084 321115 <NA>          5 uc001aaq.2 <NA>   
##  6 chr1     +           321146 321207 <NA>          6 uc001aar.2 <NA>   
##  7 chr1     +           322037 326938 100133331     7 uc009vjk.2 <NA>   
##  8 chr1     +           323892 328581 100132062     8 uc001aau.3 <NA>   
##  9 chr1     +           324288 325896 100133331     9 uc021oeh.1 <NA>   
## 10 chr1     +           327546 328439 <NA>         10 uc021oei.1 <NA>   
## # ... with 82,950 more rows
```

```r
# exon chrom,start, end, entID, txID, exonID, exon rank
tbl(src, "ranges_exon") %>% collect()
```

```
## # A tibble: 742,493 x 9
##    exon_chrom exon_strand exon_start exon_end entrez    tx_id exon_id exon_name exon_rank
##    <chr>      <chr>            <int>    <int> <chr>     <int>   <int> <chr>         <int>
##  1 chr1       +                11874    12227 100287102     1       1 <NA>              1
##  2 chr1       +                12613    12721 100287102     1       3 <NA>              2
##  3 chr1       +                13221    14409 100287102     1       5 <NA>              3
##  4 chr1       +                11874    12227 100287102     3       1 <NA>              1
##  5 chr1       +                12646    12697 100287102     3       4 <NA>              2
##  6 chr1       +                13221    14409 100287102     3       5 <NA>              3
##  7 chr1       +                11874    12227 100287102     2       1 <NA>              1
##  8 chr1       +                12595    12721 100287102     2       2 <NA>              2
##  9 chr1       +                13403    14409 100287102     2       6 <NA>              3
## 10 chr1       -                14362    14829 653635     4074   13964 <NA>              4
## # ... with 742,483 more rows
```

```r
# Gene symbol starting with SNORD
tbl(src, "id") %>% 
  dplyr::filter(symbol %like% "SNORD%") %>% 
  dplyr::select(entrez:symbol) %>% 
  dplyr::distinct() %>% 
  dplyr::arrange(symbol) %>%
  collect()
```

```
## # A tibble: 398 x 4
##    entrez    map     ensembl         symbol   
##    <chr>     <chr>   <chr>           <chr>    
##  1 652966    17p13.1 ENSG00000238917 SNORD10  
##  2 594838    6q23.2  ENSG00000221500 SNORD100 
##  3 594837    6q23.2  ENSG00000206754 SNORD101 
##  4 26771     13q12.2 ENSG00000207500 SNORD102 
##  5 692234    1p35.2  <NA>            SNORD103A
##  6 692235    1p35.2  <NA>            SNORD103B
##  7 692200    1p35.2  <NA>            SNORD103C
##  8 692227    17q23.3 ENSG00000199753 SNORD104 
##  9 692229    19p13.2 ENSG00000209645 SNORD105 
## 10 100113382 19p13.2 ENSG00000238531 SNORD105B
## # ... with 388 more rows
```

```r
# Transcript counts per gene symbol
txcount <- inner_join(tbl(src, "id"), tbl(src, "ranges_tx")) %>%
  dplyr::select(symbol, tx_id) %>% 
  group_by(symbol) %>% 
  summarise(count = n()) %>% 
  arrange(count) %>%
  collect()
```

```
## Joining, by = "entrez"
```

```r
txcount
```

```
## # A tibble: 23,370 x 2
##    symbol       count
##    <chr>        <int>
##  1 A2M-AS1          1
##  2 AADACL4          1
##  3 AADACP1          1
##  4 ABCC5-AS1        1
##  5 ABHD14A-ACY1     1
##  6 ABHD15           1
##  7 ABHD8            1
##  8 ACBD6            1
##  9 ACSM4            1
## 10 ACTG1P17         1
## # ... with 23,360 more rows
```
