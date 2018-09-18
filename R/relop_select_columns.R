

#' Implement drop columns.
#'
#' \code{data.table} based implementation.
#'
#' @inheritParams ex_data_table
#'
#' @examples
#'
#' dL <- data.frame(x = 1, y = 2, z = 3)
#' rquery_pipeline <- local_td(dL) %.>%
#'   select_columns(., "y")
#' ex_data_table(rquery_pipeline)
#'
#' @export
ex_data_table.relop_select_columns <- function(optree,
                                               ...,
                                               tables = list(),
                                               source_usage = NULL,
                                               source_limit = NULL,
                                               env = parent.frame()) {
  force(env)
  wrapr::stop_if_dot_args(substitute(list(...)), "rqdatatable::ex_data_table.relop_select_columns")
  cols <- optree$columns
  if(is.null(source_usage)) {
    source_usage <- columns_used(optree)
  }
  x <- ex_data_table(optree$source[[1]],
                     tables = tables,
                     source_usage = source_usage,
                     source_limit = source_limit,
                     env = env)
  x[, cols, with=FALSE] # data.table semantics (drop=FALSE implicit)
}

