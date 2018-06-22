

# execute an rquery pipeline with data.table sources


#' @importFrom data.table :=
NULL


#' @importFrom wrapr mk_tmp_name_source
#' @export
wrapr::mk_tmp_name_source

#' @importFrom wrapr map_to_char
#' @export
wrapr::map_to_char

#' @importFrom wrapr %.>%
#' @export
wrapr::`%.>%`

#' @importFrom wrapr %:=%
#' @export
wrapr::`%:=%`

#' @importFrom wrapr let
#' @export
wrapr::let

#' @importFrom wrapr qc
#' @export
wrapr::qc

#' @importFrom wrapr qc
#' @export
wrapr::qc

#' @importFrom wrapr qe
#' @export
wrapr::qe

#' @importFrom wrapr build_frame
#' @export
wrapr::build_frame

#' @importFrom wrapr draw_frame
#' @export
wrapr::draw_frame

#' @importFrom wrapr qchar_frame
#' @export
wrapr::qchar_frame

#' @importFrom wrapr apply_left
#' @export
wrapr::apply_left

#' @importFrom wrapr apply_right
#' @export
wrapr::apply_right




# don't let . look like an unbound reference
. <- NULL




#' Execute an \code{rquery} pipeline with \code{data.table} sources.
#'
#' \code{data.table}s are looked for by name in the \code{tables} argument and in the execution environment.
#'
#'\itemize{
#'  \item \code{\link{ex_data_table.relop_drop_columns}}: implement drop columns
#'  \item \code{\link{ex_data_table.relop_extend}}: implement extend/assign operator
#'  \item \code{\link{ex_data_table.relop_natural_join}}: implement natural join
#'  \item \code{\link{ex_data_table.relop_non_sql}}: direct function (non-sql) operator (not implemented for \code{data.table})
#'  \item \code{\link{ex_data_table.relop_null_replace}}: implement NA/NULL replacement
#'  \item \code{\link{ex_data_table.relop_orderby}}: implement row ordering
#'  \item \code{\link{ex_data_table.relop_project}}: implement row ordering
#'  \item \code{\link{ex_data_table.relop_rename_columns}}: implement column renaming
#'  \item \code{\link{ex_data_table.relop_select_columns}}: implement select columns
#'  \item \code{\link{ex_data_table.relop_select_rows}}: implement select rows
#'  \item \code{\link{ex_data_table.relop_sql}}: direct sql operator (not implemented for \code{data.table})
#'  \item \code{\link{ex_data_table.relop_table_source}}: implement data source
#'  \item \code{\link{ex_data_table.relop_theta_join}}: implement theta join  (not implemented for \code{data.table})
#'  \item \code{\link{ex_data_table.relop_unionall}}: implement row binding
#' }
#'
#' @param optree relop operations tree.
#' @param ... not used, force later arguments to bind by name.
#' @param tables named list map from table names used in nodes to data.tables and data.frames.
#' @param source_usage list mapping source table names to vectors of columns used.
#' @param source_limit if not null limit all table sources to no more than this many rows (used for debugging).
#' @param env environment to work in.
#' @return resulting data.table (intermediate tables can somtimes be mutated as is practice with data.table).
#'
#' @examples
#'
#'   a <- data.table::data.table(x = c(1, 2) , y = c(20, 30), z = c(300, 400))
#'   optree <- local_td(a) %.>%
#'      select_columns(., c("x", "y")) %.>%
#'      select_rows_nse(., x<2 & y<30)
#'   cat(format(optree))
#'   print(ex_data_table(optree)[])
#'
#'   # other ways to execute the pipeline include
#'   as.data.frame(optree)
#'   as.data.table(optree)
#'   data.frame(x = 0, y = 4, z = 400) %.>% optree
#'
#'   # and immediate execution is also possible
#'
#'   # double apply into standard pipeline (parenthesized)
#'   data.frame(x = 1, y = 2) %>>% (
#'       extend_nse(., z = x/y) %.>%
#'       select_columns(., "z") )
#'
#'   # double apply pipeline
#'   data.frame(x = 1, y = 2) %>>%
#'       extend_nse(., z = x/y) %>>%
#'       select_columns(., "z")
#'
#' @export
#'
ex_data_table <- function(optree,
                          ...,
                          tables = list(),
                          source_usage = NULL,
                          source_limit = NULL,
                          env = parent.frame()) {
  UseMethod("ex_data_table", optree)
}

#' default non-impementation.
#'
#' Throw on error if this method is called, signalling that a specific \code{data.table} implemetation is needed for this method.
#'
#' @inheritParams ex_data_table
#' @export
ex_data_table.default <- function(optree,
                                  ...,
                                  tables = list(),
                                  source_usage = NULL,
                                  source_limit = NULL,
                                  env = parent.frame()) {
  stop(paste("rqdatatable::ex_data_table() does not have an implementation for class: ",
             paste(class(optree), collapse = ", "),
             "yet"))
}


#' @export
as.data.frame.relop <- function(x, row.names = NULL, optional = FALSE,
                                ...,
                                stringsAsFactors = FALSE,
                                env = parent.frame()) {
  wrapr::stop_if_dot_args(substitute(list(...)), "rqdatatable::as.data.frame.relop")
  if(!is.null(row.names)) {
    stop("rqdatatable::as.data.frame.relop row.names should not be set")
  }
  if(!isTRUE(optional==FALSE)) {
    stop("rqdatatable::as.data.frame.relop optional should not be set")
  }
  if(!isTRUE(stringsAsFactors==FALSE)) {
    stop("rqdatatable::as.data.frame.relop stringsAsFactors should not be set")
  }
  res <- ex_data_table(x, env = env)
  if(!is.data.frame(res)) {
    stop("qdatatable::as.data.frame.relop result was not a data.frame")
  }
  as.data.frame(res)
}

#' @importFrom data.table as.data.table is.data.table
#' @export
data.table::as.data.table

#' @export
as.data.table.relop <- function(x, keep.rownames = FALSE,
                                ...,
                                stringsAsFactors = FALSE,
                                env = parent.frame()) {
  wrapr::stop_if_dot_args(substitute(list(...)), "rqdatatable::as.data.table.relop")
  if(!isTRUE(keep.rownames==FALSE)) {
    stop("rqdatatable::as.data.table.relop keep.rownames should not be set")
  }
  if(!isTRUE(stringsAsFactors==FALSE)) {
    stop("rqdatatable::as.data.table.relop stringsAsFactors should not be set")
  }
  res <- ex_data_table(x, env = env)
  if(!is.data.frame(res)) {
    stop("qdatatable::as.data.table.relop result was not a data.frame")
  }
  if(!data.table::is.data.table(res)) {
    res <- data.table::as.data.table(res)
  }
  res
}

