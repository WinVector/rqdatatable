

# https://github.com/WinVector/pyvtreat/blob/master/Examples/StratifiedCrossPlan/StratifiedCrossPlan.ipynb


test_project_example <- function() {

  prepared_stratified <- data.frame(
    'y' = c(1, 0, 0, 1, 0, 0),
    'g' = c(0, 0, 0, 1, 1, 1),
    'x' = c(1, 2, 3, 4, 5, 6)
  )

  ops <- local_td(prepared_stratified) %.>%
    project(.,
      sum %:=% sum(y),
      mean %:=% mean(y),
      size %:=% n(),
    groupby='g')

  res <- prepared_stratified %.>% ops
  res <- as.data.frame(res)

  expect = data.frame(
    g = c(0, 1),
    sum = c(1, 1),
    mean = c(0.3333333333333333, 0.3333333333333333),
    size = c(3, 3)
  )

  RUnit::checkEquals(res, expect)

  invisible(NULL)
}
