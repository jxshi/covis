library(GenomicFeatures)
library(biomaRt)
library(AnnotationDbi)
library(dplyr)
library(readr)

meta <- readr::read_rds("../nogit/data/ref/tx_metadata_GRCh37.Ensembl75.rds")
txdb <- AnnotationDbi::loadDb("../nogit/data/ref/tx_GRCh37.Ensembl75.db")
az <- readr::read_tsv("../nogit/data/ref/az300.bed.gz",
                      col_names = c("chr", "start", "end", "gene_name"),
                      col_types = "ciic")

table(az$gene_name %in% meta$gene_name) # YES!!!

az_tx <- meta %>%
  dplyr::filter(gene_name %in% az$gene_name,
                tx_biotype == "protein_coding")
head(az_tx)

# MALAT1 is lincRNA, MIRI42 is miRNA, so all good!
az[!az$gene_name %in% az_tx$gene_name, ]
length(unique(az_tx$gene_name)) # 300 - 2 = 298
length(unique(az_tx$gene_id)) # multiple gene IDs correspond to the same gene name

# Now just pull out the az_tx tx IDs from txdb
exons_all <- GenomicFeatures::exonsBy(txdb, by = "tx", use.names = TRUE)
cds_all <- GenomicFeatures::cdsBy(txdb, by = "tx", use.names = TRUE)
table(az_tx$tx_id %in% names(exons_all)) # all included
table(az_tx$tx_id %in% names(cds_all)) # all included
exons_az <- exons_all[az_tx$tx_id]
cds_az <- cds_all[az_tx$tx_id]
readr::write_rds(exons_az, "../nogit/data/ref/az_exons.rds")
readr::write_rds(cds_az, "../nogit/data/ref/az_cds.rds")
