#' Read a BED file
#'
#' Read a BED file output by mosdepth, containing four
#' columns: chrom, start_pos, end_pos and coverage. If a GRanges object
#' is specified for `param`, it scans only those records from the BED file.
#'
#' The BED file needs to be bgzipped and tbi-indexed for use with tabix.
#' **Note** that a csi-index (mosdepth default) is not supported
#' by Rsamtools (or maybe it just doesn't work for  me).
#'
#' For example, you can run the following on a sorted BED file:
#' `bgzip <sample>.per-base.bed; tabix -p bed <sample>.per-base.bed.gz`,
#' and then read the resulting gzipped and indexed file with this function.
#'
#' @param fn BED file name. Must be a character vector of length 1.
#' @param param A GRanges or GRangesList instance, used to select
#'   which records to scan.
#' @return A GRanges object representation of the input BED file.
#' @examples
#' fn <- system.file("extdata", "mosdepth_s1.per-base.bed.gz", package = "covis")
#' gr <- GenomicRanges::GRanges(c("1:10000-12000", "1:13000-14000"))
#' x1 <- read_bed(fn)
#' x2 <- read_bed(fn, gr)
#'
#' @export
read_bed <- function(fn, param = NULL) {
  stopifnot(file.exists(fn))
  if (!grepl("gz$", fn)) stop(glue::glue("The {fn} BED file must be bgzipped!"))
  if (!file.exists(paste0(fn, ".tbi"))) stop(glue::glue("The {fn} BED file must be tbi-indexed!"))
  tbx <- Rsamtools::TabixFile(fn)
  if (!is.null(param)) {
    # read BED chunks
    res <- Rsamtools::scanTabix(tbx, param = param)
  } else {
    # read the whole BED
    res <- Rsamtools::scanTabix(tbx)
  }
  # each element of res is a character atomic vector
  # with 'chr\tpos_start\tpos_end\tcoverage' elements.
  gr <- purrr::map(res, function(el) {
    DF <- utils::read.table(textConnection(el), header = FALSE, sep = "\t",
                            col.names = c("chr", "start", "end", "coverage"),
                            colClasses = c("character", "integer", "integer", "integer"),
                            comment.char = "", quote = "", stringsAsFactors = FALSE)
    GenomicRanges::makeGRangesFromDataFrame(DF)
  })
  return(gr)
}
