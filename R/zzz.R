

rqdatatable_default_options <- list(
  rquery.rquery_executor = list(f = ex_data_table)
)

.onLoad <- function(libname, pkgname) {
  op <- options()
  toset <- setdiff(names(rqdatatable_default_options), names(op))
  if(length(toset)>0) {
    options(rqdatatable_default_options[toset])
  }
  invisible()
}
