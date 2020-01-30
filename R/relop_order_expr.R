
#' Order rows by expression.
#'
#' \code{data.table} based implementation.
#'
#' @inheritParams ex_data_table_step
#'
#' @examples
#'
#' dL <- build_frame(
#'     "x", "y" |
#'     2L , "b" |
#'    -4L , "a" |
#'     3L , "c" )
#' rquery_pipeline <- local_td(dL) %.>%
#'   order_expr(., abs(x))
#' dL %.>% rquery_pipeline
#'
#' @export
ex_data_table_step.relop_order_expr <- function(optree,
                                           ...,
                                           tables = list(),
                                           source_usage = NULL,
                                           source_limit = NULL,
                                           env = parent.frame()) {
  force(env)
  wrapr::stop_if_dot_args(substitute(list(...)), "rqdatatable::ex_data_table_step.relop_order_expr")
  if(is.null(source_usage)) {
    source_usage <- columns_used(optree)
  }
  x <- ex_data_table_step(optree$source[[1]],
                     tables = tables,
                     source_usage = source_usage,
                     source_limit = source_limit,
                     env = env)
  tmpnam <- ".rquery_ex_order_expr_tmp"
  src <- vapply(seq_len(length(optree$parsed)),
                function(i) {
                  paste("(", optree$parsed[[i]]$presentation, ")")
                }, character(1))
  lsrc <- remap_parsed_exprs_for_data_table(src)
  src <- paste0(tmpnam, "[, .rquery_ex_order_expr_tmp_col := ", lsrc$eexprs, " ]")
  expr <- parse(text = src)
  tmpenv <- patch_global_child_env(env)
  assign(tmpnam, x, envir = tmpenv)
  x <- eval(expr, envir = tmpenv, enclos = tmpenv)
  x <- order_table(x, ".rquery_ex_order_expr_tmp_col", NULL)
  x$.rquery_ex_order_expr_tmp_col <- NULL
  if(!is.null(optree$limit)) {
    n <- nrow(x)
    if(optree$limit < n) {
      x <- x[seq_len(optree$limit), , drop = FALSE]
    }
  }
  x
}

