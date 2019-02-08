
test_relop_drop_columns <- function() {

 dL <- data.frame(x = 1, y = 2, z = 3)
 rquery_pipeline <- local_td(dL) %.>%
   drop_columns(., "y")
 res <- ex_data_table(rquery_pipeline)
 RUnit::checkTrue(data.table::is.data.table(res))

 invisible(NULL)
}
