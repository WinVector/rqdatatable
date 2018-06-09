

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
#' Execute an \code{rquery} pipeline with \code{data.table} in parallel partitioned by a given column.
#' Note: usually the overhead of partitioning and distributing the work will by far overwhelm any parallel speedup.
#' Also, not all optrees return the same result partitioned as when not partitioned: the user must ensure the partitioning column is
#' structured to ensure this.
#' Also \code{data.table} itself already seems to exploit some thread-level parallelism (one often sees user time > elapsed time).
#' Requires the \code{parallel} package.
#'
#'
#' @param optree relop operations tree.
#' @param partition_column character name of column to partition work by.
#' @param cl a cluster object, created by package parallel or by package snow. If NULL, use the registered default cluster.
#' @param ... not used, force later arguments to bind by name.
#' @param tables named list map from table names used in nodes to data.tables and data.frames.
#' @param source_limit if not null limit all table sources to no more than this many rows (used for debugging).
#' @param debug logical if TRUE use lapply instead of parallel::clusterApplyLB.
#' @param env environment to work in.
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
  # make sure all needed tables are in the ntables list
  ntables <- list()
  for(ni in names(source_usage)) {
    ti <- tables[[ni]]
    if(is.null(ti)) {
      ti <- get(ni, envir = env) # should throw if not found
    }
    # front-load some error checking
    if(!is.data.frame(ti)) {
      stop(paste("rqdatatable::ex_data_table_parallel all arguments must resolve to data.frames",
           ni, paste(class(ti), collapse = " ")))
    }
    nsi <- source_usage[[ni]]
    nti <- colnames(ti)
    missing <- setdiff(nsi, nti)
    if(length(missing)>0) {
      stop(paste("rqdatatable::ex_data_table_parallel missing required columns",
                 ni, paste(missing, collapse = " ")))
    }
    if((partition_column %in% nti) && (!(partition_column %in% nsi))) {
      # preserve partition column
      nsi <- c(nsi, partition_column)
    }
    if(is.null(source_limit) || (nrow(ti)>source_limit)) {
      ntables[[ni]] <- ti[ , nsi, drop = FALSE]
    } else {
      ntables[[ni]] <- ti[seq_len(source_limit), nsi, drop = FALSE]
    }
  }
  # get a list of values of the partition column
  levels <- c()
  for(ni in names(ntables)) {
    ti <- ntables[[ni]]
    if(partition_column %in% colnames(ti)) {
      levels <- unique(c(levels, as.character(ti[[partition_column]])))
    }
  }
  if(length(levels)<=0) {
    stop(paste("rqdatatable::ex_data_table_parallel no values found for partition column", partition_column))
  }
  # build a list of tablesets
  tablesets <- lapply(levels,
                      function(li) {
                        nti <- ntables
                        for(ni in names(ntables)) {
                          ti <- ntables[[ni]]
                          if(partition_column %in% colnames(ti)) {
                            nti[[ni]] <- ti[as.character(ti[[partition_column]])==li, , drop = FALSE]
                          }
                        }
                        nti
                      })
  if(debug) {
    res <- lapply(tablesets, parallel_f, optree = optree)
  } else {
    # dispatch the operation in parallel
    res <- parallel::clusterApplyLB(cl, tablesets, parallel_f, optree = optree)
  }
  res <- data.table::rbindlist(res)
  if("relop_orderby" %in% class(optree)) {
    reord <- orderby(local_td(res), cols = optree$orderby, reverse = optree$reverse)
    res <- ex_data_table(optree = reord)
  }
  res
}
