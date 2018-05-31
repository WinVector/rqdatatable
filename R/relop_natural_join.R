
#' Natural join.
#'
#' \code{data.table} based implementation.  Note: does not yet match \code{rquery} common column coalesce semantics,
#' so all common columns must be join conditions.
#'
#' @inheritParams ex_data_table
#'
#' @examples
#'
#' a <- build_frame(
#'     "x", "y" |
#'     1L , "a" |
#'     2L , "b" )
#' b <- build_frame(
#'     "x", "z" |
#'     2L , "x" |
#'     3L , "y" )
#' rquery_pipeline <-
#'   natural_join(local_td(a), local_td(b),
#'                by = "x",
#'                jointype = "FULL")
#' ex_data_table(rquery_pipeline)[]
#'
#' @export
ex_data_table.relop_natural_join <- function(optree,
                                             ...,
                                             tables = list(),
                                             source_usage = NULL,
                                             source_limit = NULL,
                                             env = parent.frame()) {
  wrapr::stop_if_dot_args(substitute(list(...)), "rquery::ex_data_table.relop_natural_join")
  if(is.null(source_usage)) {
    source_usage <- columns_used(optree)
  }
  inputs <- lapply(optree$source,
                   function(si) {
                     ex_data_table(si,
                                   tables = tables,
                                   source_usage = source_usage,
                                   source_limit = source_limit,
                                   env = env)
                   })
  A <- inputs[[1]]
  B <- inputs[[2]]
  common <- sort(intersect(column_names(A), column_names(B)))
  if(!isTRUE(all.equal(common, sort(optree$by)))) {
    stop("ex_data_table.relop_natural_join all common columns must be in by-clause")
  }
  if(optree$jointype=="INNER") {

  } else if(optree$jointype=="INNER") {
    A[B, nomatch = 0]
  } else if(optree$jointype=="LEFT") {
    A[B]
  } else if(optree$jointype=="RIGHT") {
    B[A]
  } else if(optree$jointype=="FULL") {
    merge(A, B, all=TRUE)
  } else {
    stop(paste("jointype was", optree$jointype, " but should be one of INNER, LEFT, RIGHT, or FULL"))
  }
}

