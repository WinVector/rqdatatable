

mk_f_db_default <- function(f, cols) {
  function(db, incoming_table_name, outgoing_table_name, nd = NULL, ...) {
    colsq <- vapply(cols,
                    function(ci) {
                      rquery::quote_identifier(db, ci)
                    }, character(1))
    colstr <- paste(colsq, collapse = ", ")
    q <- paste0("SELECT ", colstr, " FROM ", rquery::quote_identifier(db, incoming_table_name))
    d <- rquery::rq_get_query(db, q)
    if(length(formals(f))>=2) {
      res <- f(d, nd)
    } else {
      # legacy signature
      res <- f(d)
    }
    rquery::rq_copy_to(db, outgoing_table_name, res)
  }
}

#' Helper to build data.table capable non-sql nodes.
#'
#' @param . or data.frame input.
#' @param f function that takes a data.table to a data.frame (or data.table).
#' @param ... force later arguments to bind by name.
#' @param f_db implementation signature: f_db(db, incoming_table_name, outgoing_table_name, nd, ...) (db being a database handle). NULL defaults to using f.
#' @param columns_produced character columns produces by f.
#' @param display_form display form for node.
#' @param orig_columns orig_columns, if TRUE assume all input columns are present in derived table.
#' @return relop non-sql node implementation.
#'
#' @seealso \code{\link[rqdatatable]{ex_data_table_step.relop_non_sql}}, \code{\link{rq_df_grouped_funciton_node}}
#'
#'
#' @examples
#'
#' # a node generator is something an expert can
#' # write and part-time R users can use.
#' grouped_regression_node <- function(., group_col = "group", xvar = "x", yvar = "y") {
#'   force(group_col)
#'   formula_str <- paste(yvar, "~", xvar)
#'   f <- function(df, nd = NULL) {
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
#'   rq_df_funciton_node(
#'     ., f,
#'     columns_produced = columns_produced,
#'     display_form = paste0(yvar, "~", xvar, " grouped by ", group_col))
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
#' d %.>% rquery_pipeline
#'
#' @export
#'
rq_df_funciton_node <- function(., f,
                                ...,
                                f_db = NULL,
                                columns_produced,
                                display_form,
                                orig_columns = FALSE) {
  wrapr::stop_if_dot_args(substitute(list(...)), "rqdatatable::rq_df_funciton_node")
  cols <- column_names(.)
  if(orig_columns) {
    missing <- setdiff(columns_produced, cols)
    columns_produced <- c(columns_produced, missing)
  }
  if(is.null(f_db)) {
    f_db <- mk_f_db_default(f, cols)
  }
  non_sql_node(.,
               f_db = f_db,
               f_df = f,
               f_dt = NULL,
               incoming_table_name = "incoming_table_name",
               outgoing_table_name = "outgoing_table_name",
               columns_produced = columns_produced,
               display_form = display_form,
               orig_columns = orig_columns)
}





#' Helper to build data.table capable non-sql nodes.
#'
#' @param . or data.frame input.
#' @param f function that takes a data.table to a data.frame (or data.table).
#' @param ... force later arguments to bind by name.
#' @param f_db implementation signature: f_db(db, incoming_table_name, outgoing_table_name) (db being a database handle). NULL defaults to using f.
#' @param columns_produced character columns produces by f.
#' @param group_col character, column to split by.
#' @param display_form display form for node.
#' @return relop non-sql node implementation.
#'
#' @seealso \code{\link[rqdatatable]{ex_data_table_step.relop_non_sql}}, \code{\link{rq_df_funciton_node}}
#'
#'
#' @examples
#'
#' # a node generator is something an expert can
#' # write and part-time R users can use.
#' grouped_regression_node <- function(., group_col = "group", xvar = "x", yvar = "y") {
#'   force(group_col)
#'   formula_str <- paste(yvar, "~", xvar)
#'   f <- function(di) {
#'     mi <- lm(as.formula(formula_str), data = di)
#'     ci <- as.data.frame(summary(mi)$coefficients)
#'     ci$Variable <- rownames(ci)
#'     rownames(ci) <- NULL
#'     colnames(ci) <- c("Estimate", "Std_Error", "t_value", "p_value", "Variable")
#'     ci
#'   }
#'   columns_produced =
#'     c("Estimate", "Std_Error", "t_value", "p_value", "Variable", group_col)
#'   rq_df_grouped_funciton_node(
#'     ., f,
#'     columns_produced = columns_produced,
#'     group_col = group_col,
#'     display_form = paste0(yvar, "~", xvar, " grouped by ", group_col))
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
#' d %.>% rquery_pipeline
#'
#'
#' @export
#'
rq_df_grouped_funciton_node <- function(., f,
                                        ...,
                                        f_db = NULL,
                                        columns_produced,
                                        group_col,
                                        display_form) {
  wrapr::stop_if_dot_args(substitute(list(...)), "rqdatatable::rq_df_grouped_funciton_node")
  cols <- column_names(.)
  if(!(group_col %in% cols)) {
    stop("rq_df_grouped_funciton_node grouping column must be in input")
  }
  if(!(group_col %in% columns_produced)) {
    columns_produced <- c(columns_produced, group_col)
  }
  force(group_col)
  fg <- function(df, nd = NULL) {
    dlist <- split(df, df[[group_col]])
    clist <- lapply(dlist,
                    function(di) {
                      gi <- NULL
                      if(nrow(di)>0) {
                        gi <- di[[group_col]][[1]]
                      }
                      di <- f(di)
                      if(!is.null(gi)) {
                        di[[group_col]] <- gi
                      }
                      di
                    })
    data.table::rbindlist(clist)
  }
  if(is.null(f_db)) {
    f_db <- mk_f_db_default(fg, cols)
  }
  non_sql_node(.,
               f_db = f_db,
               f_df = fg,
               f_dt = NULL,
               incoming_table_name = "incoming_table_name",
               outgoing_table_name = "outgoing_table_name",
               columns_produced = columns_produced,
               display_form = paste(display_form, "grouped by", group_col),
               orig_columns = FALSE)
}


