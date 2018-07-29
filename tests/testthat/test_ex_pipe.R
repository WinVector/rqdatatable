
library("rqdatatable")
context("ex_data_table_pipe")

test_that("test_ex_pipe.R works as expected", {

  d <- data.frame(x = 1)
  ops <- local_td(d) %.>% extend_nse(., y = x + 1)
  testthat::expect("relop" %in% class(ops))
  r <- d %.>% ops
  testthat::expect(is.data.frame(r))
})
