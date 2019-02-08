
test_rquery_fns <- function() {

   a <- data.table::data.table(x = c(1, 2) , y = c(20, 30), z = c(300, 400))
   optree <- local_td(a) %.>%
      select_columns(., c("x", "y")) %.>%
      select_rows_nse(., x<2 & y<30)
   # cat(format(optree))
   # print(ex_data_table(optree))
   RUnit::checkTrue("relop" %in% class(optree))

   invisible(NULL)
}


