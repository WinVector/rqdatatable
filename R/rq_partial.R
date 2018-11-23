

#' @importFrom wrapr ApplyTo
#' @importClassesFrom wrapr UnaryFn UnaryFnList PartialNamedFn PartialFunction
NULL

f_eval_partial_step <- function(d, nd) {
  wrapr::ApplyTo(nd$partial_step, d)
}



#' Wrap a function name and arguments as an rqdatatable stage.
#'
#' @param source incoming relop pipeline.
#' @param step a wrapr::UnaryFn derived S4 instance.
#' @param ... force later arguments to be taken by name.
#' @param columns_produced columns of this node's result.
#' @param check_result_details logical, if TRUE enforce result type and columns.
#' @param env environment to work in.
#' @return wrapped function
#'
#'
#' @export
#'
rq_partial <- function(source, step,
                       ...,
                       columns_produced = NULL,
                       check_result_details = TRUE,
                       env = parent.frame()) {
  force(env)
  UseMethod("rq_partial", source)
}

#' @export
rq_partial.relop <- function(source, step,
                             ...,
                             columns_produced = NULL,
                             check_result_details = TRUE,
                             env = parent.frame()) {
  force(columns_produced)
  force(step)
  force(env)
  wrapr::stop_if_dot_args(substitute(list(...)), "rq_partial.relop")
  display_form <- format(step)
  nd <- non_sql_node(source = source,
                     f_db = NULL,
                     f_df = f_eval_partial_step,
                     f_dt = NULL,
                     incoming_table_name = "fk_name_1",
                     outgoing_table_name = "fk_name_1",
                     columns_produced = columns_produced,
                     display_form = display_form,
                     orig_columns = FALSE,
                     temporary = TRUE,
                     check_result_details = check_result_details,
                     env = env)
  nd$partial_step <- step
  nd
}

#' @export
rq_partial.data.frame <- function(source, step,
                                  ...,
                                  columns_produced = NULL,
                                  check_result_details = TRUE,
                                  env = parent.frame()) {
  force(env)
  wrapr::stop_if_dot_args(substitute(list(...)), "rq_partial.data.frame")
  tmp_name <- wrapr::mk_tmp_name_source()()
  dnode <- mk_td(tmp_name, colnames(source))
  enode <- rq_partial(dnode,
                      step = step,
                      columns_produced = columns_produced,
                      check_result_details = check_result_details,
                      env = env)
  rquery_apply_to_data_frame(source, enode, env = env)
}
