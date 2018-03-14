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

<!-- vim-markdown-toc -->

Introduction
------------
Here I'll look at the raw contents of a few Bioconductor Annotation packages:

* `TxDb.Hsapiens.UCSC.hg19.knownGene`
* `org.Hs.eg.db`
* `EnsDb.Hsapiens.v86`


```r
library(dplyr)
library(dbplyr)
library(DBI)
library(RSQLite)
# databases
library(TxDb.Hsapiens.UCSC.hg19.knownGene)
library(org.Hs.eg.db)
library(EnsDb.Hsapiens.v86)
```

```
## Warning in read.dcf(con): URL 'http://bioconductor.org/BiocInstaller.dcf':
## status was 'Couldn't resolve host name'
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
tbl(db, "metadata") %>% as.data.frame()
```

```
##                                        name                                        value
## 1                                   Db type                                         TxDb
## 2                        Supporting package                              GenomicFeatures
## 3                               Data source                                         UCSC
## 4                                    Genome                                         hg19
## 5                                  Organism                                 Homo sapiens
## 6                               Taxonomy ID                                         9606
## 7                                UCSC Table                                    knownGene
## 8                              Resource URL                      http://genome.ucsc.edu/
## 9                           Type of Gene ID                               Entrez Gene ID
## 10                             Full dataset                                          yes
## 11                         miRBase build ID                                       GRCh37
## 12                          transcript_nrow                                        82960
## 13                                exon_nrow                                       289969
## 14                                 cds_nrow                                       237533
## 15                            Db created by    GenomicFeatures package from Bioconductor
## 16                            Creation time 2015-10-07 18:11:28 +0000 (Wed, 07 Oct 2015)
## 17 GenomicFeatures version at creation time                                      1.21.30
## 18         RSQLite version at creation time                                        1.0.0
## 19                          DBSCHEMAVERSION                                          1.1
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
tbl(db, "transcript") %>% dplyr::filter(`_tx_id` == 78830)
```

```
## # Source:   lazy query [?? x 7]
## # Database: sqlite 3.19.3
## #   [/Library/Frameworks/R.framework/Versions/3.4/Resources/library/TxDb.Hsapiens.UCSC.hg19.knownGene/extdata/TxDb.Hsapiens.UCSC.hg19.knownGene.sqlite]
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

tbl(db, "metadata") %>% as.data.frame()
```

```
##                  name                                                             value
## 1     DBSCHEMAVERSION                                                               2.1
## 2             Db type                                                             OrgDb
## 3  Supporting package                                                     AnnotationDbi
## 4            DBSCHEMA                                                          HUMAN_DB
## 5            ORGANISM                                                      Homo sapiens
## 6             SPECIES                                                             Human
## 7        EGSOURCEDATE                                                         2017-Nov6
## 8        EGSOURCENAME                                                       Entrez Gene
## 9         EGSOURCEURL                              ftp://ftp.ncbi.nlm.nih.gov/gene/DATA
## 10          CENTRALID                                                                EG
## 11              TAXID                                                              9606
## 12       GOSOURCENAME                                                     Gene Ontology
## 13        GOSOURCEURL ftp://ftp.geneontology.org/pub/go/godatabase/archive/latest-lite/
## 14       GOSOURCEDATE                                                        2017-Nov01
## 15     GOEGSOURCEDATE                                                         2017-Nov6
## 16     GOEGSOURCENAME                                                       Entrez Gene
## 17      GOEGSOURCEURL                              ftp://ftp.ncbi.nlm.nih.gov/gene/DATA
## 18     KEGGSOURCENAME                                                       KEGG GENOME
## 19      KEGGSOURCEURL                              ftp://ftp.genome.jp/pub/kegg/genomes
## 20     KEGGSOURCEDATE                                                        2011-Mar15
## 21       GPSOURCENAME                         UCSC Genome Bioinformatics (Homo sapiens)
## 22        GPSOURCEURL                                                                  
## 23       GPSOURCEDATE                                                         2017-Oct9
## 24       ENSOURCEDATE                                                        2017-Aug23
## 25       ENSOURCENAME                                                           Ensembl
## 26        ENSOURCEURL                           ftp://ftp.ensembl.org/pub/current_fasta
## 27       UPSOURCENAME                                                           Uniprot
## 28        UPSOURCEURL                                           http://www.UniProt.org/
## 29       UPSOURCEDATE                                          Tue Nov  7 20:57:02 2017
```

