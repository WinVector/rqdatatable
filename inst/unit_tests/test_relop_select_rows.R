

test_relop_select_rows <- function () {

 dL <- build_frame(
     "x", "y" |
     2L , "b" |
     1L , "a" |
     3L , "c" )
 rquery_pipeline <- local_td(dL) %.>%
   select_rows_nse(., x <= 2)
 ex_data_table(rquery_pipeline)[]

 invisible(NULL)
}
