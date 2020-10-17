
test_space_merge <- function() {
  # from: https://community.rstudio.com/t/merging-2-dataframes-and-replacing-na-values/32123/4

  x <- data.frame(
    ID = c(1, 2, 3),
    S1 = c(1, NA, NA),
    S2 = c(2, 2, 2)
  )
  colnames(x) <- c("ID", " S1 ", "S2")

  y <- data.frame(
    ID = c(1, 2, 3, 4),
    S1 = c(1, 1, 1, 1),
    S3 = c(3, 3, 3, 3)
  )
  colnames(y) <- c("ID", " S1 ", "S3")

  final <- natural_join(x, y, by = "ID", jointype = "FULL")

  expect <- wrapr::build_frame(
    "ID"  , " S1 ", "S2"    , "S3" |
      1   , 1     , 2       , 3    |
      2   , 1     , 2       , 3    |
      3   , 1     , 2       , 3    |
      4   , 1     , NA_real_, 3    )
  expect_true(wrapr::check_equiv_frames(expect, final))

  invisible(NULL)
}

test_space_merge()
