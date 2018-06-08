

#' Direct non-sql (function) node, not implented for \code{data.table} case.
#'
#' Passes a single table to a function that takes a single data.frame as its arguement, and returns a single data.frame.
#'
#' @examples
#'
#' # a node generator is something an expert can
#' # write and part-time R users can use.
#' grouped_regression_node <- function(., group_col = "group", xvar = "x", yvar = "y") {
#'   force(group_col)
#'   formula_str <- paste(yvar, "~", xvar)
#'   f <- function(df) {
#'     dlist <- split(df, df[[group_col]])
#'     clist <- lapply(dlist,
#'                     function(di) {
#'                       mi <- lm(as.formula(formula_str), data = di)
#'                       ci <- as.data.frame(summary(mi)$coefficients)
#'                       ci$Variable <- rownames(ci)
#'                       rownames(ci) <- NULL
#'                       ci[[group_col]] <- di[[group_col]][[1]]
#'                       ci
#'                     })
#'     data.table::rbindlist(clist)
#'   }
#'   columns_produced =
#'      c("Variable", "Estimate", "Std. Error", "t value", "Pr(>|t|)", group_col)
#'   non_sql_node(.,
#'                f_db = function(...) { stop("db function not implemented")},
#'                f_df = f,
#'                incoming_table_name = "incoming_table_name",
#'                outgoing_table_name = "outgoing_table_name",
#'                columns_produced = columns_produced,
#'                display_form = paste0(yvar, "~", xvar, " grouped by ", group_col),
#'                orig_columns = FALSE)
#' }
#'
#' # work an example
#' set.seed(3265)
#' d <- data.frame(x = rnorm(1000),
#'                 y = rnorm(1000),
#'                 group = sample(letters[1:5], 1000, replace = TRUE),
#'                 stringsAsFactors = FALSE)
#'
#' rquery_pipeline <- local_td(d) %.>%
#'   grouped_regression_node(.)
#'
#' cat(format(rquery_pipeline))
#'
#' ex_data_table(rquery_pipeline)[]
#'
#' @inheritParams ex_data_table
#' @export
ex_data_table.relop_non_sql <- function(optree,
                                        ...,
                                        tables = list(),
                                        source_usage = NULL,
                                        source_limit = NULL,
                                        env = parent.frame()) {
  wrapr::stop_if_dot_args(substitute(list(...)), "rqdataframe::ex_data_table.relop_non_sql")
  if(is.null(source_usage)) {
    source_usage <- columns_used(optree)
  }
  x <- ex_data_table(optree$source[[1]],
                     tables = tables,
                     source_limit = source_limit,
                     source_usage = source_usage,
                     env = env)
  f_df <- optree$f_df
  if(is.null(f_df)) {
    stop("rqdataframe::ex_data_table.relop_non_sql df is NULL")
  }
  res <- f_df(x)
  if(!is.data.frame(res)) {
    stop("qdataframe::ex_data_table.relop_non_sql f_df did not return a data.frame")
  }
  if(!data.table::is.data.table(res)) {
    res <- data.table::as.data.table(res)
  }
  if(!isTRUE(all.equal(sort(colnames(res)), sort(optree$columns_produced)))) {
    stop("qdataframe::ex_data_table.relop_non_sql columns produced did not match specification")
  }
  res
}