#' Direct non-sql (function) node, not implemented for \code{data.table} case.
#'
#' Passes a single table to a function that takes a single data.frame as its argument, and returns a single data.frame.
#'
#'
#'
#' @seealso \code{\link{rq_df_funciton_node}}, \code{\link{rq_df_grouped_funciton_node}}
#'
#' @examples
#'
#' set.seed(3252)
#' d <- data.frame(a = rnorm(1000), b = rnorm(1000))
#'
#' optree <- local_td(d) %.>%
#'   quantile_node(.)
#' d %.>% optree
#'
#' p2 <- local_td(d) %.>%
#'   rsummary_node(.)
#' d %.>% p2
#'
#' summary(d)
#'
#' @inheritParams ex_data_table_step
#' @export
ex_data_table_step.relop_non_sql <- function(optree,
                                        ...,
                                        tables = list(),
                                        source_usage = NULL,
                                        source_limit = NULL,
                                        env = parent.frame()) {
  force(env)
  wrapr::stop_if_dot_args(substitute(list(...)), "rqdatatable::ex_data_table_step.relop_non_sql")
  if(is.null(source_usage)) {
    source_usage <- columns_used(optree)
  }
  x <- ex_data_table_step(optree$source[[1]],
                     tables = tables,
                     source_limit = source_limit,
                     source_usage = source_usage,
                     env = env)
  if(isTRUE(optree$check_result_details)) {
    if(!is.data.frame(x)) {
      stop("rqdatatable::ex_data_table_step.relop_non_sql sub-expression eval was not a data.frame")
    }
  }
  res <- NULL
  f_df <- optree$f_df
  if(is.data.frame(x)) {
    f_dt <- optree$f_dt
    if(!is.null(f_dt)) {
      # data table specialized impl
      if(!data.table::is.data.table(x)) {
        x <- data.table::as.data.table(x)
      }
      if(length(formals(f_dt))>=2) {
        res <- f_dt(x, optree)
      } else {
        # legacy signature
        res <- f_dt(x)
      }
    } else {
      # data.frame impl
      if(is.null(f_df)) {
        stop("rqdatatable::ex_data_table_step.relop_non_sql df is NULL")
      }
      x <- data.frame(x)
      if(length(formals(f_df))>=2) {
        res <- f_df(x, optree)
      } else {
        # legacy signature
        res <- f_df(x)
      }
    }
  } else {
    if(is.null(f_df)) {
      stop("rqdatatable::ex_data_table_step.relop_non_sql df is NULL")
    }
    if(length(formals(f_df))>=2) {
      res <- f_df(x, optree)
    } else {
      # legacy signature
      res <- f_df(x)
    }
  }
  if(!data.table::is.data.table(res)) {
    res <- data.table::as.data.table(res)
  }
  if(isTRUE(optree$check_result_details)) {
    missing_columns <- setdiff(column_names(optree), colnames(res))
    if(length(missing_columns)>0) {
      stop(paste("qdataframe::ex_data_table_step.relop_non_sql columns produced did not meet declared column specification",
                 paste(missing_columns, collapse = ", ")))
    }
  }
  res
}


