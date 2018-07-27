library("rqdatatable")

context("select narrowing")

test_that("test_select_narrowing.R: Works As Expected", {
  x <- data.frame(a = 1:3, b = 4:6, c = 7:9)
  op1 <- local_td(x) %.>% extend_nse(., e %:=% a + 1)
  cn1 <- sort(colnames((x %.>% op1)[]))
  op2 <- op1 %.>% select_columns(., "e")
  cn2 <- sort(colnames((x %.>% op2)[]))
  testthat::expect_equal(cn1, c("a", "b", "c", "e"))
  testthat::expect_equal(cn2, c("e"))
})
