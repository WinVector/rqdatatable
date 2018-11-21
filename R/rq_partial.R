
f <- function(d, nd) {
  wrapr::applyto(nd$partial_step, d)
}



#' Wrap a function name and arguments as an rqdatatable stage.
#'
#' @param source incoming relop pipeline.
#' @param fn_name character, name of function.
#' @param ... force later arguments to be taken by name.
#' @param fn_package character, name of package.
#' @param arg_name name for remaining argument.
#' @param args list of function argument values
#' @param columns_produced columns of this node's result.
#' @param env environment to work in.
#' @return wrapped function
#'
#' @seealso \code{\link{applyto}}
#'
#' @export
#'
rq_partial <- function(source, fn_name = NULL,
                       ...,
                       fn_package = "base",
                       arg_name = '', args = list(),
                       columns_produced,
                       env = parent.frame()) {
  force(columns_produced)
  force(env)
  wrapr::stop_if_dot_args(substitute(list(...)), "rq_partial")
  step <- wrapr::wrap_fname_S3(fn_name = fn_name,
                               fn_package = fn_package,
                               arg_name = arg_name,
                               args = args)
  nd <- non_sql_node(source = source,
               f_db = NULL,
               f_df = f,
               f_dt = f,
               incoming_table_name = "fk_name_1",
               outgoing_table_name = "fk_name_2",
               columns_produced = columns_produced,
               display_form = paste0(fn_package, "::", fn_name),
               orig_columns = FALSE,
               temporary = TRUE,
               env = env)
  nd$partial_step <- step
  nd
}
