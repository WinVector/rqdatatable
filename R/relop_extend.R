
#' @describeIn ex_data_table implement extend/assign operator
#' @export
ex_data_table.relop_extend <- function(optree,
                                       ...,
                                       tables = list(),
                                       source_usage = NULL,
                                       env = parent.frame()) {
  wrapr::stop_if_dot_args(substitute(list(...)), "rquery::ex_data_table.relop_extend")
  oclause <- build_order_clause(optree$orderby, optree$rev_orderby)
  if(length(oclause)<=0) {
    oclause = ""
  }
  n <- length(optree$parsed)
  if(n<0) {
    stop("rquery::ex_data_table.relop_extend() must have at least one assignment")
  }
  if(is.null(source_usage)) {
    source_usage <- columns_used(optree)
  }
  x <- ex_data_table(optree$source[[1]],
                     tables = tables,
                     source_usage = source_usage,
                     env = env)
  byi <- ""
  if(length(optree$partitionby)>0) {
    pterms <- paste0("\"", optree$partitionby, "\"")
    byi <- paste0(" , by = c(", paste(pterms, collapse = ", "), ")")
  }
  tmpnam <- ".rquery_ex_extend_tmp"
  tmpenv <- new.env(parent = env)
  assign(tmpnam, x, envir = tmpenv)
  enames <-
    vapply(seq_len(n),
           function(i) {
             paste0("\"", optree$parsed[[i]]$symbols_produced, "\"")
           }, character(1))
  enames <- paste0("c(", paste(enames, collapse = ", "), ")")
  eexprs <-
    vapply(seq_len(n),
           function(i) {
             gsub("^[^:]*:=[[:space:]]*", "", as.character(optree$parsed[[i]]$presentation))
           }, character(1))
  eexprs <- paste0("list(", paste(eexprs, collapse = ", "), ")")
  # := notation means add columns to current data.table, j notation would move to summize type calc.
  src <- paste0(tmpnam, "[ ",
                oclause,
                " , ", paste(enames, ":=", eexprs),
                byi,
                " ]")
  expr <- parse(text = src)
  eval(expr, envir = tmpenv, enclos = env)
}

