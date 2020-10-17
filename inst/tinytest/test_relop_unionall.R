
test_relop_unionall <- function() {

 dL <- build_frame(
     "x", "y" |
     2L , "b" |
     1L , "a" |
     3L , "c" )
 rquery_pipeline <- unionall(list(local_td(dL), local_td(dL)))
 ex_data_table(rquery_pipeline)

 invisible(NULL)
}

test_relop_unionall()
