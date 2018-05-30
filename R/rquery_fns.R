

# execute an rquery pipeline with data.table sources


#' @importFrom data.table :=
#' @importFrom rquery columns_used column_names
NULL

#' @importFrom wrapr %.>%
#' @export
wrapr::`%.>%`

#' @importFrom wrapr build_frame
#' @export
wrapr::build_frame


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
#'   print(ex_data_table(optree))
#'
#' @export
#'
ex_data_table <- function(optree,
                          ...,
                          tables = list(),
                          source_usage = NULL,
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
                                  env = parent.frame()) {
  stop(paste("rquery::ex_data_table() does not have an implementation for class: ",
             paste(class(optree), collapse = ", "),
             "yet"))
}





build_order_clause <- function(orderby, rev_orderby) {
  oterms <- character(0)
  if(length(orderby)>0) {
    oterms <- c(oterms, orderby)
  }
  if(length(rev_orderby)>0) {
    oterms <- c(oterms, paste0("-", rev_orderby))
  }
  if(length(oterms)<=0) {
    return(NULL)
  }
  paste("order(",
        paste(oterms, collapse = ", "),
        ")")
}



