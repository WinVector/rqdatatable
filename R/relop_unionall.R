

#' @describeIn ex_data_table implement row binding
#' @export
ex_data_table.relop_unionall <- function(optree,
                                         ...,
                                         tables = list(),
                                         source_usage = NULL,
                                         env = parent.frame()) {
  wrapr::stop_if_dot_args(substitute(list(...)), "rquery::ex_data_table.relop_unionall") # TODO: test and release
  if(is.null(source_usage)) {
    source_usage <- columns_used(optree)
  }
  inputs <- lapply(optree$source,
                   function(si) {
                     ex_data_table(si,
                                   tables = tables,
                                   source_usage = source_usage,
                                   env = env)
                   })
  data.table::rbindlist(inputs)
}


