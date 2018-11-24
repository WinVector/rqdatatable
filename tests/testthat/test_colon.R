
library("rqdatatable")

context("test_colon")

test_that("test_colon.R", {

  d <- data.frame(t = 1:2)
  r <- d %.>% extend(., u = 4:5)
  testthat::expect_equal(data.table::data.table(t = 1:2, u = 4:5), r)
})
