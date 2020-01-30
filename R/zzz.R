
# don't let . look like an unbound reference
. = NULL


#' Set rqdatatable package as default rquery executor
#'
#' Sets rqdatatable (and hence data.table) as the default executor for rquery).
#'
#' @export
#'
set_rqdatatable_as_executor <- function() {
  options(list("rquery.rquery_executor" = list(f = ex_data_table, name = "rqdatable")))
  invisible(NULL)
}

.onAttach <- function(libname, pkgname) {
  # attach happens after load, so set as the executor only in the attach case
  prev_exec <- getOption("rquery.rquery_executor", default = NULL)
  if(is.null(prev_exec) || (is.list(prev_exec) && isTRUE(prev_exec$name == "rqdatable"))) {
    set_rqdatatable_as_executor()
  }
  invisible(NULL)
}
