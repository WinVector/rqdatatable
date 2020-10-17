
test_set_ind_op <- function() {
  d <- data.frame(a = c("1", "2", "1", "3"),
                  b = c("1", "1", "3", "2"),
                  q = 1,
                  stringsAsFactors = FALSE)
  set <- c("1", "2")
  op_tree <- local_td(d) %.>%
    set_indicator(., "one_two", "a", set) %.>%
    set_indicator(., "z", "a", c())
  res <- ex_data_table(op_tree)

  expect <- wrapr::build_frame(
    "a"  , "b", "q", "one_two", "z" |
      "1", "1", 1  , 1        , 0   |
      "2", "1", 1  , 1        , 0   |
      "1", "3", 1  , 1        , 0   |
      "3", "2", 1  , 0        , 0   )
  expect_true(wrapr::check_equiv_frames(expect, res))

  invisible(NULL)
}

test_set_ind_op()

