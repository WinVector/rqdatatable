
library("rqdatatable")
context("drop_columns")

test_that("drop_columns works as expected", {

 dL <- data.frame(x = 1, y = 2, z = 3)
 rquery_pipeline <- local_td(dL) %.>%
   drop_columns(., "y")
 res <- ex_data_table(rquery_pipeline)
 expect_true(data.table::is.data.table(res))


})
