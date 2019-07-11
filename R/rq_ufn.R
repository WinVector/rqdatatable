

#' @importMethodsFrom wrapr ApplyTo
#' @importClassesFrom wrapr UnaryFn UnaryFnList PartialNamedFn PartialFunction
NULL



f_eval_partial_step <- function(d, nd = NULL) {
  wrapr::ApplyTo(nd$partial_step, d)
}


#' @importFrom methods is
NULL


#' Wrap a function name and arguments as an rqdatatable stage.
#'
#' @param source incoming relop pipeline.
#' @param step a wrapr::UnaryFn derived S4 instance.
#' @param ... force later arguments to be taken by name.
#' @param columns_produced columns of this node's result.
#' @param check_result_details logical, if TRUE enforce result type and columns.
#' @param use_data_table logical, if TRUE use data.table code path.
#' @param f_db database implementation signature: f_db(db, incoming_table_name, outgoing_table_name, nd, ...) (db being a database handle, can't be a nested rquery pipeline).
#' @param temp_name_source a wrapr::mk_tmp_name_source().
#' @param env environment to work in.
#' @return wrapped function
#'
#'
#' @export
#'
rq_ufn <- function(source, step,
                   ...,
                   columns_produced = NULL,
                   check_result_details = TRUE,
                   use_data_table = TRUE,
                   f_db = NULL,
                   temp_name_source = wrapr::mk_tmp_name_source(),
                   env = parent.frame()) {
  force(env)
  UseMethod("rq_ufn", source)
}

#' @export
rq_ufn.relop <- function(source, step,
                         ...,
                         columns_produced = NULL,
                         check_result_details = TRUE,
                         use_data_table = TRUE,
                         f_db = function(db, incoming_table_name, outgoing_table_name, nd, ...)  { stop("f_db not defined")},
                         temp_name_source = wrapr::mk_tmp_name_source(),
                         env = parent.frame()) {
  force(columns_produced)
  force(step)
  force(env)
  wrapr::stop_if_dot_args(substitute(list(...)), "rq_ufn.relop")
  if((!isS4(step)) || (!methods::is(step, "UnaryFn"))) {
    stop(paste("rquery::rq_ufn.relop step: ", step, " must be an instance of a class derived from wrapr::UnaryFn"))
  }
  display_form <- format(step)
  incoming_table_name <- temp_name_source()
  outgoing_table_name <- incoming_table_name
  if(!is.null(f_db)) {
    outgoing_table_name <- temp_name_source()
  }
  if(use_data_table) {
    nd <- non_sql_node(source = source,
                       f_db = f_db,
                       f_df = f_eval_partial_step,
                       f_dt = f_eval_partial_step,
                       incoming_table_name = incoming_table_name,
                       outgoing_table_name = outgoing_table_name,
                       columns_produced = columns_produced,
                       display_form = display_form,
                       orig_columns = FALSE,
                       temporary = TRUE,
                       check_result_details = check_result_details,
                       env = env)
  } else {
    nd <- non_sql_node(source = source,
                       f_db = f_db,
                       f_df = f_eval_partial_step,
                       f_dt = NULL,
                       incoming_table_name = incoming_table_name,
                       outgoing_table_name = outgoing_table_name,
                       columns_produced = columns_produced,
                       display_form = display_form,
                       orig_columns = FALSE,
                       temporary = TRUE,
                       check_result_details = check_result_details,
                       env = env)
  }
  nd$partial_step <- step
  nd
}

#' @export
rq_ufn.data.frame <- function(source, step,
                              ...,
                              columns_produced = NULL,
                              check_result_details = TRUE,
                              use_data_table = TRUE,
                              f_db = NULL,
                              temp_name_source = wrapr::mk_tmp_name_source(),
                              env = parent.frame()) {
  force(env)
  wrapr::stop_if_dot_args(substitute(list(...)), "rq_ufn.data.frame")
  tmp_name <- wrapr::mk_tmp_name_source()()
  dnode <- mk_td(tmp_name, colnames(source))
  enode <- rq_ufn(dnode,
                  step = step,
                  columns_produced = columns_produced,
                  check_result_details = check_result_details,
                  use_data_table = use_data_table,
                  f_db = f_db,
                  temp_name_source = temp_name_source,
                  env = env)
  rquery_apply_to_data_frame(source, enode, env = env)
}
