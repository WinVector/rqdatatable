
test_colon <- function() {

  d <- data.frame(t = 1:2)
  r <- d %.>% extend(., u = 4:5)
  expect_equal(data.frame(t = 1:2, u = 4:5), r)

  invisible(NULL)
}

test_colon()