```r
tbl(db, "map_metadata") %>% as.data.frame()
```

```
##           map_name                               source_name
## 1         ENTREZID                               Entrez Gene
## 2         GENENAME                               Entrez Gene
## 3           SYMBOL                               Entrez Gene
## 4              CHR                               Entrez Gene
## 5           ACCNUM                               Entrez Gene
## 6              MAP                               Entrez Gene
## 7             OMIM                               Entrez Gene
## 8           REFSEQ                               Entrez Gene
## 9             PMID                               Entrez Gene
## 10         PMID2EG                               Entrez Gene
## 11         UNIGENE                               Entrez Gene
## 12              GO                             Gene Ontology
## 13           GO2EG                               Entrez Gene
## 14       GO2ALLEGS                             Gene Ontology
## 15       GO2ALLEGS                               Entrez Gene
## 16            PATH                               KEGG GENOME
## 17         PATH2EG                               KEGG GENOME
## 18          ENZYME                               KEGG GENOME
## 19       ENZYME2EG                               KEGG GENOME
## 20          CHRLOC UCSC Genome Bioinformatics (Homo sapiens)
## 21       CHRLOCEND UCSC Genome Bioinformatics (Homo sapiens)
## 22            PFAM                                   Uniprot
## 23         PROSITE                                   Uniprot
## 24        ALIAS2EG                               Entrez Gene
## 25         ENSEMBL                               Entrez Gene
## 26      ENSEMBL2EG                               Entrez Gene
## 27     ENSEMBLPROT                                   Ensembl
## 28  ENSEMBLPROT2EG                                   Ensembl
## 29    ENSEMBLTRANS                                   Ensembl
## 30 ENSEMBLTRANS2EG                                   Ensembl
## 31         UNIPROT                               Entrez Gene
## 32          UCSCKG UCSC Genome Bioinformatics (Homo sapiens)
##                                                           source_url              source_date
## 1                               ftp://ftp.ncbi.nlm.nih.gov/gene/DATA                2017-Nov6
## 2                               ftp://ftp.ncbi.nlm.nih.gov/gene/DATA                2017-Nov6
## 3                               ftp://ftp.ncbi.nlm.nih.gov/gene/DATA                2017-Nov6
## 4                               ftp://ftp.ncbi.nlm.nih.gov/gene/DATA                2017-Nov6
## 5                               ftp://ftp.ncbi.nlm.nih.gov/gene/DATA                2017-Nov6
## 6                               ftp://ftp.ncbi.nlm.nih.gov/gene/DATA                2017-Nov6
## 7                               ftp://ftp.ncbi.nlm.nih.gov/gene/DATA                2017-Nov6
## 8                               ftp://ftp.ncbi.nlm.nih.gov/gene/DATA                2017-Nov6
## 9                               ftp://ftp.ncbi.nlm.nih.gov/gene/DATA                2017-Nov6
## 10                              ftp://ftp.ncbi.nlm.nih.gov/gene/DATA                2017-Nov6
## 11                              ftp://ftp.ncbi.nlm.nih.gov/gene/DATA                2017-Nov6
## 12 ftp://ftp.geneontology.org/pub/go/godatabase/archive/latest-lite/               2017-Nov01
## 13                              ftp://ftp.ncbi.nlm.nih.gov/gene/DATA                2017-Nov6
## 14 ftp://ftp.geneontology.org/pub/go/godatabase/archive/latest-lite/               2017-Nov01
## 15                              ftp://ftp.ncbi.nlm.nih.gov/gene/DATA                2017-Nov6
## 16                              ftp://ftp.genome.jp/pub/kegg/genomes               2011-Mar15
## 17                              ftp://ftp.genome.jp/pub/kegg/genomes               2011-Mar15
## 18                              ftp://ftp.genome.jp/pub/kegg/genomes               2011-Mar15
## 19                              ftp://ftp.genome.jp/pub/kegg/genomes               2011-Mar15
## 20                                                                                  2017-Oct9
## 21                                                                                  2017-Oct9
## 22                                           http://www.UniProt.org/ Tue Nov  7 20:57:02 2017
## 23                                           http://www.UniProt.org/ Tue Nov  7 20:57:02 2017
## 24                              ftp://ftp.ncbi.nlm.nih.gov/gene/DATA                2017-Nov6
## 25                              ftp://ftp.ncbi.nlm.nih.gov/gene/DATA                2017-Nov6
## 26                              ftp://ftp.ncbi.nlm.nih.gov/gene/DATA                2017-Nov6
## 27                           ftp://ftp.ensembl.org/pub/current_fasta               2017-Aug23
## 28                           ftp://ftp.ensembl.org/pub/current_fasta               2017-Aug23
## 29                           ftp://ftp.ensembl.org/pub/current_fasta               2017-Aug23
## 30                           ftp://ftp.ensembl.org/pub/current_fasta               2017-Aug23
## 31                              ftp://ftp.ncbi.nlm.nih.gov/gene/DATA                2017-Nov6
## 32                                                                                  2017-Oct9
```

