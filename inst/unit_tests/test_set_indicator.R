
test_set_indicator <- function() {

  d <- data.frame(
    id = 1:4,
    a = c("1", "2", "1", "3"),
    b = c("1", "1", "3", "2"),
    q = 1,
    stringsAsFactors = FALSE)
  # example
  set <- c("1", "2")
  op_tree <- local_td(d) %.>%
    set_indicator(., "one_two", "a", set) %.>%
    set_indicator(., "z", "a", c()) %.>%
    orderby(., "id")
  res = d %.>% op_tree
  RUnit::checkEquals(c(1,1,1,0), res$one_two)

  invisible(NULL)
}
