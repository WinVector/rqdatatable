

#' Bind tables together by rows.
#'
#' \code{data.table} based implementation.
#'
#' @inheritParams ex_data_table_step
#'
#' @examples
#'
#' dL <- build_frame(
#'     "x", "y" |
#'     2L , "b" |
#'     1L , "a" |
#'     3L , "c" )
#' rquery_pipeline <- unionall(list(local_td(dL), local_td(dL)))
#' ex_data_table_step(rquery_pipeline)
#'
#' @export
ex_data_table_step.relop_unionall <- function(optree,
                                         ...,
                                         tables = list(),
                                         source_usage = NULL,
                                         source_limit = NULL,
                                         env = parent.frame()) {
  force(env)
  if(is.null(source_usage)) {
    source_usage <- columns_used(optree)
  }
  inputs <- lapply(optree$source,
                   function(si) {
                     ex_data_table_step(si,
                                   tables = tables,
                                   source_usage = source_usage,
                                   source_limit = source_limit,
                                   env = env)
                   })
  data.table::rbindlist(inputs)
}


