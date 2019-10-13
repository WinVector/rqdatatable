

strip_up_through_first_assignment <- function(s) {
  trimws(gsub("^[^=]*=[%]?[[:space:]]*", "", s),
         which = "both")
}

data_table_extend_fns <- list(
  ngroup = list(data.table_version = ".GRP", need_one_col = TRUE),
  rank = list(data.table_version = "cumsum(rqdatatable_temp_one_col)", need_one_col = TRUE),
  row_number = list(data.table_version = "cumsum(rqdatatable_temp_one_col)", need_one_col = TRUE),
  n = list(data.table_version = "sum(rqdatatable_temp_one_col)", need_one_col = TRUE),
  random = list(data.table_version = "runif(.N)", need_one_col = FALSE),
  rand = list(data.table_version = "runif(.N)", need_one_col = FALSE)
)


remap_parsed_exprs_for_data_table <- function(eexprs) {
  n <- length(eexprs)
  pure_function_indices <- grep("^[[:alpha:]][[:alnum:]_.]*[[:space:]]*\\([[:space:]]*\\)$",
                                eexprs)
  need_one_col <- FALSE
  if(length(pure_function_indices)>0) {
    fn_names <- rep(NA_character_, length(eexprs))
    fn_names[pure_function_indices] <- gsub("[[:space:]]*\\(.*$", "", eexprs[pure_function_indices])
    fn_names[!(fn_names %in% names(data_table_extend_fns))] <- NA_character_
    translations <- data_table_extend_fns[fn_names]
    for(i in seq_len(length(translations))) {
      transi <- translations[[i]]
      if(!is.null(transi)) {
        eexprs[[i]] <- transi$data.table_version
        need_one_col <- need_one_col || transi$need_one_col
      }
    }
  }
  return(list(eexprs = eexprs, need_one_col = need_one_col))
}

prepare_prased_assignments_for_data_table <- function(parsed) {
  n <- length(parsed)
  enames_raw <-
    vapply(seq_len(n),
           function(i) {
             parsed[[i]]$symbols_produced
           }, character(1))
  enames <- paste0("\"", enames_raw, "\"")
  # map some functions to data.table equivs
  eexprs <-
    vapply(seq_len(n),
           function(i) {
             strip_up_through_first_assignment(as.character(parsed[[i]]$presentation))
           }, character(1))
  re_mapped <- remap_parsed_exprs_for_data_table(eexprs)
  return(list(enames = enames, eexprs = re_mapped$eexprs, need_one_col = re_mapped$need_one_col))
}

#' Implement extend/assign operator.
#'
#' \code{data.table} based implementation.
#'
#' Will re-order columns if there are ordering terms.
#'
#' @inheritParams ex_data_table
#'
#' @examples
#'
#' dL <- build_frame(
#'     "subjectID", "surveyCategory"     , "assessmentTotal", "one" |
#'     1          , "withdrawal behavior", 5                , 1     |
#'     1          , "positive re-framing", 2                , 1     |
#'     2          , "withdrawal behavior", 3                , 1     |
#'     2          , "positive re-framing", 4                , 1     )
#' rquery_pipeline <- local_td(dL) %.>%
#'   extend_nse(.,
#'              probability %:=%
#'                exp(assessmentTotal * 0.237)/
#'                sum(exp(assessmentTotal * 0.237)),
#'              count %:=% sum(one),
#'              rank %:=% rank(),
#'              orderby = c("assessmentTotal", "surveyCategory"),
#'              reverse = c("assessmentTotal"),
#'              partitionby = 'subjectID') %.>%
#'   orderby(., c("subjectID", "probability"))
#' ex_data_table(rquery_pipeline)
#'
#' @export
ex_data_table.relop_extend <- function(optree,
                                       ...,
                                       tables = list(),
                                       source_usage = NULL,
                                       source_limit = NULL,
                                       env = parent.frame()) {
  wrapr::stop_if_dot_args(substitute(list(...)), "rqdatatable::ex_data_table.relop_extend")
  force(env)
  if(is.null(source_usage)) {
    source_usage <- columns_used(optree)
  }
  x <- ex_data_table(optree$source[[1]],
                     tables = tables,
                     source_usage = source_usage,
                     source_limit = source_limit,
                     env = env)
  n <- length(optree$parsed)
  if(n<=0) {
    return(x)
  }
  # if there is an order, order now apply it (pre-pending partition)
  if((length(optree$orderby)>0) || (length(optree$partitionby)>0) ) {
    common_terms <- unique(intersect(optree$orderby, optree$partitionby))
    sort_terms <- c(optree$partitionby[!(optree$partitionby %in% common_terms)],
                    optree$orderby[optree$orderby %in% common_terms],
                    optree$orderby[!(optree$orderby %in% common_terms)])
    x <- order_table(x, sort_terms, optree$reverse)
  }
  # work on partition term
  byi <- ""
  if(length(optree$partitionby)>0) {
    pterms <- paste0("\"", optree$partitionby, "\"")
    byi <- paste0(" , by = c(", paste(pterms, collapse = ", "), ")")
  }
  # work on node

  prepped <- prepare_prased_assignments_for_data_table(optree$parsed)
  enames <- prepped$enames
  eexprs <- prepped$eexprs
  need_one_col <- prepped$need_one_col

  tmpnam <- ".rquery_ex_extend_tmp"
  rqdatatable_temp_one_col <- NULL # don't look like an unbound reference
  if(need_one_col) {
    x[ , rqdatatable_temp_one_col := 1.0]
  }
  if(length(enames)>0) {
    enames <- paste0("c(", paste(enames, collapse = ", "), ")")
    eexprs <- paste0("list(", paste(eexprs, collapse = ", "), ")")
    # := notation means add columns to current data.table, j notation would move to summarize type calc.
    src <- paste0(tmpnam, "[ ",
                  " , ", paste(enames, ":=", eexprs),
                  byi,
                  " ]")
    expr <- parse(text = src)
    tmpenv <- patch_global_child_env(env)
    assign(tmpnam, x, envir = tmpenv)
    x <- eval(expr, envir = tmpenv, enclos = tmpenv)
  }
  # fast ranking (seems more compatible with this workflow than data.table::frank())
  # could also try a grouped cumsum()
  if('rqdatatable_temp_one_col' %in% colnames(x)) {
    x[ , rqdatatable_temp_one_col := NULL]
  }
  x[]
}

