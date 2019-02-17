
test_ex_pipe <- function() {

  d <- data.frame(x = 1)
  ops <- local_td(d) %.>% extend_nse(., y = x + 1)
  RUnit::checkTrue("relop" %in% class(ops))
  r <- d %.>% ops
  RUnit::checkTrue(is.data.frame(r))

  invisible(NULL)
}
