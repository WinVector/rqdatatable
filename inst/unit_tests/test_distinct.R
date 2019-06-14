
test_distict <- function() {
  d <- data.frame(a = c(1, 1, 1, 2, 2, 2),
                  b = c(1, 2, 1, 2, 1, 2),
                  c = c(1, 1, 1, 2, 2, 2))
  r <- project(d, groupby = c("a", "b", "c"))
  RUnit::checkEquals(nrow(r), 4)

  invisible(NULL)
}
