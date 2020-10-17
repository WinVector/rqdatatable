

test_dtmsg <- function() {
  d <- data.frame(
    'g' = c(1, 2, 2, 3, 3, 3),
    'x' = c(1, 4, 5, 7, 8, 9),
    'v' = c(10, 40, 50, 70, 80, 90)
  )

  table_description <- local_td(d)

  d['irrelevant_column'] <- 1

  id_ops_a = table_description %.>%
    project(., groupby='g') %.>%
    extend(.,
           ngroup %:=% row_number())

  d %.>% id_ops_a
  invisible(NULL)
}

test_dtmsg()
