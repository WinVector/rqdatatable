


#' Theta join (database impelementation).
#'
#' Execute one step using the rquery.rquery_db_executor SQL supplier.  Note: it is not
#' a good practice to use database nodes in data.table intended pipelines (loss of class information and
#' cost of data transfer).  This node impelemtation is only here for completeness.
#'
#' @examples
#'
#' # WARNING: example tries to change rquery.rquery_db_executor option to RSQLite and back.
#' if (requireNamespace("DBI", quietly = TRUE) &&
#'     requireNamespace("RSQLite", quietly = TRUE)) {
#'   # example database connection
#'   my_db <- DBI::dbConnect(RSQLite::SQLite(),
#'                           ":memory:")
#'   old_o <- options(list("rquery.rquery_db_executor" = list(db = my_db)))
#'
#'   d1 <- data.frame(AUC = 0.6, R2 = 0.2)
#'   d2 <- data.frame(AUC2 = 0.4, R2 = 0.3)
#'
#'   optree <- theta_join_se(local_td(d1), local_td(d2), "AUC >= AUC2")
#'
#'   ex_data_table(optree, tables = list(d1 = d1, d2 = d2)) %.>%
#'     print(.)
#'   # d %.>% optree
#'
#'   options(old_o)
#'   DBI::dbDisconnect(my_db)
#' }
#'
#' @inheritParams ex_data_table
#' @export
ex_data_table.relop_theta_join <- function(optree,
                                           ...,
                                           tables = list(),
                                           source_usage = NULL,
                                           source_limit = NULL,
                                           env = parent.frame()) {
  wrapr::stop_if_dot_args(substitute(list(...)), "rqdatatable::ex_data_table.relop_theta_join")
  rquery.rquery_db_executor <- getOption("rquery.rquery_db_executor", default = NULL)
  if(is.null(rquery.rquery_db_executor)) {
    stop("rqdatatable::ex_data_table.relop_theta_join attempting to execut SQL node with rquery.rquery_db_executor not set.")
  }
  my_db <- rquery.rquery_db_executor$db
  if(is.null(source_usage)) {
    source_usage <- columns_used(optree)
  }
  A <- ex_data_table(optree$source[[1]],
                     tables = tables,
                     source_limit = source_limit,
                     source_usage = source_usage,
                     env = env)
  B <- ex_data_table(optree$source[[2]],
                     tables = tables,
                     source_limit = source_limit,
                     source_usage = source_usage,
                     env = env)
  shallow_copy <- optree
  nmgen <- wrapr::mk_tmp_name_source("rdtdtj")
  dA <- rquery::rq_copy_to(my_db, table_name = nmgen(), A,
                           overwrite = FALSE, temporary = TRUE)
  dB <- rquery::rq_copy_to(my_db, table_name = nmgen(), B,
                           overwrite = FALSE, temporary = TRUE)
  shallow_copy$source <- list(dA, dB)
  res <- rquery::execute(my_db, shallow_copy,
                         allow_executor = FALSE,
                         overwrite = FALSE, temporary = TRUE,
                         env = env)
  rquery::rq_remove_table(my_db, dA$table_name)
  rquery::rq_remove_table(my_db, dB$table_name)
  if(!is.data.frame(res)) {
    stop("rqdatatable::ex_data_table.relop_theta_join input was not a data.frame")
  }
  if(!data.table::is.data.table(res)) {
    res <- data.table::as.data.table(res)
  }
  res
}



