

library("rqdatatable")
context("relop_orderby")

test_that("relop_orderby works as expected", {


 dL <- build_frame(
     "x", "y" |
     2L , "b" |
     1L , "a" |
     3L , "c" )
 rquery_pipeline <- local_td(dL) %.>%
   orderby(., "y")
 ex_data_table(rquery_pipeline)[]

})
