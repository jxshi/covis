fn <- system.file("extdata", "mosdepth_s1.per-base.bed.gz", package = "covis")
gr <- GenomicRanges::GRanges(c("1:10000-12000", "1:13000-14000"))
x1 <- read_bed(fn)
x2 <- read_bed(fn, param = gr)

context("read BED")

test_that("get full BED without param", {
  expect_equal(length(x1), 1L)
  expect_equal(length(x1[[1]]), 1000L)
})

test_that("get list of BED ranges with param", {
  expect_equal(length(x2), 2L)
  expect_true(all(sapply(x2, length) == c(106L, 282L)))
})
