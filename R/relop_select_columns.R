
#' @describeIn ex_data_table implement select columns
#' @export
ex_data_table.relop_select_columns <- function(optree,
                                               ...,
                                               tables = list(),
                                               source_usage = NULL,
                                               env = parent.frame()) {
  wrapr::stop_if_dot_args(substitute(list(...)), "rquery::ex_data_table.relop_select_columns")
  cols <- optree$columns
  if(is.null(source_usage)) {
    source_usage <- columns_used(optree)
  }
  x <- ex_data_table(optree$source[[1]],
                     tables = tables,
                     source_usage = source_usage,
                     env = env)
  x[, cols, with=FALSE]
}

