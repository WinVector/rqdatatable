

test_relop_select_columns <- function() {

 dL <- data.frame(x = 1, y = 2, z = 3)
 rquery_pipeline <- local_td(dL) %.>%
   select_columns(., "y")
 ex_data_table(rquery_pipeline)[]

 invisible(NULL)
}
