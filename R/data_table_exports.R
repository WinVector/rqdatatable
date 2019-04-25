
# allow derived packages to use some data.table methods without declaring
# themselves data.table packages (and thus picking up different semantics)

#' rbindlist
#'
#' Note: different argument defaults than data.table::rbindlist.
#'
#' @param l list of data.frames to rbind.
#' @param use.names passed to data.table
#' @param fill passed to data.table
#' @param idcol passed to data.table
#' @return data.table
#'
#' @export
#' @keywords internal
#'
#' @examples
#'
#' rbindlist_data_table(list(
#'   data.frame(x = 1, y = 2),
#'   data.frame(x = c(2, 3), y = c(NA, 4))))
#'
rbindlist_data_table <- function(l,
                                 use.names = TRUE,
                                 fill = TRUE,
                                 idcol = NULL) {
  res <- data.table::rbindlist(l,
                               use.names = use.names,
                               fill = fill,
                               idcol = idcol)
  res <- data.frame(res)
  rownames(res) <- NULL
  res
}


#' Map a data records from row records to block records with one record row per columnsToTakeFrom value.
#'
#' Map a data records from row records (records that are exactly single rows) to block records
#' (records that may be more than one row).  All columns not named in columnsToTakeFrom are copied to each
#' record row in the result.
#'
#'
#' @param data data.frame to work with.
#' @param nameForNewKeyColumn character name of column to write new keys in.
#' @param nameForNewValueColumn character name of column to write new values in.
#' @param columnsToTakeFrom character array names of columns to take values from.
#' @param ... force later arguments to bind by name.
#' @param columnsToCopy character array names of columns to copy.
#' @return new data.frame with values moved to rows.
#'
#' @export
#' @keywords internal
#'
#' @examples
#'
#' (d <- wrapr::build_frame(
#'   "id"  , "id2", "AUC", "R2" |
#'     1   , "a"  , 0.7  , 0.4  |
#'     2   , "b"  , 0.8  , 0.5  ))
#'
#' (layout_to_blocks_data_table(
#'   d,
#'   nameForNewKeyColumn = "measure",
#'   nameForNewValueColumn = "value",
#'   columnsToTakeFrom = c("AUC", "R2"),
#'   columnsToCopy = c("id", "id2")))
#'
#'
layout_to_blocks_data_table <- function(data,
                                        ...,
                                        nameForNewKeyColumn,
                                        nameForNewValueColumn,
                                        columnsToTakeFrom,
                                        columnsToCopy = setdiff(colnames(data), columnsToTakeFrom)) {
  wrapr::stop_if_dot_args(substitute(list(...)), "rqdatatable::layout_to_blocks_data_table")
  if(!is.data.frame(data)) {
    stop("rqdatatable::layout_to_blocks_data_table data must be a data.frame")
  }
  if(!data.table::is.data.table(data)) {
    data <- as.data.table(data)
  }
  res <- data.table::melt.data.table(
    data = data,
    id.vars = columnsToCopy,
    variable.name = nameForNewKeyColumn,
    value.name = nameForNewValueColumn,
    variable.factor = FALSE)
  res <- data.frame(res)
  rownames(res) <- NULL
  res
}

#' Map data records from block records that have one row per measurement value to row records.
#'
#' Map data records from block records (where each record may be more than one row) to
#' row records (where each record is a single row).  Values specified in rowKeyColumns
#' determine which sets of rows build up records and are copied into the result.
#'
#'
#' @param data data.frame to work with (must be local, for remote please try \code{moveValuesToColumns*}).
#' @param columnToTakeKeysFrom character name of column build new column names from.
#' @param columnToTakeValuesFrom character name of column to get values from.
#' @param rowKeyColumns character array names columns that should be table keys.
#' @param ... force later arguments to bind by name.
#' @param sep character if not null build more detailed column names.
#' @return new data.frame with values moved to columns.
#'
#'
#' @export
#' @keywords internal
#'
#' @examples
#'
#' (d2 <- wrapr::build_frame(
#'   "id"  , "id2", "measure", "value" |
#'     1   , "a"  , "AUC"    , 0.7     |
#'     2   , "b"  , "AUC"    , 0.8     |
#'     1   , "a"  , "R2"     , 0.4     |
#'     2   , "b"  , "R2"     , 0.5     ))
#'
#' (layout_to_rowrecs_data_table(d2,
#'                              columnToTakeKeysFrom = "measure",
#'                              columnToTakeValuesFrom = "value",
#'                              rowKeyColumns = c("id", "id2")))
#'
layout_to_rowrecs_data_table <- function(data,
                                         ...,
                                         columnToTakeKeysFrom,
                                         columnToTakeValuesFrom,
                                         rowKeyColumns,
                                         sep = "_") {
  wrapr::stop_if_dot_args(substitute(list(...)), "rqdatatable::layout_to_rowrecs_data_table")
  if(!is.data.frame(data)) {
    stop("rqdatatable::layout_to_rowrecs_data_table data must be a data.frame")
  }
  if(!data.table::is.data.table(data)) {
    data <- as.data.table(data)
  }
  f <- stats::as.formula(paste(paste(rowKeyColumns, collapse = " + "), "~", columnToTakeKeysFrom))
  res <- data.table::dcast.data.table(
    data = data,
    formula = f,
    fun.aggregate = mean,
    fill = NA,
    value.var = columnToTakeValuesFrom,
    sep = sep)
  res <- data.frame(res)
  rownames(res) <- NULL
  res
}



