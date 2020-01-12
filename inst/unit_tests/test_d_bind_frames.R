test_d_bind_frames <- function() {
  d <- data.frame(x = 1, y = 's', stringsAsFactors = FALSE)
  frame_list = list(d, d)

  r <- rbindlist_data_table(frame_list)
  RUnit::checkTrue(is.data.frame(r))
  expect <- data.frame(x = c(1, 1), y = c('s', 's'), stringsAsFactors = FALSE)
  RUnit::checkTrue(isTRUE(all.equal(r, expect)))
  RUnit::checkTrue(is.character(r$y))
  RUnit::checkTrue(!is.factor(r$y))

  invisible(NULL)
}
