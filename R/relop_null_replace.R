

#' Replace NAs.
#'
#' \code{data.table} based implementation.
#'
#' @inheritParams ex_data_table
#'
#' @examples
#'
#' dL <- build_frame(
#'     "x", "y" |
#'     2L ,  5  |
#'     NA ,  7  |
#'     NA , NA )
#' rquery_pipeline <- local_td(dL) %.>%
#'   null_replace(., c("x", "y"), 0, note_col = "nna")
#' ex_data_table(rquery_pipeline)
#'
#' @export
ex_data_table.relop_null_replace <- function(optree,
                                             ...,
                                             tables = list(),
                                             source_usage = NULL,
                                             source_limit = NULL,
                                             env = parent.frame()) {
  force(env)
  wrapr::stop_if_dot_args(substitute(list(...)), "rqdatatable::ex_data_table.relop_null_replace")
  if(is.null(source_usage)) {
    source_usage <- columns_used(optree)
  }
  x <- ex_data_table(optree$source[[1]],
                     tables = tables,
                     source_usage = source_usage,
                     source_limit = source_limit,
                     env = env)
  if(!is.null(optree$note_col)) {
    x[[optree$note_col]] <- 0
  }
  for(ci in optree$cols) {
    if(!is.null(optree$note_col)) {
      x[[optree$note_col]] <- x[[optree$note_col]] + ifelse(is.na(x[[ci]]), 1, 0)
    }
    x[[ci]] <- ifelse(is.na(x[[ci]]), optree$value, x[[ci]])
  }
  x
}

