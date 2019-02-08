
test_pow <- function() {
  d <- data.frame(x = 2)
  d2 <- extend(d, xsq = x^2)
  testthat::expect_equivalent(data.frame(x = 2, xsq = 4), data.frame(d2))

  invisible(NULL)
}
