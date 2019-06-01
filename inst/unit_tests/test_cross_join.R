
test_cross_join <- function() {

  x <- data.frame(
    x = c(1, 2)
  )

  y <- data.frame(
    y = c(3, 4)
  )

  final <- natural_join(x, y, by = character(0), jointype = "FULL")

  expect <- wrapr::build_frame(
    "x"  , "y" |
      1  , 3   |
      1  , 4   |
      2  , 3   |
      2  , 4   )
  RUnit::checkTrue(wrapr::check_equiv_frames(expect, final))

  invisible(NULL)
}
