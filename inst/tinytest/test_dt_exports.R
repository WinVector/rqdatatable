
test_dt_exports <- function() {

  d0 <- rbindlist_data_table(list(
    data.frame(x = 1, y = 2),
    data.frame(x = c(2, 3), y = c(NA, 4))))

  e0 <- wrapr::build_frame(
    "x"  , "y"      |
      1  , 2        |
      2  , NA_real_ |
      3  , 4        )

  expect_true(wrapr::check_equiv_frames(e0, d0))




  d <- wrapr::build_frame(
    "id"  , "id2", "AUC", "R2" |
      1   , "a"  , 0.7  , 0.4  |
      2   , "b"  , 0.8  , 0.5  )

  d1 <- layout_to_blocks_data_table(
    d,
    nameForNewKeyColumn = "measure",
    nameForNewValueColumn = "value",
    columnsToTakeFrom = c("AUC", "R2"),
    columnsToCopy = c("id", "id2"))

  e1 <- wrapr::build_frame(
    "id"  , "id2", "measure", "value" |
      1   , "a"  , "AUC"    , 0.7     |
      2   , "b"  , "AUC"    , 0.8     |
      1   , "a"  , "R2"     , 0.4     |
      2   , "b"  , "R2"     , 0.5     )

  expect_true(wrapr::check_equiv_frames(e1, d1))




  d2 <- wrapr::build_frame(
    "id"  , "id2", "measure", "value" |
      1   , "a"  , "AUC"    , 0.7     |
      2   , "b"  , "AUC"    , 0.8     |
      1   , "a"  , "R2"     , 0.4     |
      2   , "b"  , "R2"     , 0.5     )

  d3 <- layout_to_rowrecs_data_table(d2,
                                     columnToTakeKeysFrom = "measure",
                                     columnToTakeValuesFrom = "value",
                                     rowKeyColumns = c("id", "id2"))

  e3 <- wrapr::build_frame(
    "id"  , "id2", "AUC", "R2" |
      1   , "a"  , 0.7  , 0.4  |
      2   , "b"  , 0.8  , 0.5  )

  expect_true(wrapr::check_equiv_frames(e3, d3))

  invisible(NULL)
}

test_dt_exports()

