
test_join_table_consist <- function() {

  d <- wrapr::build_frame(
    "Sepal.Length", "Sepal.Width", "Petal.Length", "Petal.Width", "Species" |
      5.1           , 3.5          , 1.4           , 0.2          , "setosa"  )

  control_table <- wrapr::qchar_frame(
    Part,  Measure, Value        |
      Sepal, Length,  Sepal.Length |
      Sepal, Width,   Sepal.Width  |
      Petal, Length,  Petal.Length |
      Petal, Width,   Petal.Width  )

  # had been throwing as both tables got same temp-id
  natural_join(control_table, d, by = NULL)

  invisible(NULL)
}

test_join_table_consist()