```r
tbl(db, "map_counts") %>% as.data.frame()
```

```
##           map_name  count
## 1        SYMBOL2EG  60048
## 2         GENENAME  60118
## 3           SYMBOL  60118
## 4              CHR  59942
## 5        ACCNUM2EG 843021
## 6           ACCNUM  40951
## 7              MAP  56744
## 8           MAP2EG   2039
## 9             OMIM  15759
## 10         OMIM2EG  20740
## 11          REFSEQ  39716
## 12       REFSEQ2EG 306516
## 13            PMID  35730
## 14         PMID2EG 565357
## 15         UNIGENE  26033
## 16      UNIGENE2EG  29142
## 17      CHRLENGTHS    455
## 18              GO  19307
## 19           GO2EG  17531
## 20       GO2ALLEGS  22302
## 21            PATH   5869
## 22         PATH2EG    229
## 23          ENZYME   2230
## 24       ENZYME2EG    975
## 25          CHRLOC  28030
## 26       CHRLOCEND  28030
## 27            PFAM  19337
## 28         PROSITE  19337
## 29        ALIAS2EG 121154
## 30         ENSEMBL  26023
## 31      ENSEMBL2EG  28653
## 32     ENSEMBLPROT   7561
## 33  ENSEMBLPROT2EG  24071
## 34    ENSEMBLTRANS   8005
## 35 ENSEMBLTRANS2EG  36947
## 36         UNIPROT  19339
## 37          UCSCKG  25193
## 38           TOTAL  60118
```

```r
tbl(db, "sqlite_stat1") %>% as.data.frame()
```

