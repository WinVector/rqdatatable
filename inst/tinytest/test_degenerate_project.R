
test_good_project <- function() {
  d <- data.frame(x = 1:4,
                  y = c('a', 'a', 'b', 'b'),
                  stringsAsFactors = FALSE)
  ops <- project(local_td(d), x2 := max(x))
  d %.>% ops
  invisible(NULL)
}

test_good_project()



test_degenerate_project <- function() {
  d <- data.frame(x = 1:4,
                  y = c('a', 'a', 'b', 'b'),
                  stringsAsFactors = FALSE)
  expect_error({
    ops <- project(local_td(d), x2 := x)  # rquery may thow here
    d %.>% ops
  })
  invisible(NULL)
}

test_degenerate_project()



test_project_calc <- function() {
  d <- data.frame(x = 1:4,
                  y = c('a', 'a', 'b', 'b'),
                  stringsAsFactors = FALSE)
  ops <- project(local_td(d), x2 := max(x) + max(x))
  d %.>% ops
  invisible(NULL)
}

test_project_calc()

