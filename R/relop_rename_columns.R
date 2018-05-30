

#' @describeIn ex_data_table implement column renaming
#' @export
ex_data_table.relop_rename_columns <- function(optree,
                                               ...,
                                               tables = list(),
                                               source_usage = NULL,
                                               env = parent.frame()) {
  stop("rquery::ex_data_table.relop_rename_columns not implemented yet") # TODO: test and release
  wrapr::stop_if_dot_args(substitute(list(...)), "rquery::ex_data_table.relop_rename_columns")
  if(is.null(source_usage)) {
    source_usage <- columns_used(optree)
  }
  x <- ex_data_table(optree$source[[1]],
                     tables = tables,
                     source_usage = source_usage,
                     env = env)
  data.table::setnames(x, old = names(optree$cmap), new = as.character(optree$cmap))
  x
}


