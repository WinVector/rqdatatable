
test_grouped_running <- function() {

  data <- wrapr::build_frame(
      "x", "y" |
      1  , 1   |
      0  , 0   |
      1  , 0   |
      0  , 1   |
      0  , 0   |
      1  , 1   )

  res <- extend_nse(data,
                 running_y_sum = cumsum(y),
                 partitionby = "x",
                 orderby = "y",
                 reverse = "y")

  res <- orderby(res, c("x", "y"), reverse = c("x", "y"))

  res <- data.frame(res)

  expect <- wrapr::build_frame(
      "x", "y", "running_y_sum" |
      1  , 1  , 1               |
      1  , 1  , 2               |
      1  , 0  , 2               |
      0  , 1  , 1               |
      0  , 0  , 1               |
      0  , 0  , 1               )

  expect_equal(res, expect)

  invisible(NULL)
}

test_grouped_running()

