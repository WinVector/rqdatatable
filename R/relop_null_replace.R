

#' @describeIn ex_data_table implement NA/NULL replacement
#' @export
ex_data_table.relop_null_replace <- function(optree,
                                             ...,
                                             tables = list(),
                                             source_usage = NULL,
                                             env = parent.frame()) {
  stop("rquery::ex_data_table.relop_null_replace not implemented yet") # TODO: test and release
  wrapr::stop_if_dot_args(substitute(list(...)), "rquery::ex_data_table.relop_null_replace")
  if(is.null(source_usage)) {
    source_usage <- columns_used(optree)
  }
  x <- ex_data_table(optree$source[[1]],
                     tables = tables,
                     source_usage = source_usage,
                     env = env)
  NOTECOL <- NULL # don't look like an unbound reference
  if(!is.null(optree$notecol)) {
    wrapr::let(
      c(NOTECOL = optree$notecol),
      x <- x[, NOTECOL := 0]
    )
  }
  COL <- NULL # don't look like an unbound reference
  for(ci in optree$cols) {
    wrapr::let(
      c(COL = ci,
        NOTECOL = optree$notecol),
      {
        x[ is.na(COL), NOTECOL = NOTECOL + 1 ]
        x[ is.na(COL), COL = optree$value ]
      }
    )
  }
  x
}

