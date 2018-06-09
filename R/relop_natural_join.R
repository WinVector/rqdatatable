
#' Natural join.
#'
#' \code{data.table} based implementation.  Note: does not yet match \code{rquery} common column coalesce semantics,
#' so all common columns must be join conditions.
#'
#' @inheritParams ex_data_table
#'
#' @examples
#'
#' d1 <- build_frame(
#'     "key", "val", "val1" |
#'       "a"  , 1  ,  10    |
#'       "b"  , 2  ,  11    |
#'       "c"  , 3  ,  12    )
#' d2 <- build_frame(
#'     "key", "val", "val2" |
#'       "a"  , 5  ,  13    |
#'       "b"  , 6  ,  14    |
#'       "d"  , 7  ,  15    )
#' # can't have shared non-key columns in rqdatatable yet
#' d1$val <- NULL
#' d2$val <- NULL
#'
#' # key matching join
#' optree <- natural_join(local_td(d1), local_td(d2),
#'                        jointype = "FULL", by = 'key')
#' ex_data_table(optree)[]
#'
#' # can't have shared non-key columns in rqdatatable yet
#' # # full cross-product join
#' # optree2 <- natural_join(local_td(d1), local_td(d2),
#' #                         jointype = "FULL", by = NULL)
#' # ex_data_table(optree2)[]
#'
#' @export
ex_data_table.relop_natural_join <- function(optree,
                                             ...,
                                             tables = list(),
                                             source_usage = NULL,
                                             source_limit = NULL,
                                             env = parent.frame()) {
  wrapr::stop_if_dot_args(substitute(list(...)), "rqdatatable::ex_data_table.relop_natural_join")
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
    stop("ex_data_table.relop_natural_join currently for data.table implementation all common columns must be in by-clause")
  }
  if(optree$jointype=="INNER") {
    merge(A, B, by = optree$by, all=FALSE, allow.cartesian=TRUE)
  } else if(optree$jointype=="LEFT") {
    merge(A, B, by = optree$by, all.x=TRUE, allow.cartesian=TRUE)
  } else if(optree$jointype=="RIGHT") {
    merge(A, B, by = optree$by, all.y=TRUE, allow.cartesian=TRUE)
  } else if(optree$jointype=="FULL") {
    merge(A, B, by = optree$by, all=TRUE, allow.cartesian=TRUE)
  } else {
    stop(paste("jointype was", optree$jointype, " but should be one of INNER, LEFT, RIGHT, or FULL"))
  }
}

