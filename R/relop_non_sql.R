

#' Direct non-sql (function) node, not implented for \code{data.table} case.
#'
#' Passes a single table to a function that takes a single data.frame as its arguement, and returns a single data.frame.
#'
#' @inheritParams ex_data_table
#' @export
ex_data_table.relop_non_sql <- function(optree,
                                        ...,
                                        tables = list(),
                                        source_usage = NULL,
                                        source_limit = NULL,
                                        env = parent.frame()) {
  wrapr::stop_if_dot_args(substitute(list(...)), "rqdataframe::ex_data_table.relop_non_sql")
  if(is.null(source_usage)) {
    source_usage <- columns_used(optree)
  }
  x <- ex_data_table(optree$source[[1]],
                     tables = tables,
                     source_limit = source_limit,
                     source_usage = source_usage,
                     env = env)
  f_df <- optree$f_df
  if(is.null(f_df)) {
    stop("rqdataframe::ex_data_table.relop_non_sql df is NULL")
  }
  f_df(x)
}


