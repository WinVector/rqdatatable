

library("rqdatatable")
context("relop_table_source")

test_that("relop_table_source works as expected", {



 dL <- build_frame(
     "x", "y" |
     2L , "b" |
     1L , "a" |
     3L , "c" )
 rquery_pipeline <- local_td(dL)
 ex_data_table(rquery_pipeline)[]


})