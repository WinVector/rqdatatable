
#' @describeIn ex_data_table implement select rows
#' @export
ex_data_table.relop_select_rows <- function(optree,
                                            ...,
                                            tables = list(),
                                            source_usage = NULL,
                                            env = parent.frame()) {
  wrapr::stop_if_dot_args(substitute(list(...)), "rquery::ex_data_table.relop_select_rows")
  if(is.null(source_usage)) {
    source_usage <- columns_used(optree)
  }
  x <- ex_data_table(optree$source[[1]],
                     tables = tables,
                     source_usage = source_usage,
                     env = env)
  tmpnam <- ".rquery_ex_select_rows_tmp"
  src <- vapply(seq_len(length(optree$parsed)),
                function(i) {
                  paste("(", optree$parsed[[i]]$presentation, ")")
                }, character(1))
  src <- paste0(tmpnam, "[ ", paste(src, collapse = " & "), " ]")
  expr <- parse(text = src)
  tmpenv <- new.env(parent = env)
  assign(tmpnam, x, envir = tmpenv)
  eval(expr, envir = tmpenv, enclos = env)
}

