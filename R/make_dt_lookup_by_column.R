
#' Lookup by column function factory.
#'
#' Build data.table implementation of lookup_by_column.  We do this here as rqdatatable is
#' a data.table aware package (and rquery is not).
#'
#' @param pick character scalar, name of column to control value choices.
#' @param result character scalar, name of column to place values in.
#' @return f_dt() function.
#'
#' @examples
#'
#' df = data.frame(x = c(1, 2, 3, 4),
#'                 y = c(5, 6, 7, 8),
#'                 choice = c("x", "y", "x", "z"),
#'                 stringsAsFactors = FALSE)
#' make_dt_lookup_by_column("choice", "derived")(df)
#'
#' # # base-R implementation
#' # df %.>% lookup_by_column(., "choice", "derived")
#' # # # data.table implementation (requies rquery 1.1.0, or newer)
#' # # df %.>% lookup_by_column(., "choice", "derived",
#' # #                          f_dt_factory = rqdatatable::make_dt_lookup_by_column)
#'
#' @export
#'
#'
make_dt_lookup_by_column <- function(pick, result) {
  force(pick)
  force(result)
  f_dt <- function(d) {
    dt <- as.data.table(d)
    # dt[, RESULT := .SD[[PICK]], by = PICK][] # alternate
    .I <- PICK <- RESULT <- NULL # don't look like unbound symbols
    wrapr::let(
      c(PICK = pick, RESULT = result),
      dt[, RESULT := dt[[PICK]][.I], by = PICK]
    )
    dt[]
  }
  f_dt
}
