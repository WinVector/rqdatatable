
#' Implement projection operator.
#'
#' \code{data.table} based implementation.
#'
#' @inheritParams ex_data_table
#'
#' @examples
#'
#' dL <- build_frame(
#'   "subjectID", "surveyCategory"     , "assessmentTotal" |
#'     1          , "withdrawal behavior", 5                 |
#'     1          , "positive re-framing", 2                 |
#'     2          , "withdrawal behavior", 3                 |
#'     2          , "positive re-framing", 4                 )
#' test_p <- local_td(dL) %.>%
#'   extend_nse(.,
#'              one %:=% 1) %.>%
#'   project_nse(.,
#'               maxscore = max(assessmentTotal),
#'               groupby = 'subjectID')
#' cat(format(test_p))
#' ex_data_table(test_p)
#'
#' @export
ex_data_table.relop_project <- function(optree,
                                        ...,
                                        tables = list(),
                                        source_usage = NULL,
                                        source_limit = NULL,
                                        env = parent.frame()) {
  force(env)
  wrapr::stop_if_dot_args(substitute(list(...)), "rqdatatable::ex_data_table.relop_project")
  n <- length(optree$parsed)
  if(n<0) {
    stop("rqdatatable::ex_data_table.relop_project() must have at least one assignment")
  }
  if(is.null(source_usage)) {
    source_usage <- columns_used(optree)
  }
  x <- ex_data_table(optree$source[[1]],
                     tables = tables,
                     source_usage = source_usage,
                     source_limit = source_limit,
                     env = env)
  byi <- ""
  if(length(optree$groupby)>0) {
    pterms <- paste0("\"", optree$groupby, "\"")
    byi <- paste0(" , by = c(", paste(pterms, collapse = ", "), ")")
  }
  tmpnam <- ".rquery_ex_extend_tmp"
  tmpenv <- new.env(parent = globalenv())
  assign(tmpnam, x, envir = tmpenv)
  enames <-
    vapply(seq_len(n),
           function(i) {
             paste0("\"", optree$parsed[[i]]$symbols_produced, "\"")
           }, character(1))
  eexprs <-
    vapply(seq_len(n),
           function(i) {
             strip_up_through_first_assignment(as.character(optree$parsed[[i]]$presentation))
           }, character(1))
  # := notation means add columns to current data.table, j notation would move to summize type calc.
  src <- paste0(tmpnam, "[ ",
                " , j = list(", paste(paste(enames, "=", eexprs), collapse = ", "), ") ",
                byi,
                " ]")
  expr <- parse(text = src)
  eval(expr, envir = tmpenv, enclos = tmpenv)
}

