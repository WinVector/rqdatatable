
test_null_replace_op <- function() {
  dL <- build_frame(
    "x", "y" |
      2L ,  5  |
      NA ,  7  |
      NA , NA )
  rquery_pipeline <- local_td(dL) %.>%
    null_replace(., c("x", "y"), 0, note_col = "nna")
  res <- ex_data_table(rquery_pipeline)


  expect <- wrapr::build_frame(
    "x"  , "y", "nna" |
      2L , 5  , 0     |
      0L , 7  , 1     |
      0L , 0  , 2     )
  expect_true(wrapr::check_equiv_frames(expect, res))

  invisible(NULL)
}

test_null_replace_op()
