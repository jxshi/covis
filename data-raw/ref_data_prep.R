library(GenomicFeatures)
library(biomaRt)
library(AnnotationDbi)
library(dplyr)

#---- Metadata ----#
ensembl <- biomaRt::useMart(biomart = "ENSEMBL_MART_ENSEMBL",
                            dataset = "hsapiens_gene_ensembl",
                            host = "feb2014.archive.ensembl.org")
attrib_all <- biomaRt::listAttributes(ensembl) # check out which columns you want

attrib <- c("ensembl_transcript_id", "ensembl_gene_id", "external_gene_id",
            "strand", "gene_biotype", "transcript_biotype")

meta <- biomaRt::getBM(attributes = attrib, mart = ensembl)
head(meta)

meta <- meta %>%
  dplyr::rename(tx_id = ensembl_transcript_id,
                tx_biotype = transcript_biotype,
                gene_id = ensembl_gene_id,
                gene_name = external_gene_id)

saveRDS(meta, "../nogit/data/ref/tx_metadata_GRCh37.Ensembl75.rds")

#---- az300.bed ----#
az <- readr::read_tsv("../nogit/data/ref/az300.bed.gz",
                      col_names = c("chr", "start", "end", "gene_name"),
                      col_types = "ciic")

table(az$gene_name %in% meta$gene_name) # YES!!!

#---- Transcripts ----#
txdb <- GenomicFeatures::makeTxDbFromBiomart(biomart = "ENSEMBL_MART_ENSEMBL",
                                             dataset = "hsapiens_gene_ensembl",
                                             host = "feb2014.archive.ensembl.org")
AnnotationDbi::saveDb(txdb, "../nogit/data/ref/tx_GRCh37.Ensembl75.db")
# txdb <- AnnotationDbi::loadDb("../nogit/data/ref/tx_GRCh37.Ensembl75.db")

exons <- exonsBy(txdb, by = "tx", use.names = TRUE)
cdss <- cdsBy(txdb, by = "tx", use.names = TRUE)
az_tx <- meta %>%
  dplyr::filter(gene_name %in% az$gene_name,
                tx_biotype == "protein_coding")

# MALAT1 is lincRNA, MIRI42 is miRNA, so all good!
az[!az$gene_name %in% az_tx$gene_name, ]
length(unique(az_tx$gene_id))
