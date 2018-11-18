library("rqdatatable")

context("pow")

test_that("test_pw: Works As Expected", {
  d <- data.frame(x = 2)
  d2 <- extend(d, xsq = x^2)
  testthat::expect_equivalent(data.frame(x = 2, xsq = 4), data.frame(d2))
})
