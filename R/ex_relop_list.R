

#' default non-impementation.
#'
#' Throw on error if this method is called, signalling that a specific \code{data.table} implemetation is needed for this method.
#'
#' @inheritParams ex_data_table
#' @export
ex_data_table.relop_list <- function(optree,
                                     ...,
                                     tables = list(),
                                     source_usage = NULL,
                                     source_limit = NULL,
                                     env = parent.frame()) {
  force(env)
  stop("ex_data_table.relop_list not implemented yet")
}
