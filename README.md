Coverage Visualisation for Cancer Genes
=======================================

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
    - gropu: Genes and Gene Predictions
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

gunzip -c data/gencode_gene_v27lift37.bed.gz | wc -l
540381
gunzip -c data/gencode_gene_v27lift37.bed.gz | cut -f 5 | uniq -c
540381 0

md5sum data/gencode_gene_v27lift37.bed.gz
a115d945a3d5aac546ce70311b1438ed
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
