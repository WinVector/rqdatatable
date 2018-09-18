





#' Build a data source description.
#'
#' \code{data.table} based implementation.
#' Looks for tables first in \code{tables} and then in \code{env}.
#' Will accept any \code{data.frame} that can
#' be converted to \code{data.table}.
#'
#' @inheritParams ex_data_table
#'
#' @examples
#'
#' dL <- build_frame(
#'     "x", "y" |
#'     2L , "b" |
#'     1L , "a" |
#'     3L , "c" )
#' rquery_pipeline <- local_td(dL)
#' ex_data_table(rquery_pipeline)
#'
#' @export
ex_data_table.relop_table_source <- function(optree,
                                             ...,
                                             tables = list(),
                                             source_usage = NULL,
                                             source_limit = NULL,
                                             env = parent.frame()) {
  force(env)
  wrapr::stop_if_dot_args(substitute(list(...)), "rqdatatable::ex_data_table.relop_table_source")
  name <- optree$table_name
  res <- NULL
  if(name %in% names(tables)) {
    res <- tables[[name]]
  } else {
    res <- get(name, envir = env)
  }
  if(is.null(res)) {
    stop(paste("rqdatatable::ex_data_table.relop_table_source, could not find: ",
               name))
  }
  if(!is.data.frame(res)) {
    stop(paste("rqdatatable::ex_data_table.relop_table_source ",
               name,
               " is not a data.frame (class: ",
               paste(class(res), collapse = ", "),
               ")"))
  }
  cols_have <- colnames(res)
  cols_want <- NULL
  if(!is.null(source_usage)) {
    cols_want <- source_usage[[name]]
  } else {
    cols_want <- column_names(optree)
  }
  missing_cols <- setdiff(cols_want, cols_have)
  if(length(missing_cols)>0) {
    stop(paste("rqdatatable::ex_data_table.relop_table_source missing required columns",
               paste(missing_cols, collapse = ", ")))
  }
  if(!data.table::is.data.table(res)) {
    if((!is.null(source_limit)) && (source_limit<nrow(res))) {
      res <- data.table::as.data.table(res[seq_len(source_limit), cols_want, drop = FALSE])
    } else {
      res <- data.table::as.data.table(res[, cols_want, drop = FALSE])
    }
  } else {
    if((!is.null(source_limit)) && (source_limit<nrow(res))) {
      res <- data.table::copy(res[seq_len(source_limit), cols_want, with = FALSE]) # try to break reference semantics
    } else {
      res <- data.table::copy(res[, cols_want, with = FALSE]) # try to break reference semantics
    }
  }
  res
}
