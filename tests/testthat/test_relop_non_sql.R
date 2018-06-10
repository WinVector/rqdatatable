

library("rqdatatable")
context("relop_non_sql")

test_that("relop_non_sql works as expected", {


 # a node generator is something an expert can
 # write and part-time R users can use.
 grouped_regression_node <- function(., group_col = "group", xvar = "x", yvar = "y") {
   force(group_col)
   formula_str <- paste(yvar, "~", xvar)
   f <- function(df) {
     dlist <- split(df, df[[group_col]])
     clist <- lapply(dlist,
                     function(di) {
                       mi <- lm(as.formula(formula_str), data = di)
                       ci <- as.data.frame(summary(mi)$coefficients)
                       ci$Variable <- rownames(ci)
                       rownames(ci) <- NULL
                       ci[[group_col]] <- di[[group_col]][[1]]
                       ci
                     })
     data.table::rbindlist(clist)
   }
   columns_produced =
      c("Variable", "Estimate", "Std. Error", "t value", "Pr(>|t|)", group_col)
   rq_df_funciton_node(
     ., f,
     columns_produced = columns_produced,
     display_form = paste0(yvar, "~", xvar, " grouped by ", group_col))
 }

 # work an example
 set.seed(3265)
 d <- data.frame(x = rnorm(1000),
                 y = rnorm(1000),
                 group = sample(letters[1:5], 1000, replace = TRUE),
                 stringsAsFactors = FALSE)

 rquery_pipeline <- local_td(d) %.>%
   grouped_regression_node(.)

 cat(format(rquery_pipeline))

 ex_data_table(rquery_pipeline)[]



 # a node generator is something an expert can
 # write and part-time R users can use.
 grouped_regression_node <- function(., group_col = "group", xvar = "x", yvar = "y") {
   force(group_col)
   formula_str <- paste(yvar, "~", xvar)
   f <- function(di) {
     mi <- lm(as.formula(formula_str), data = di)
     ci <- as.data.frame(summary(mi)$coefficients)
     ci$Variable <- rownames(ci)
     rownames(ci) <- NULL
     colnames(ci) <- c("Estimate", "Std_Error", "t_value", "p_value", "Variable")
     ci
   }
   columns_produced =
     c("Estimate", "Std_Error", "t_value", "p_value", "Variable", group_col)
   rq_df_grouped_funciton_node(
     ., f,
     columns_produced = columns_produced,
     group_col = group_col,
     display_form = paste0(yvar, "~", xvar, " grouped by ", group_col))
 }

 # work an example
 set.seed(3265)
 d <- data.frame(x = rnorm(1000),
                 y = rnorm(1000),
                 group = sample(letters[1:5], 1000, replace = TRUE),
                 stringsAsFactors = FALSE)

 rquery_pipeline <- local_td(d) %.>%
   grouped_regression_node(.)

 cat(format(rquery_pipeline))

 ex_data_table(rquery_pipeline)[]

 if (requireNamespace("DBI", quietly = TRUE) &&
     requireNamespace("RSQLite", quietly = TRUE)) {
   # example database connection
   my_db <- DBI::dbConnect(RSQLite::SQLite(),
                           ":memory:")

   rquery::to_sql(rquery_pipeline, my_db) %.>%
     print(.)

   dR <- rquery::rq_copy_to(my_db,
                            d = d,
                            table_name = "d",
                            overwrite = TRUE,
                            temporary = TRUE)
   tbl <- rquery::materialize(my_db, rquery_pipeline,
                              overwrite = FALSE,
                              temporary = TRUE)
   DBI::dbReadTable(my_db, tbl$table_name) %.>%
     print(.)

   DBI::dbDisconnect(my_db)
 }



 set.seed(3252)
 d <- data.frame(a = rnorm(1000), b = rnorm(1000))

 optree <- local_td(d) %.>%
   quantile_node(.)
 ex_data_table(optree)

 p2 <- local_td(d) %.>%
   rsummary_node(.)
 res <- ex_data_table(p2)
 expect_true(data.table::is.data.table(res))

})
