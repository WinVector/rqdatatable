
#' Implement drop columns.
#'
#' \code{data.table} based implementation.
#'
#' @inheritParams ex_data_table_step
#'
#' @examples
#'
#' dL <- data.frame(x = 1, y = 2, z = 3)
#' rquery_pipeline <- local_td(dL) %.>%
#'   drop_columns(., "y")
#' dL %.>% rquery_pipeline
#'
#' @export
ex_data_table_step.relop_drop_columns <- function(optree,
                                             ...,
                                             tables = list(),
                                             source_limit = NULL,
                                             source_usage = NULL,
                                             env = parent.frame()) {
  force(env)
  wrapr::stop_if_dot_args(substitute(list(...)), "rqdatatable::ex_data_table_step.relop_drop_columns")
  cols <- optree$columns
  if(is.null(source_usage)) {
    source_usage <- columns_used(optree)
  }
  x <- ex_data_table_step(optree$source[[1]],
                     tables = tables,
                     source_limit = source_limit,
                     source_usage = source_usage,
                     env = env)
  x[, cols, with=FALSE]
}
