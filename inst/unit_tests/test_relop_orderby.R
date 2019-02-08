

test_relop_orderby <- function() {

 dL <- build_frame(
     "x", "y" |
     2L , "b" |
     1L , "a" |
     3L , "c" )
 rquery_pipeline <- local_td(dL) %.>%
   orderby(., "y")
 ex_data_table(rquery_pipeline)[]

 invisible(NULL)

}
