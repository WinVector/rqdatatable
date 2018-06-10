
library("rqdatatable")
context("relop_theta_join")

test_that("relop_theta_join works as expected", {



 # WARNING: example tries to change rquery.rquery_db_executor option to RSQLite and back.
 if (requireNamespace("DBI", quietly = TRUE) &&
     requireNamespace("RSQLite", quietly = TRUE)) {
   # example database connection
   my_db <- DBI::dbConnect(RSQLite::SQLite(),
                           ":memory:")
   old_o <- options(list("rquery.rquery_db_executor" = list(db = my_db)))

   d1 <- data.frame(AUC = 0.6, R2 = 0.2)
   d2 <- data.frame(AUC2 = 0.4, R2 = 0.3)

   optree <- theta_join_se(local_td(d1), local_td(d2), "AUC >= AUC2")

   ex_data_table(optree, tables = list(d1 = d1, d2 = d2)) %.>%
     print(.)
   # d %.>% optree

   options(old_o)
   DBI::dbDisconnect(my_db)
 }

 })

