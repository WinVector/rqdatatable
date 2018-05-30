

#' Direct non-sql (function) node, not implented for \code{data.table} case.
#'
#' Placeholder to through legible "not implemented" message.
#'
#' @inheritParams ex_data_table
#' @export
ex_data_table.relop_non_sql <- function(optree,
                                        ...,
                                        tables = list(),
                                        source_usage = NULL,
                                        env = parent.frame()) {
  stop("rquery::ex_data_table.relop_non_sql direct non-sql (function) nodes can not used on data.table arguments")
}


