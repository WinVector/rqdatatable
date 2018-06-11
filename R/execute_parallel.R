

#' @importFrom parallel clusterApplyLB
NULL


parallel_f <- function(tables, ...) {
  args <- list(...)
  optree = args[["optree"]]
  res <- ex_data_table(optree = optree,
                       tables = tables)
  res
}



#' Execute an \code{rquery} pipeline with \code{data.table} in parallel.
#'
#' Execute an \code{rquery} pipeline with \code{data.table} in parallel, partitioned by a given column.
#' Note: usually the overhead of partitioning and distributing the work will by far overwhelm any parallel speedup.
#' Also \code{data.table} itself already seems to exploit some thread-level parallelism (one often sees user time > elapsed time).
#' Requires the \code{parallel} package.  For a worked example with significant speedup please see \url{https://github.com/WinVector/rqdatatable/blob/master/extras/Parallel_rqdatatable.md}.
#'
#' Care must be taken that the calculation partitioning is course enough to ensure a correct calculation.  For example: anything
#' one is joining on, aggergating over, or ranking over must be grouped so that all elements affecting a given result row are
#' in the same level of the partition.
#'
#'
#' @param optree relop operations tree.
#' @param partition_column character name of column to partition work by.
#' @param cl a cluster object, created by package parallel or by package snow. If NULL, use the registered default cluster.
#' @param ... not used, force later arguments to bind by name.
#' @param tables named list map from table names used in nodes to data.tables and data.frames.
#' @param source_limit if not null limit all table sources to no more than this many rows (used for debugging).
#' @param debug logical if TRUE use lapply instead of parallel::clusterApplyLB.
#' @param env environment to look for values in.
#' @return resulting data.table (intermediate tables can somtimes be mutated as is practice with data.table).
#'
#'
#'
#' @export
#'
ex_data_table_parallel <- function(optree,
                                   partition_column,
                                   cl = NULL,
                                   ...,
                                   tables = list(),
                                   source_limit = NULL,
                                   debug = FALSE,
                                   env = parent.frame()) {
  if(!requireNamespace("parallel", quietly = TRUE)) {
    stop("rqdatatable::ex_data_table_parallel requires the parallel package be installed.")
  }
  wrapr::stop_if_dot_args(substitute(list(...)), "rqdatatable::ex_data_table_parallel")
  source_usage <- columns_used(optree)
  tablesets <- wrapr::partition_tables(names(source_usage),
                                       partition_column = partition_column,
                                       source_usage = source_usage,
                                       source_limit = source_limit,
                                       tables = tables,
                                       env = env)
  if(debug) {
    res <- lapply(tablesets, parallel_f, optree = optree)
  } else {
    # dispatch the operation in parallel
    res <- parallel::clusterApplyLB(cl, tablesets, parallel_f, optree = optree)
  }
  tablesets <- NULL
  res <- data.table::rbindlist(res)
  if("relop_orderby" %in% class(optree)) {
    order_table(res, orderby = optree$orderby, reverse = optree$reverse)
  }
  res
}
