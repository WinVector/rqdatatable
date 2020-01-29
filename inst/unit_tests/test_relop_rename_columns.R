
test_relop_rename_columns <- function() {

 dL <- build_frame(
     "x", "y" |
     2L , "b" |
     1L , "a" |
     3L , "c" )
 rquery_pipeline <- local_td(dL) %.>%
   rename_columns(., c("x" = "y", "y" = "x"))
 ex_data_table(rquery_pipeline)

 invisible(NULL)
}
