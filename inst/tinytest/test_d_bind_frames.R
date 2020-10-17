
test_d_bind_frames <- function() {
  d <- data.frame(x = 1, y = 's', stringsAsFactors = FALSE)
  frame_list = list(d, d)

  r <- rbindlist_data_table(frame_list)
  expect_true(is.data.frame(r))
  expect <- data.frame(x = c(1, 1), y = c('s', 's'), stringsAsFactors = FALSE)
  expect_true(isTRUE(all.equal(r, expect)))
  expect_true(is.character(r$y))
  expect_true(!is.factor(r$y))

  invisible(NULL)
}

test_d_bind_frames()
