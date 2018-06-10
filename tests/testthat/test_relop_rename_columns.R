

library("rqdatatable")
context("relop_rename_columns")

test_that("relop_rename_columns works as expected", {



 dL <- build_frame(
     "x", "y" |
     2L , "b" |
     1L , "a" |
     3L , "c" )
 rquery_pipeline <- local_td(dL) %.>%
   rename_columns(., c("x" = "y", "y" = "x"))
 ex_data_table(rquery_pipeline)[]



})