```
##                      tbl                           idx        stat
## 1                ensembl                      Fensembl     29140 2
## 2           ncbi2ensembl                 Fncbi2ensembl     25504 2
## 3           ensembl2ncbi                 Fensembl2ncbi     28444 2
## 4                     ec                           Fec      2444 2
## 5              go_mf_all              Fgo_mf_all_go_id   360895 79
## 6              go_mf_all                    Fgo_mf_all   360895 21
## 7              go_bp_all              Fgo_bp_all_go_id 2114456 134
## 8              go_bp_all                    Fgo_bp_all 2114456 122
## 9                   pfam                         Fpfam     64323 4
## 10                 go_mf                  Fgo_mf_go_id    65467 16
## 11                 go_mf                        Fgo_mf     65467 4
## 12  chromosome_locations         Fchromosome_locations     45093 2
## 13               unigene                      Funigene     30632 2
## 14                  ucsc                         Fucsc    164134 7
## 15                refseq                       Frefseq    306516 8
## 16                 alias                        Falias    126486 3
## 17                  omim                         Fomim     21685 2
## 18                pubmed                       Fpubmed  1235510 35
## 19              metadata   sqlite_autoindex_metadata_1        29 1
## 20          map_metadata                          <NA>          32
## 21            map_counts sqlite_autoindex_map_counts_1        38 1
## 22          ensembl_prot                     Fensemblp     24792 4
## 23               prosite                      Fprosite     69981 4
## 24                  kegg                         Fkegg     16313 3
## 25            chrlengths sqlite_autoindex_chrlengths_1       455 1
## 26                 genes      sqlite_autoindex_genes_1     60118 1
## 27             gene_info  sqlite_autoindex_gene_info_1     60118 1
## 28             go_cc_all              Fgo_cc_all_go_id  644719 339
## 29             go_cc_all                    Fgo_cc_all   644719 35
## 30                 go_cc                  Fgo_cc_go_id    79378 50
## 31                 go_cc                        Fgo_cc     79378 5
## 32                 go_bp                  Fgo_bp_go_id   138423 12
## 33                 go_bp                        Fgo_bp    138423 8
## 34           chromosomes                  Fchromosomes     60013 2
## 35            accessions                   Faccessions   843841 21
## 36               uniprot                      Funiprot     33489 2
## 37         ensembl_trans                     Fensemblt     38035 5
## 38 cytogenetic_locations        Fcytogenetic_locations     56873 2
```

```r
# EGID + genbank accession numbers
tbl(db, "accessions") %>% head() %>% as.data.frame()
```

```
##   _id accession
## 1   1  AA484435
## 2   1  AAH35719
## 3   1  AAL07469
## 4   1  AB073611
## 5   1  ACJ13639
## 6   1  AF414429
```

```r
# EGID + gene alias
tbl(db, "alias") %>% head() %>% as.data.frame()
```

```
##   _id alias_symbol
## 1   1          A1B
## 2   1          ABG
## 3   1          GAB
## 4   1     HYST2477
## 5   1         A1BG
## 6   2         A2MD
```

```r
# b37 chr lengths
tbl(db, "chrlengths") %>% head() %>% as.data.frame()
```

```
##   chromosome    length
## 1          1 248956422
## 2          2 242193529
## 3          3 198295559
## 4          4 190214555
## 5          5 181538259
## 6          6 170805979
```

```r
# EGID 1 is on chr 19, with location foo
tbl(db, "chromosome_locations") %>% head() %>% as.data.frame()
```

```
##   _id seqname start_location end_location
## 1   1      19      -58346805    -58353499
## 2   2      12       -9067707     -9116229
## 3   3      12       -9228532     -9234207
## 4   4       8       18210102     18223689
## 5   4       8       18221667     18223689
## 6   4       8       18170461     18223689
```

```r
# EGID 1 is on chr 19
tbl(db, "chromosomes") %>% head() %>% as.data.frame()
```

```
##   _id chromosome
## 1   1         19
## 2   2         12
## 3   3         12
## 4   4          8
## 5   5          8
## 6   6          8
```

```r
# EGID cytogenetic location 
tbl(db, "cytogenetic_locations") %>% head() %>% as.data.frame()
```

```
##   _id cytogenetic_location
## 1   1             19q13.43
## 2   2             12p13.31
## 3   3             12p13.31
## 4   4                 8p22
## 5   5                 8p22
## 6   6                 8p22
```

```r
# Enzyme commission numbers
tbl(db, "ec") %>% head() %>% as.data.frame()
```

```
##   _id ec_number
## 1   4   2.3.1.5
## 2   5   2.3.1.5
## 3  10  2.3.1.87
## 4  11   6.1.1.7
## 5  13  2.6.1.22
## 6  13  2.6.1.19
```

```r
# Ensembl/NCBI Gene ID
tbl(db, "ensembl") %>% head() %>% as.data.frame()
```

