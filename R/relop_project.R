

is_keyed_by_columns <- function(d, keys) {
  if(length(keys)<1) {
    return(nrow(d)<=1)
  }
  dt <- as.data.table(d)
  dt <- dt[ , j = list(RQDATATABLE_TMP = 1), by = keys ]
  return(nrow(dt)==nrow(d))
}


#' Implement projection operator.
#'
#' \code{data.table} based implementation.
#'
#' @inheritParams ex_data_table_step
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
#'   project(.,
#'           maxscore := max(assessmentTotal),
#'           count := n(),
#'           groupby = 'subjectID')
#' cat(format(test_p))
#' dL %.>% test_p
#'
#' @export
ex_data_table_step.relop_project <- function(optree,
                                        ...,
                                        tables = list(),
                                        source_usage = NULL,
                                        source_limit = NULL,
                                        env = parent.frame()) {
  force(env)
  wrapr::stop_if_dot_args(substitute(list(...)), "rqdatatable::ex_data_table_step.relop_project")
  n <- length(optree$parsed)
  if(is.null(source_usage)) {
    source_usage <- columns_used(optree)
  }
  x <- ex_data_table_step(optree$source[[1]],
                     tables = tables,
                     source_usage = source_usage,
                     source_limit = source_limit,
                     env = env)
  byi <- ""
  if(length(optree$groupby)>0) {
    pterms <- paste0("\"", optree$groupby, "\"")
    byi <- paste0(" , by = c(", paste(pterms, collapse = ", "), ")")
  }
  tmpnam <- ".rquery_ex_project_tmp"
  tmpenv <- patch_global_child_env(env)
  assign(tmpnam, x, envir = tmpenv)
  cols_to_remove <- character(0)
  rqdatatable_temp_one_col <- NULL # don't look like an unbound reference
  if(n>0) {
    prepped <- prepare_prased_assignments_for_data_table(optree$parsed)
    enames <- prepped$enames
    eexprs <- prepped$eexprs
    if(prepped$need_one_col) {
      x[ , rqdatatable_temp_one_col := 1.0]
    }
    cols_to_remove <- "rqdatatable_temp_one_col"
  } else {
    enames <- "RQDATATABLE_FAKE_COL"
    eexprs <- "1"
    cols_to_remove <- enames
    need_one_col <- FALSE
  }
  # := notation means add columns to current data.table, j notation would move to summize type calc.
  src <- paste0(tmpnam, "[ ",
                " , j = list(", paste(paste(enames, "=", eexprs), collapse = ", "), ") ",
                byi,
                " ]")
  expr <- parse(text = src)
  res <- eval(expr, envir = tmpenv, enclos = tmpenv)
  cols_to_remove <- intersect(cols_to_remove, colnames(res))
  if(length(cols_to_remove)>0) {
    # https://stackoverflow.com/a/9202485/6901725
    res[, (cols_to_remove) := NULL]
  }
  # check keying is correct, catches use of non-aggregated columns
  if(!is_keyed_by_columns(res, optree$groupby)) {
    stop("project: result was not keyed by groubpy columns, likely unaggregated columns in calculation")
  }
  res
}

