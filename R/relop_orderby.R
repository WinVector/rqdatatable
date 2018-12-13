
# alters argument in place, value returned for convenience
order_table <- function(x, orderby, reverse) {
  if(length(setdiff(reverse, orderby))>0) {
    stop("qdatatable order_table reverse must be contained in orderby")
  }
  if(length(orderby)<=0) {
    return(x)
  }
  order <- rep(1L, length(orderby))
  if(length(reverse)>0) {
    order[orderby %in% reverse] <- -1L
  }
  data.table::setorderv(x, cols = orderby, order = order)[]
}

#' Reorder rows.
#'
#' \code{data.table} based implementation.
#'
#' @inheritParams ex_data_table
#'
#' @examples
#'
#' dL <- build_frame(
#'     "x", "y" |
#'     2L , "b" |
#'     1L , "a" |
#'     3L , "c" )
#' rquery_pipeline <- local_td(dL) %.>%
#'   orderby(., "y")
#' ex_data_table(rquery_pipeline)
#'
#' @export
ex_data_table.relop_orderby <- function(optree,
                                        ...,
                                        tables = list(),
                                        source_usage = NULL,
                                        source_limit = NULL,
                                        env = parent.frame()) {
  force(env)
  wrapr::stop_if_dot_args(substitute(list(...)), "rqdatatable::ex_data_table.relop_orderby")
  if(is.null(source_usage)) {
    source_usage <- columns_used(optree)
  }
  x <- ex_data_table(optree$source[[1]],
                     tables = tables,
                     source_usage = source_usage,
                     source_limit = source_limit,
                     env = env)
  x <- order_table(x, optree$orderby, optree$reverse)
  if(!is.null(optree$limit)) {
    n <- nrow(x)
    if(optree$limit < n) {
      x <- x[seq_len(optree$limit), , drop = FALSE]
    }
  }
  x
}


