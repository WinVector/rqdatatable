


#' @describeIn ex_data_table implement direct function (non-sql) operator
#' @export
ex_data_table.relop_non_sql <- function(optree,
                                        ...,
                                        tables = list(),
                                        source_usage = NULL,
                                        env = parent.frame()) {
  stop("rquery::ex_data_table.relop_non_sql direct non-sql (function) nodes can not used on data.table arguments")
}


