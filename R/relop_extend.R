

strip_up_through_first_assignment <- function(s) {
  trimws(gsub("^[^=]*=[%]?[[:space:]]*", "", s),
         which = "both")
}

#' Implement extend/assign operator.
#'
#' \code{data.table} based implementation.
#'
#' @inheritParams ex_data_table
#'
#' @examples
#'
#' scale <- 0.237
#' dL <- build_frame(
#'     "subjectID", "surveyCategory"     , "assessmentTotal", "one" |
#'     1          , "withdrawal behavior", 5                , 1     |
#'     1          , "positive re-framing", 2                , 1     |
#'     2          , "withdrawal behavior", 3                , 1     |
#'     2          , "positive re-framing", 4                , 1     )
#' rquery_pipeline <- local_td(dL) %.>%
#'   extend_nse(.,
#'              probability %:=%
#'                exp(assessmentTotal * scale)/
#'                sum(exp(assessmentTotal * scale)),
#'              count %:=% sum(one),
#'              rank %:=% rank(),
#'              orderby = c("assessmentTotal", "surveyCategory"),
#'              reverse = c("assessmentTotal"),
#'              partitionby = 'subjectID') %.>%
#'   orderby(., c("subjectID", "probability"))
#' ex_data_table(rquery_pipeline)[]
#'
#' @export
ex_data_table.relop_extend <- function(optree,
                                       ...,
                                       tables = list(),
                                       source_usage = NULL,
                                       source_limit = NULL,
                                       env = parent.frame()) {
  wrapr::stop_if_dot_args(substitute(list(...)), "rquery::ex_data_table.relop_extend")
  if(is.null(source_usage)) {
    source_usage <- columns_used(optree)
  }
  x <- ex_data_table(optree$source[[1]],
                     tables = tables,
                     source_usage = source_usage,
                     source_limit = source_limit,
                     env = env)
  # if there is an order, order now apply it
  x <- order_table(x, c(optree$partitionby, optree$orderby), optree$reverse)
  n <- length(optree$parsed)
  if(n<0) {
    return(x)
  }
  # work on partition term
  byi <- ""
  if(length(optree$partitionby)>0) {
    pterms <- paste0("\"", optree$partitionby, "\"")
    byi <- paste0(" , by = c(", paste(pterms, collapse = ", "), ")")
  }
  # work on node
  tmpnam <- ".rquery_ex_extend_tmp"
  tmpenv <- new.env(parent = env)
  assign(tmpnam, x, envir = tmpenv)
  enames_raw <-
    vapply(seq_len(n),
           function(i) {
             optree$parsed[[i]]$symbols_produced
           }, character(1))
  enames <- paste0("\"", enames_raw, "\"")
  eexprs <-
    vapply(seq_len(n),
           function(i) {
             strip_up_through_first_assignment(as.character(optree$parsed[[i]]$presentation))
           }, character(1))
  rank_exprs_indices <- sort(unique(c(
    grep("^rank[[:space:]]*\\([[:space:]]*\\)$", eexprs),
    grep("^row_number[[:space:]]*\\([[:space:]]*\\)$", eexprs)
  )))
  use_rank_col <- length(rank_exprs_indices)>0
  rank_names <- NULL
  qdatatable_temp_rank_col <- NULL # don't look like an unbound reference
  if(use_rank_col) {
    x[ , qdatatable_temp_rank_col := seq_len(nrow(x))]
    rank_names <- enames_raw[rank_exprs_indices]
    enames <- enames[-rank_exprs_indices]
    eexprs <- eexprs[-rank_exprs_indices]
  }
  if(length(enames)>0) {
    enames <- paste0("c(", paste(enames, collapse = ", "), ")")
    eexprs <- paste0("list(", paste(eexprs, collapse = ", "), ")")
    # := notation means add columns to current data.table, j notation would move to summize type calc.
    src <- paste0(tmpnam, "[ ",
                  " , ", paste(enames, ":=", eexprs),
                  byi,
                  " ]")
    expr <- parse(text = src)
    x <- eval(expr, envir = tmpenv, enclos = env)
  }
  # fast ranking (seems more compatible with this workflow than data.table::frank())
  if(use_rank_col) {
    qdatatable_temp_rank_col_g <- NULL # don't look like an unbound reference
    COL <- NULL # don't look like an unbound reference
    if(length(optree$partitionby)>0) {
      x[, qdatatable_temp_rank_col_g := 1 + qdatatable_temp_rank_col - min(qdatatable_temp_rank_col),
        by = c(optree$partitionby)]
    } else {
      x[, qdatatable_temp_rank_col_g := qdatatable_temp_rank_col]
    }
    x[ , qdatatable_temp_rank_col := NULL]
    for(ci in rank_names) {
      wrapr::let(
        c(COL = ci),
        x[ , COL := qdatatable_temp_rank_col_g]
      )
    }
    x[, qdatatable_temp_rank_col_g := NULL]
  }
  x
}

