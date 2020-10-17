
test_mk_dt_l_by_col <- function() {

  df = data.frame(x = c(1, 2, 3, 4),
                  y = c(5, 6, 7, 8),
                  choice = c("x", "y", "x", "z"),
                  stringsAsFactors = FALSE)
  res <- make_dt_lookup_by_column("choice", "derived")(df)
  expect <- wrapr::build_frame(
    "x"  , "y", "choice", "derived" |
      1  , 5  , "x"     , 1         |
      2  , 6  , "y"     , 6         |
      3  , 7  , "x"     , 3         |
      4  , 8  , "z"     , NA_real_  )
  expect_true(wrapr::check_equiv_frames(expect, res))

  df2 <- df
  colnames(df2) <- c(" x ", " y ", " choice ")
  df2[[" choice "]] <- paste0(" ", df2[[" choice "]], " ")
  res2 <- make_dt_lookup_by_column(" choice ", " derived ")(df2)
  expect2 <- wrapr::build_frame(
    " x "  , " y ", " choice ", " derived " |
      1    , 5    , " x "     , 1           |
      2    , 6    , " y "     , 6           |
      3    , 7    , " x "     , 3           |
      4    , 8    , " z "     , NA_real_    )
  expect_true(wrapr::check_equiv_frames(expect2, res2))

  invisible(NULL)
}

test_mk_dt_l_by_col()

