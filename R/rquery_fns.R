

# execute an rquery pipeline with data.table sources


#' @importFrom data.table :=
NULL

#' @importFrom wrapr %:=%
NULL




#' Execute an \code{rquery} pipeline with \code{data.table} sources.
#'
#' \code{data.table}s are looked for by name in the \code{tables} argument and in the execution environment.
#' Main external execution interface.
#'
#'\itemize{
#'  \item \code{\link{ex_data_table_step.relop_drop_columns}}: implement drop columns
#'  \item \code{\link{ex_data_table_step.relop_extend}}: implement extend/assign operator
#'  \item \code{\link{ex_data_table_step.relop_natural_join}}: implement natural join
#'  \item \code{\link{ex_data_table_step.relop_non_sql}}: direct function (non-sql) operator (not implemented for \code{data.table})
#'  \item \code{\link{ex_data_table_step.relop_null_replace}}: implement NA/NULL replacement
#'  \item \code{\link{ex_data_table_step.relop_orderby}}: implement row ordering
#'  \item \code{\link{ex_data_table_step.relop_project}}: implement row ordering
#'  \item \code{\link{ex_data_table_step.relop_rename_columns}}: implement column renaming
#'  \item \code{\link{ex_data_table_step.relop_select_columns}}: implement select columns
#'  \item \code{\link{ex_data_table_step.relop_select_rows}}: implement select rows
#'  \item \code{\link{ex_data_table_step.relop_sql}}: direct sql operator (not implemented for \code{data.table})
#'  \item \code{\link{ex_data_table_step.relop_table_source}}: implement data source
#'  \item \code{\link{ex_data_table_step.relop_theta_join}}: implement theta join  (not implemented for \code{data.table})
#'  \item \code{\link{ex_data_table_step.relop_unionall}}: implement row binding
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
#'   ex_data_table(optree)
#'
#'   # other ways to execute the pipeline include
#'   data.frame(x = 0, y = 4, z = 400) %.>% optree
#'
#'
#' @export
#'
ex_data_table <- function(optree,
                          ...,
                          tables = list(),
                          source_usage = NULL,
                          source_limit = NULL,
                          env = parent.frame()) {
  force(env)
  data_table_in <- isTRUE(any(vapply(tables, data.table::is.data.table, logical(1))))
  res <- ex_data_table_step(optree, tables = tables, source_usage = source_usage, source_limit = source_limit, env = env)
  if(!data_table_in) {
    res <- as.data.frame(res)
  }
  res
}


#' Execute an \code{rquery} pipeline with \code{data.table} sources.
#'
#' \code{data.table}s are looked for by name in the \code{tables} argument and in the execution environment.
#' Internal execution interface.
#'
#'\itemize{
#'  \item \code{\link{ex_data_table_step.relop_drop_columns}}: implement drop columns
#'  \item \code{\link{ex_data_table_step.relop_extend}}: implement extend/assign operator
#'  \item \code{\link{ex_data_table_step.relop_natural_join}}: implement natural join
#'  \item \code{\link{ex_data_table_step.relop_non_sql}}: direct function (non-sql) operator (not implemented for \code{data.table})
#'  \item \code{\link{ex_data_table_step.relop_null_replace}}: implement NA/NULL replacement
#'  \item \code{\link{ex_data_table_step.relop_orderby}}: implement row ordering
#'  \item \code{\link{ex_data_table_step.relop_project}}: implement row ordering
#'  \item \code{\link{ex_data_table_step.relop_rename_columns}}: implement column renaming
#'  \item \code{\link{ex_data_table_step.relop_select_columns}}: implement select columns
#'  \item \code{\link{ex_data_table_step.relop_select_rows}}: implement select rows
#'  \item \code{\link{ex_data_table_step.relop_sql}}: direct sql operator (not implemented for \code{data.table})
#'  \item \code{\link{ex_data_table_step.relop_table_source}}: implement data source
#'  \item \code{\link{ex_data_table_step.relop_theta_join}}: implement theta join  (not implemented for \code{data.table})
#'  \item \code{\link{ex_data_table_step.relop_unionall}}: implement row binding
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
#' @keywords internal
#'
#' @examples
#'
#'   a <- data.table::data.table(x = c(1, 2) , y = c(20, 30), z = c(300, 400))
#'   optree <- local_td(a) %.>%
#'      select_columns(., c("x", "y")) %.>%
#'      select_rows_nse(., x<2 & y<30)
#'   cat(format(optree))
#'   ex_data_table_step(optree)
#'
#'   # other ways to execute the pipeline include
#'   ex_data_table(optree)
#'   data.frame(x = 0, y = 4, z = 400) %.>% optree
#'
#'
#' @export
#'
ex_data_table_step <- function(optree,
                          ...,
                          tables = list(),
                          source_usage = NULL,
                          source_limit = NULL,
                          env = parent.frame()) {
  force(env)
  UseMethod("ex_data_table_step", optree)
}



#' default non-impementation.
#'
#' Throw on error if this method is called, signalling that a specific \code{data.table} implemetation is needed for this method.
#'
#' @inheritParams ex_data_table_step
#' @export
ex_data_table_step.default <- function(optree,
                                  ...,
                                  tables = list(),
                                  source_usage = NULL,
                                  source_limit = NULL,
                                  env = parent.frame()) {
  force(env)
  stop(paste("rqdatatable::ex_data_table_step() does not have an implementation for class: ",
             paste(class(optree), collapse = ", "),
             "yet"))
}



#' @importFrom data.table as.data.table is.data.table
#' @export
data.table::as.data.table

#' @importFrom rquery column_names columns_used local_td non_sql_node rquery_apply_to_data_frame
NULL


