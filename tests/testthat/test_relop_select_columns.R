

library("rqdatatable")
context("relop_select_columns")

test_that("relop_select_columns works as expected", {


 dL <- data.frame(x = 1, y = 2, z = 3)
 rquery_pipeline <- local_td(dL) %.>%
   select_columns(., "y")
 ex_data_table(rquery_pipeline)[]

})
