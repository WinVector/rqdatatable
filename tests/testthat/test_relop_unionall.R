
library("rqdatatable")
context("relop_union_all")

test_that("relop_union_all works as expected", {

 dL <- build_frame(
     "x", "y" |
     2L , "b" |
     1L , "a" |
     3L , "c" )
 rquery_pipeline <- unionall(list(local_td(dL), local_td(dL)))
 ex_data_table(rquery_pipeline)[]


})