```
##   _id      ensembl_id
## 1   1 ENSG00000121410
## 2   2 ENSG00000175899
## 3   3 ENSG00000256069
## 4   4 ENSG00000171428
## 5   5 ENSG00000156006
## 6   7 ENSG00000196136
```

```r
tbl(db, "ensembl2ncbi") %>% head() %>% as.data.frame()
```

```
##   _id      ensembl_id
## 1   1 ENSG00000121410
## 2   2 ENSG00000175899
## 3   3 ENSG00000256069
## 4   4 ENSG00000171428
## 5   5 ENSG00000156006
## 6   7 ENSG00000196136
```

```r
tbl(db, "ncbi2ensembl") %>% head() %>% as.data.frame()
```

```
##   _id      ensembl_id
## 1   1 ENSG00000121410
## 2   2 ENSG00000175899
## 3   3 ENSG00000256069
## 4   4 ENSG00000171428
## 5   5 ENSG00000156006
## 6   7 ENSG00000196136
```

```r
# Ensembl Protein ID
tbl(db, "ensembl_prot") %>% head() %>% as.data.frame()
```

```
##   _id         prot_id
## 1   5 ENSP00000286479
## 2   5 ENSP00000428416
## 3   9 ENSP00000248450
## 4   9 ENSP00000403343
## 5   9 ENSP00000416394
## 6   9 ENSP00000396295
```

```r
# Ensembl Transcript ID
tbl(db, "ensembl_trans") %>% head() %>% as.data.frame()
```

```
##   _id        trans_id
## 1   3 ENST00000543404
## 2   3 ENST00000566278
## 3   3 ENST00000545343
## 4   3 ENST00000544183
## 5   5 ENST00000286479
## 6   5 ENST00000520116
```

```r
# Full gene name + symbol (60118)
tbl(db, "gene_info") %>% head() %>% as.data.frame()
```

```
##   _id                          gene_name symbol
## 1   1             alpha-1-B glycoprotein   A1BG
## 2   2              alpha-2-macroglobulin    A2M
## 3   3 alpha-2-macroglobulin pseudogene 1  A2MP1
## 4   4              N-acetyltransferase 1   NAT1
## 5   5              N-acetyltransferase 2   NAT2
## 6   6     N-acetyltransferase pseudogene   NATP
```

```r
# Gene ID connecting to above (60118)
tbl(db, "genes") %>% head() %>% as.data.frame()
```

```
##   _id gene_id
## 1   1       1
## 2   2       2
## 3   3       3
## 4   4       9
## 5   5      10
## 6   6      11
```

```r
# UCSC transcript IDs
tbl(db, "ucsc") %>% head() %>% as.data.frame()
```

```
##   _id    ucsc_id
## 1   1 uc061drj.1
## 2   1 uc002qsd.5
## 3   1 uc061drk.1
## 4   1 uc061drl.1
## 5   1 uc061drm.1
## 6   1 uc061drs.1
```

```r
dbDisconnect(db)
```

EnsDb
-----

```r
# This is for GRCh38
db <- dbConnect(SQLite(), ensdb_fname)
dbListTables(db) %>% dput()
```

```
## c("chromosome", "entrezgene", "exon", "gene", "metadata", "protein", 
## "protein_domain", "tx", "tx2exon", "uniprot")
```

```r
foo <- c("chromosome", "entrezgene", "exon", "gene", "metadata", "protein",
         "protein_domain", "tx", "tx2exon", "uniprot")
tbl(db, "metadata") %>% as.data.frame()
```

```
##                  name                               value
## 1             Db type                               EnsDb
## 2     Type of Gene ID                     Ensembl Gene ID
## 3  Supporting package                           ensembldb
## 4       Db created by ensembldb package from Bioconductor
## 5      script_version                               0.3.0
## 6       Creation time            Thu May 18 16:32:27 2017
## 7     ensembl_version                                  86
## 8        ensembl_host                           localhost
## 9            Organism                        homo_sapiens
## 10        taxonomy_id                                9606
## 11       genome_build                              GRCh38
## 12    DBSCHEMAVERSION                                 2.0
```

