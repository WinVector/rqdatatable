
test_df_types <- function() {
  ops <- mk_td('d', c('a', 'b', 'c')) %.>%
    extend(., y = a / b) %.>%
    order_rows(., 'y')

  # base::data.frame stays base::data.frame
  res1 <- data.frame(a = 1, b = 2, c = 3) %.>% ops
  expect_true(is.data.frame(res1))
  expect_true(!data.table::is.data.table(res1))

  # data.table stays data.table
  res2 <- data.table::data.table(a = 1, b = 2, c = 3) %.>% ops
  expect_true(is.data.frame(res2))
  expect_true(data.table::is.data.table(res2))

  invisible(NULL)
}

test_df_types()
