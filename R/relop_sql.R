
#' Direct sql node.
#'
#' Execute one step using the rquery.rquery_db_executor SQL supplier.  Note: it is not
#' a good practice to use SQL nodes in data.table intended pipelines (loss of class information and
#' cost of data transfer).  This implementation is only here for completeness.
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
#'   # example data
#'   d <- data.frame(v1 = c(1, 2, NA, 3),
#'                   v2 = c(NA, "b", NA, "c"),
#'                   v3 = c(NA, NA, 7, 8),
#'                   stringsAsFactors = FALSE)
#'
#'   # example xform
#'   vars <- column_names(d)
#'   # build a NA/NULLs per-row counting expression.
#'   # names are "quoted" by wrapping them with as.name().
#'   # constants can be quoted by an additional list wrapping.
#'   expr <- lapply(vars,
#'                  function(vi) {
#'                    list("+ (CASE WHEN (",
#'                         as.name(vi),
#'                         "IS NULL ) THEN 1.0 ELSE 0.0 END)")
#'                  })
#'   expr <- unlist(expr, recursive = FALSE)
#'   expr <- c(list(0.0), expr)
#'
#'   # instantiate the operator node
#'   op_tree <- local_td(d) %.>%
#'     sql_node(., "num_missing" %:=% list(expr))
#'   cat(format(op_tree))
#'
#'   ex_data_table(op_tree, tables = list(d = d)) %.>%
#'     print(.)
#'   # d %.>% op_tree
#'
#'   options(old_o)
#'   DBI::dbDisconnect(my_db)
#' }
#'
#' @inheritParams ex_data_table
#' @export
ex_data_table.relop_sql <- function(optree,
                                    ...,
                                    tables = list(),
                                    source_usage = NULL,
                                    source_limit = NULL,
                                    env = parent.frame()) {
  force(env)
  wrapr::stop_if_dot_args(substitute(list(...)), "rqdatatable::ex_data_table.relop_sql")
  rquery.rquery_db_executor <- getOption("rquery.rquery_db_executor", default = NULL)
  if(is.null(rquery.rquery_db_executor)) {
    stop("rqdatatable::ex_data_table.relop_sql attempting to execut SQL node with rquery.rquery_db_executor not set.")
  }
  my_db <- rquery.rquery_db_executor$db
  if(is.null(source_usage)) {
    source_usage <- columns_used(optree)
  }
  x <- ex_data_table(optree$source[[1]],
                     tables = tables,
                     source_limit = source_limit,
                     source_usage = source_usage,
                     env = env)
  shallow_copy <- optree
  ds <- local_td(x)
  shallow_copy$source <- list(ds)
  res <- rquery_apply_to_data_frame(x, optree = shallow_copy,
                                    env = env, allow_executor = FALSE)
  if(!is.data.frame(res)) {
    stop("rqdatatable::ex_data_table.relop_sql input was not a data.frame")
  }
  if(!data.table::is.data.table(res)) {
    res <- data.table::as.data.table(res)
  }
  res
}