```r
# b38 chromosome lengths
tbl(db, "chromosome") %>% head() %>% as.data.frame()
```

```
##   seq_name seq_length is_circular
## 1        X  156040895           0
## 2       20   64444167           0
## 3        1  248956422           0
## 4        6  170805979           0
## 5        3  198295559           0
## 6        7  159345973           0
```

```r
# Ensembl 'ENSG000' + Entrez '123' Gene ID
tbl(db, "entrezgene") %>% head() %>% as.data.frame()
```

```
##           gene_id entrezid
## 1 ENSG00000000003     7105
## 2 ENSG00000000005    64102
## 3 ENSG00000000419     8813
## 4 ENSG00000000457    57147
## 5 ENSG00000000460    55732
## 6 ENSG00000000938     2268
```

```r
# Ensembl exon ID 'ENSE000', start, end
tbl(db, "exon") %>% head() %>% as.data.frame()
```

```
##           exon_id exon_seq_start exon_seq_end
## 1 ENSE00001855382      100636608    100636806
## 2 ENSE00003662440      100635558    100635746
## 3 ENSE00003654571      100635178    100635252
## 4 ENSE00003658810      100633931    100634029
## 5 ENSE00003554016      100633405    100633539
## 6 ENSE00000401072      100632485    100632568
```

```r
# Ensembl gene ID 'ENSG000', gene name/start/end, chromosome
#-------- Important --------#
# 63,970 rows
tbl(db, "gene") %>% head() %>% as.data.frame()
```

```
##           gene_id gene_name   gene_biotype gene_seq_start gene_seq_end seq_name seq_strand
## 1 ENSG00000000003    TSPAN6 protein_coding      100627109    100639991        X         -1
## 2 ENSG00000000005      TNMD protein_coding      100584802    100599885        X          1
## 3 ENSG00000000419      DPM1 protein_coding       50934867     50958555       20         -1
## 4 ENSG00000000457     SCYL3 protein_coding      169849631    169894267        1         -1
## 5 ENSG00000000460  C1orf112 protein_coding      169662007    169854080        1          1
## 6 ENSG00000000938       FGR protein_coding       27612064     27635277        1         -1
##   seq_coord_system
## 1       chromosome
## 2       chromosome
## 3       chromosome
## 4       chromosome
## 5       chromosome
## 6       chromosome
```

```r
# Ensembl Tx/Gene IDs 'ENST000/ENSG000', start, end
tbl(db, "tx") %>% head() %>% as.data.frame()
```

```
##             tx_id           tx_biotype tx_seq_start tx_seq_end tx_cds_seq_start tx_cds_seq_end
## 1 ENST00000373020       protein_coding    100628670  100636806        100630798      100636694
## 2 ENST00000496771 processed_transcript    100632541  100636689               NA             NA
## 3 ENST00000494424 processed_transcript    100633442  100639991               NA             NA
## 4 ENST00000612152       protein_coding    100627109  100637104        100630798      100635569
## 5 ENST00000614008       protein_coding    100632063  100637104        100632063      100635569
## 6 ENST00000373031       protein_coding    100584802  100599885        100585019      100599717
##           gene_id
## 1 ENSG00000000003
## 2 ENSG00000000003
## 3 ENSG00000000003
## 4 ENSG00000000003
## 5 ENSG00000000003
## 6 ENSG00000000005
```

```r
# Ensembl tx/exon IDs
tbl(db, "tx2exon") %>% head() %>% as.data.frame()
```

```
##             tx_id         exon_id exon_idx
## 1 ENST00000373020 ENSE00001855382        1
## 2 ENST00000373020 ENSE00003662440        2
## 3 ENST00000373020 ENSE00003654571        3
## 4 ENST00000373020 ENSE00003658810        4
## 5 ENST00000373020 ENSE00003554016        5
## 6 ENST00000373020 ENSE00000401072        6
```

```r
dbDisconnect(db)
```

