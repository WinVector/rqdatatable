


#' Theta join.
#'
#' To be implemented by \code{data.table} (not yet implemented).
#'
#' @inheritParams ex_data_table
#' @export
ex_data_table.relop_theta_join <- function(optree,
                                           ...,
                                           tables = list(),
                                           source_usage = NULL,
                                           source_limit = NULL,
                                           env = parent.frame()) {
  stop("rquery::ex_data_table.relop_theta_join not implemented yet") # TODO: implement
  wrapr::stop_if_dot_args(substitute(list(...)), "rquery::ex_data_table.relop_theta_join")
  if(is.null(source_usage)) {
    source_usage <- columns_used(optree)
  }
  inputs <- lapply(optree$source,
                   function(si) {
                     ex_data_table(si,
                                   tables = tables,
                                   source_usage = source_usage,
                                   source_limit = source_limit,
                                   env = env)
                   })
}



