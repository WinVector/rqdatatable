
test_colon <- function() {

  d <- data.frame(t = 1:2)
  r <- d %.>% extend(., u = 4:5)
  RUnit::checkEquals(data.table::data.table(t = 1:2, u = 4:5), r)

  invisible(NULL)
}
