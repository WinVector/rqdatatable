
#' @describeIn ex_data_table implement direct sql operator
#' @export
ex_data_table.relop_sql <- function(optree,
                                    ...,
                                    tables = list(),
                                    source_usage = NULL,
                                    env = parent.frame()) {
  stop("rquery::ex_data_table.relop_sql sql nodes can not used on data.table arguments")
}
