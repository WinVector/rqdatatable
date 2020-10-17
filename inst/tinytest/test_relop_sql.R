

test_relop_sql <- function() {

 # WARNING: example tries to change rquery.rquery_db_executor option to RSQLite and back.
 if (requireNamespace("DBI", quietly = TRUE) &&
     requireNamespace("RSQLite", quietly = TRUE)) {
   # example database connection
   my_db <- DBI::dbConnect(RSQLite::SQLite(),
                           ":memory:")
   old_o <- options(list("rquery.rquery_db_executor" = list(db = my_db)))

   # example data
   d <- data.frame(v1 = c(1, 2, NA, 3),
                   v2 = c(NA, "b", NA, "c"),
                   v3 = c(NA, NA, 7, 8),
                   stringsAsFactors = FALSE)

   # example xform
   vars <- column_names(d)
   # build a NA/NULLs per-row counting expression.
   # names are "quoted" by wrapping them with as.name().
   # constants can be quoted by an additional list wrapping.
   expr <- lapply(vars,
                  function(vi) {
                    list("+ (CASE WHEN (",
                         as.name(vi),
                         "IS NULL ) THEN 1.0 ELSE 0.0 END)")
                  })
   expr <- unlist(expr, recursive = FALSE)
   expr <- c(list(0.0), expr)

   # instantiate the operator node
   op_tree <- local_td(d) %.>%
     sql_node(., "num_missing" %:=% list(expr))
   cat(format(op_tree))

   ex_data_table(op_tree, tables = list(d = d)) %.>%
     print(.)
   # d %.>% op_tree

   options(old_o)
   DBI::dbDisconnect(my_db)
 }

  invisible(NULL)
}

test_relop_sql()

