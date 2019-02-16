
#' Natural join.
#'
#' \code{data.table} based implementation.
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
#'
#' # key matching join
#' optree <- natural_join(local_td(d1), local_td(d2),
#'                        jointype = "FULL", by = 'key')
#' ex_data_table(optree)
#'
#' # full cross-product join
#' # (usually with jointype = "FULL", but "LEFT" is more
#' # compatible with rquery field merge semantics).
#' optree2 <- natural_join(local_td(d1), local_td(d2),
#'                         jointype = "LEFT", by = NULL)
#' ex_data_table(optree2)
#' # notice ALL non-"by" fields take coalese to left table.
#'
#' @export
ex_data_table.relop_natural_join <- function(optree,
                                             ...,
                                             tables = list(),
                                             source_usage = NULL,
                                             source_limit = NULL,
                                             env = parent.frame()) {
  force(env)
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
  inputs <- NULL
  by <- optree$by
  common_non_key <- sort(setdiff(intersect(column_names(A), column_names(B)),
                                 by))
  new_non_key <- paste0("rquery_join_tmp_", common_non_key)
  if(length(common_non_key)>0) {
    data.table::setnames(B, old = common_non_key, new = new_non_key)
  }
  col_to_zap <- NULL
  ACOL <- NULL # don't look like an unbound ref
  BCOL <- NULL # don't look like an unbound ref
  if(length(by)<1) {
    # data.table deliberately does not accept empty by
    col_to_zap <- "requery_join_const"
    wrapr::let(
      c(ACOL = col_to_zap,
        BCOL = col_to_zap),
      {
        A[, ACOL := 'a']
        B[, BCOL := 'a']
      })
    by <- col_to_zap
  }
  res <- if(optree$jointype=="INNER") {
    merge(A, B, by = by, all=FALSE, allow.cartesian=TRUE)
  } else if(optree$jointype=="LEFT") {
    merge(A, B, by = by, all.x=TRUE, allow.cartesian=TRUE)
  } else if(optree$jointype=="RIGHT") {
    merge(A, B, by = by, all.y=TRUE, allow.cartesian=TRUE)
  } else if(optree$jointype=="FULL") {
    merge(A, B, by = by, all=TRUE, allow.cartesian=TRUE)
  } else {
    stop(paste("jointype was", optree$jointype, " but should be one of INNER, LEFT, RIGHT, or FULL"))
  }
  # fix up common columns with rquery coallesce rules
  for(i in seq_len(length(common_non_key))) {
    wrapr::let(
      c(ACOL = common_non_key[[i]],
        BCOL = new_non_key[[i]]),
      {
        res[, ACOL := ifelse(is.na(ACOL), BCOL, ACOL)]
        res[, BCOL := NULL]
      })
  }
  if(!is.null(col_to_zap)) {
    wrapr::let(
      c(ACOL = col_to_zap),
      {
        res[, ACOL := NULL]
      })
  }
  res[]
}

