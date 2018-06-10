
library("rqdatatable")
context("relop_select_rows")

test_that("relop_select_rows works as expected", {


 dL <- build_frame(
     "x", "y" |
     2L , "b" |
     1L , "a" |
     3L , "c" )
 rquery_pipeline <- local_td(dL) %.>%
   select_rows_nse(., x <= 2)
 ex_data_table(rquery_pipeline)[]


})
