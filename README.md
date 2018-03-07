Coverage Visualisation for Cancer Genes
=======================================

** *DISCLAIMER* These notes are mostly based on
[this blog post](http://davemcg.github.io/post/let-s-plot-3-base-pair-resolution-ngs-exome-coverage-plots/)
by David McGaughey. I'm simply trying to reproduce/retrace all the steps.

Step 0: Software Installation
-----------------------------
* Create conda environment with dependencies

```
# list dependencies and channels in scripts/environment.yml

name: covis
channels:
    - bioconda
dependencies:
    - mosdepth


# create 'covis' environment based on above file:
conda env create -f scripts/environment.yml
```

Step 1: Coverage Calculation with mosdepth
------------------------------------------

* Can calculate coverage in exome targeted regions (below took 6min
  on 1 -yes 1- core, with 1Gb max mem used):

```
sample="HCC2218_tumor"
bam="../data/HCC2218/HCC2218C-sort.bam"
bed="../data/HCC2218/NexteraRapidCapture_Exome_TargetedRegions_v1.2Used.bed.gz"

mosdepth -b $bed $sample $bam
```

### Command Options

```
mosdepth 0.2.1

  Usage: mosdepth [options] <prefix> <BAM-or-CRAM>

Arguments:

  <prefix>       outputs: `{prefix}.mosdepth.dist.txt`
                          `{prefix}.per-base.bed.gz` (unless -n/--no-per-base is specified)
                          `{prefix}.regions.bed.gz` (if --by is specified)
                          `{prefix}.quantized.bed.gz` (if --quantize is specified)
                          `{prefix}.thresholds.bed.gz` (if --thresholds is specified)

  <BAM-or-CRAM>  the alignment file for which to calculate depth.

Common Options:

  -t --threads <threads>     number of BAM decompression threads [default: 0]
  -c --chrom <chrom>         chromosome to restrict depth calculation.
  -b --by <bed|window>       optional BED file or (integer) window-sizes.
  -n --no-per-base           dont output per-base depth. skipping this output will speed execution
                             substantially. prefer quantized or thresholded values if possible.
  -f --fasta <fasta>         fasta file for use with CRAM files [default: ].

Other options:

  -F --flag <FLAG>              exclude reads with any of the bits in FLAG set [default: 1796]
  -q --quantize <segments>      write quantized output see docs for description.
  -Q --mapq <mapq>              mapping quality threshold [default: 0]
  -T --thresholds <thresholds>  for each interval in --by, write number of bases covered by at
                                least threshold bases. Specify multiple integer values separated
                                by ','.
  -h --help                     show help
```

### Output

* CSI index files are for tabix queries

```
HCC2218_tumor.mosdepth.dist.txt
HCC2218_tumor.per-base.bed.gz
HCC2218_tumor.per-base.bed.gz.csi
HCC2218_tumor.regions.bed.gz
HCC2218_tumor.regions.bed.gz.csi
```

* `dist.txt`:
    - cumulative distribution indicating the proportion of bases
      (or the proportion of the --by) that were covered for at
      least a given coverage value. It does this for each chromosom, and for the whole genome.
    - each row will indicate:
          * chromosome (or 'genome')
          * coverage level
          * proportion of bases covered at that level
    - last value in each chromosome will be coverage level of 0
      aligned with 1.0 bases covered at that level.

```
1  2073 0.00
1  2072 0.00
[...]
1  3    0.99
1  2    0.99
1  1    1.00
1  0    1.00
2  849  0.00
2  848  0.00
2  847  0.00
2  846  0.00
[...]
MT  3   1.00
MT  2   1.00
MT  1   1.00
MT  0   1.00
tot 2699  0.00
tot 2698  0.00
[...]
tot 1   0.99
tot 0   1.00
```

* `per-base.bed.gz`
    - per base coverage

```
# tabix HCC2218_tumor.per-base.bed.gz 1 | wc -l
8406957
# tabix HCC2218_tumor.per-base.bed.gz 21 | wc -l
889170
# gunzip -c HCC2218_tumor.per-base.bed.gz | wc -l
79781011
```

```
1     0 10003 0
1 10003 10052 2
1 10052 10069 3
1 10069 10072 4
1 10072 10075 3
1 10075 10109 4
```

* `regions.bed.gz`
    - mean per region

```
gunzip -c HCC2218_tumor.regions.bed.gz | wc -l
214126
```

```
1 12098 12258 414.44
1 12553 12721 329.89
1 13331 13701 466.99
[...]
MT 12336 14145 579.54
MT 14148 14673 527.07
MT 14746 15887 465.02
```

Step 2: Retrieve transcript and exon number
------------------------------------------

### UCSC Exon BED file

* UCSC Tables
    - clade: Mammal
    - genome: Human
    - assembly: Feb. 2009 (GRCh37/hg19)
    - group: Genes and Gene Predictions
    - track: GENCODE Gene V27lift37
    - table: Basic (wgEncodeGencodeBasicV27lift37)
    - region: genome
    - output format: BED - browser extensible data
    - output file: `gencode_gene_v27lift37.bed`
    - file type returned: gzip compressed
    - get output: Coding Exons

* Result:

```
ls -lh data/
-rw-r--r-- 1 pdiakumis punim0010 4.9M Mar  6 15:29 gencode_gene_v27lift37.bed.gz
[...]

md5sum: a115d945a3d5aac546ce70311b1438ed

gunzip -c data/gencode_gene_v27lift37.bed.gz | wc -l
540381
gunzip -c data/gencode_gene_v27lift37.bed.gz | cut -f 5 | uniq -c
540381 0
```

* Content:

```
# contains only chr1-22,X,Y,M (i.e. standard chromosomes)

chr1	67000041	67000051	ENST00000237247.10_1_cds_1_0_chr1_67000042_f	0	+
chr1	67091529	67091593	ENST00000237247.10_1_cds_2_0_chr1_67091530_f	0	+
chr1	67098752	67098777	ENST00000237247.10_1_cds_3_0_chr1_67098753_f	0	+
chr1	67099762	67099846	ENST00000237247.10_1_cds_4_0_chr1_67099763_f	0	+
[...]

# gunzip -c gencode_gene_v27lift37.bed.gz | cut -f1 | uniq -c
# it's unsorted, and in hg19 format

  51438 chr1  23135 chr10
  42070 chr2  32178 chr11
  32116 chr3  30986 chr12
  22103 chr4   8690 chr13
  23692 chr5  17633 chr14
  26601 chr6  18953 chr15
  25398 chr7  22870 chr16
  17928 chr8  32300 chr17
  21253 chr9   9248 chr18
     13 chrM  31396 chr19
  18896 chrX  12266 chr20
   1748 chrY   5997 chr21
              11473 chr22
```

### Convert from hg19 to Ensembl b37

```
gunzip -c gencode_gene_v27lift37.bed.gz | \
  sed -e 's/^chr//' | \
  sed -e 's/^M/MT/' | \
  sort -k1,1V -k2,2n | \
  gzip > gencode_gene_v27lift37_ensembl.bed.gz
```

### Intersect Coverage BED with Exon BED

* We probably could have specified the Exon BED for mosdepth. Anyway.

```
# Fix below
bedtools intersect -wa -wb -a 41001412010527.per-base.bed.gz -b /data/mcgaugheyd/genomes/GRCh37/gencode_genes_v27lift37.codingExons.ensembl.bed.gz | bgzip  > 41001412010527.per-base.labeled.bed.gz &
```

### Prepare Metadata

#### HGNC Metadata

* We can use
  [this HGNC file](ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_27/GRCh37_mapping/gencode.v27lift37.metadata.HGNC.gz)
  to match gene names with the ensembl transcript IDs in the Exon BED file.
  Got to linked file through:
      - GENCODE ->
      - Data ->
      - Human ->
      - Current Release ->
      - Go to GRCh37 version of this release ->
      - Metadata files ->
      - Gene Symbol

* Result:

```
ls -lh data/
-rw-rw-r-- 1 pdiakumis punim0010 1.1M Mar  7 12:16 gencode.v27lift37.metadata.HGNC.gz
[...]

md5sum: d558385bf2d8a2e4204756f8acf8da07

gunzip -c data/gencode.v27lift37.metadata.HGNC.gz | wc -l
172844
```

* Content:

```
ENST00000456328.2   DDX11L1
ENST00000450305.2   DDX11L1
ENST00000488147.1   WASH7P
ENST00000473358.1   MIR1302-2HG
ENST00000469289.1   MIR1302-2HG
[...]
```

#### Basic Annotation

* We can use
  [this GTF file](ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_27/GRCh37_mapping/gencode.v27lift37.basic.annotation.gtf.gz)
  to semi-accurately pick the 'canonical' transcript for a gene
  (pick the appris transcript, then the longest).
  Got to linked file through:
      - GENCODE ->
      - Data ->
      - Human ->
      - Current Release ->
      - Go to GRCh37 version of this release ->
      - GTF/GFF3 files ->
      - Basic gene annotation ->
      - GTF

* Result:

```
ls -lh data/
-rw-rw-r-- 1 pdiakumis punim0010 33M Mar  7 12:29 data/gencode.v27lift37.basic.annotation.gtf.gz
[...]

md5sum: 8a3688ffc036d989b5f3b9bf88c96e7d

gunzip -c data/gencode.v27lift37.basic.annotation.gtf.gz | wc -l
1651708
```

* Content:

```
##description: evidence-based annotation of the human genome, version 27 (Ensembl 90), mapped to GRCh37 with gencode-backmap - basic transcripts
##provider: GENCODE
##contact: gencode-help@sanger.ac.uk
##format: gtf
##date: 2017-08-01
chr1	HAVANA	gene	11869	14409	.	+	.	gene_id "ENSG00000223972.5_2"; gene_type "transcribed_unprocessed_pseudogene"; gene_name "DDX11L1"; level 2; havana_gene "OTTHUMG00000000961.2_2"; remap_status "full_contig"; remap_num_mappings 1; remap_target_status "overlap";
chr1	HAVANA	transcript	11869	14409	.	+	.	gene_id "ENSG00000223972.5_2"; transcript_id "ENST00000456328.2_1"; gene_type "transcribed_unprocessed_pseudogene"; gene_name "DDX11L1"; transcript_type "processed_transcript"; transcript_name "DDX11L1-202"; level 2; transcript_support_level 1; tag "basic"; havana_gene "OTTHUMG00000000961.2_2"; havana_transcript "OTTHUMT00000362751.1_1"; remap_num_mappings 1; remap_status "full_contig"; remap_target_status "overlap";
chr1	HAVANA	exon	11869	12227	.	+	.	gene_id "ENSG00000223972.5_2"; transcript_id "ENST00000456328.2_1"; gene_type "transcribed_unprocessed_pseudogene"; gene_name "DDX11L1"; transcript_type "processed_transcript"; transcript_name "DDX11L1-202"; exon_number 1; exon_id "ENSE00002234944.1_1"; level 2; transcript_support_level 1; tag "basic"; havana_gene "OTTHUMG00000000961.2_2"; havana_transcript "OTTHUMT00000362751.1_1"; remap_original_location "chr1:+:11869-12227"; remap_status "full_contig";
chr1	HAVANA	exon	12613	12721	.	+	.	gene_id "ENSG00000223972.5_2"; transcript_id "ENST00000456328.2_1"; gene_type "transcribed_unprocessed_pseudogene"; gene_name "DDX11L1"; transcript_type "processed_transcript"; transcript_name "DDX11L1-202"; exon_number 2; exon_id "ENSE00003582793.1_1"; level 2; transcript_support_level 1; tag "basic"; havana_gene "OTTHUMG00000000961.2_2"; havana_transcript "OTTHUMT00000362751.1_1"; remap_original_location "chr1:+:12613-12721"; remap_status "full_contig";
chr1	HAVANA	exon	13221	14409	.	+	.	gene_id "ENSG00000223972.5_2"; transcript_id "ENST00000456328.2_1"; gene_type "transcribed_unprocessed_pseudogene"; gene_name "DDX11L1"; transcript_type "processed_transcript"; transcript_name "DDX11L1-202"; exon_number 3; exon_id "ENSE00002312635.1_1"; level 2; transcript_support_level 1; tag "basic"; havana_gene "OTTHUMG00000000961.2_2"; havana_transcript "OTTHUMT00000362751.1_1"; remap_original_location "chr1:+:13221-14409"; remap_status "full_contig";
```

```
gunzip -c gencode.v27lift37.basic.annotation.gtf.gz | cut -f1 | uniq -c
# sorted, hg19, contains non-standard chrom

 155549 chr1       11 GL000241.1
 122695 chr2        3 GL000193.1
  95897 chr3        5 GL000220.1
  68352 chr4        4 GL000237.1
  73339 chr5       10 GL000212.1
  80773 chr6       20 GL000220.1
  78337 chr7       28 GL000212.1
  57954 chr8        7 GL000220.1
  63193 chr9       19 GL000212.1
  67726 chr10       6 GL000202.1
  98859 chr11      24 GL000228.1
  92200 chr12       3 GL000199.1
  27727 chr13       4 GL000192.1
  55433 chr14      22 GL000220.1
  58323 chr15       4 GL000192.1
  70930 chr16       7 GL000195.1
  96553 chr17       6 GL000205.1
  28938 chr18     150 GL000195.1
  98065 chr19       3 GL000193.1
  38172 chr20      11 GL000205.1
  19316 chr21      22 GL000195.1
  35606 chr22       7 GL000204.1
  59733 chrX        6 GL000220.1
   7490 chrY       18 GL000193.1
    143 chrM
```
