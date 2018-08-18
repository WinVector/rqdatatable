

#' Implement set_indicatoroperator.
#'
#' \code{data.table} based implementation.
#'
#' @inheritParams ex_data_table
#'
#' @examples
#'
#' d <- data.frame(a = c("1", "2", "1", "3"),
#'                 b = c("1", "1", "3", "2"),
#'                 q = 1,
#'                 stringsAsFactors = FALSE)
#' set <- c("1", "2")
#' op_tree <- local_td(d) %.>%
#'   set_indicator(., "one_two", "a", set) %.>%
#'   set_indicator(., "z", "a", c())
#' ex_data_table(op_tree)
#'
#'
#' @export
ex_data_table.relop_set_indicator <- function(optree,
                                              ...,
                                              tables = list(),
                                              source_usage = NULL,
                                              source_limit = NULL,
                                              env = parent.frame()) {
  wrapr::stop_if_dot_args(substitute(list(...)), "rqdatatable::ex_data_table.relop_set_indicator")
  if(is.null(source_usage)) {
    source_usage <- columns_used(optree)
  }
  x <- ex_data_table(optree$source[[1]],
                     tables = tables,
                     source_usage = source_usage,
                     source_limit = source_limit,
                     env = env)
  RES_COL <- NULL  # don't look like an unbound ref
  TEST_COL <- NULL # don't look like an unbound ref
  wrapr::let(
    c(RES_COL = optree$rescol,
      TEST_COL = optree$testcol),
    {
      x[ , RES_COL := 0]
      x[ TEST_COL %in% optree$testvalues, RES_COL := 1 ]
    }
  )
  x[]
}

