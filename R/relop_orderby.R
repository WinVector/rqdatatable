

#' @describeIn ex_data_table implement row ordering
#' @export
ex_data_table.relop_orderby <- function(optree,
                                        ...,
                                        tables = list(),
                                        source_usage = NULL,
                                        env = parent.frame()) {
  wrapr::stop_if_dot_args(substitute(list(...)), "rquery::ex_data_table.relop_orderby")
  if(is.null(source_usage)) {
    source_usage <- columns_used(optree)
  }
  x <- ex_data_table(optree$source[[1]],
                     tables = tables,
                     source_usage = source_usage,
                     env = env)
  oclause <- build_order_clause(optree$orderby, optree$rev_orderby)
  if(length(oclause)<=0) {
    return(x)
  }
  tmpnam <- ".rquery_ex_orderby_tmp"
  tmpenv <- new.env(parent = env)
  assign(tmpnam, x, envir = tmpenv)
  src <- paste0(tmpnam, "[ ",
                oclause,
                " ]")
  expr <- parse(text = src)
  eval(expr, envir = tmpenv, enclos = env)
}


