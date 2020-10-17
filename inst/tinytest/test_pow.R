
test_pow <- function() {
  d <- data.frame(x = 2)
  d2 <- extend(d, xsq = x^2)
  expect_equal(data.frame(x = 2, xsq = 4), data.frame(d2))

  invisible(NULL)
}

test_pow()

