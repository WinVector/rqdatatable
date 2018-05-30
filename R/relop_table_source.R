
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
#' ex_data_table(rquery_pipeline)[]
#'
#' @export
ex_data_table.relop_table_source <- function(optree,
                                             ...,
                                             tables = list(),
                                             source_usage = NULL,
                                             env = parent.frame()) {
  wrapr::stop_if_dot_args(substitute(list(...)), "rquery::ex_data_table.relop_table_source")
  name <- optree$table_name
  res <- NULL
  if(name %in% tables) {
    res <- tables[[name]]
  } else {
    res <- get(name, envir = env)
  }
  if(is.null(res)) {
    stop(paste("rquery::ex_data_table.relop_table_source, could not find: ",
               name))
  }
  if(!is.data.frame(res)) {
    stop(paste("rquery::ex_data_table.relop_table_source ",
               name,
               " is not a data.frame (class: ",
               paste(class(res), collapse = ", "),
               ")"))
  }
  cols <- NULL
  if(!is.null(source_usage)) {
    cols <- source_usage[[name]]
  }
  if(!data.table::is.data.table(res)) {
    if(length(cols)>0) {
      res <- data.table::as.data.table(res[, cols, drop = FALSE])
    } else {
      res <- data.table::as.data.table(res)
    }
  } else {
    res <- data.table::copy(res[, cols, with = FALSE]) # try to break reference semantics
  }
  res
}
