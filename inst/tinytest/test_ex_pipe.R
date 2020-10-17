
test_ex_pipe <- function() {

  d <- data.frame(x = 1)
  ops <- local_td(d) %.>% extend_nse(., y = x + 1)
  expect_true("relop" %in% class(ops))
  r <- d %.>% ops
  expect_true(is.data.frame(r))

  invisible(NULL)
}

test_ex_pipe()
