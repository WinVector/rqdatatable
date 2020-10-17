

test_relop_table_source <- function() {

 dL <- build_frame(
     "x", "y" |
     2L , "b" |
     1L , "a" |
     3L , "c" )
 rquery_pipeline <- local_td(dL)
 ex_data_table(rquery_pipeline)

 invisible(NULL)
}

test_relop_table_source()
