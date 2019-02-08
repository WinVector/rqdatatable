

test_relop_null_replace <- function() {

 dL <- build_frame(
     "x", "y" |
     2L ,  5  |
     NA ,  7  |
     NA , NA )
 rquery_pipeline <- local_td(dL) %.>%
   null_replace(., c("x", "y"), 0, note_col = "nna")
 ex_data_table(rquery_pipeline)[]

 invisible(NULL)
}
