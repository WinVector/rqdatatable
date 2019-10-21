
#' @importFrom rquery extend
#' @export
#' @keywords internal
#'
extend.wrapped_relop <- function(source,
                                 ...,
                                 partitionby = NULL,
                                 orderby = NULL,
                                 reverse = NULL,
                                 display_form = NULL,
                                 env = parent.frame()) {
  force(env)
  underlying = extend(source$underlying,
                      ...,
                      partitionby = partitionby,
                      orderby = orderby,
                      reverse = reverse,
                      display_form = display_form,
                      env = env)
  res <- list(underlying = underlying,
              data_map = source$data_map)
  class(res) <- 'wrapped_relop'
  return(res)
}

#' @importFrom rquery extend_se
#' @export
#' @keywords internal
#'
extend_se.wrapped_relop <- function(source, assignments,
                                    ...,
                                    partitionby = NULL,
                                    orderby = NULL,
                                    reverse = NULL,
                                    display_form = NULL,
                                    env = parent.frame()) {
  force(env)
  wrapr::stop_if_dot_args(substitute(list(...)),
                          "rquery::extend_se.wrapped_relop")
  underlying = extend_se(source, assignments,
                         partitionby = partitionby,
                         orderby = orderby,
                         reverse = reverse,
                         display_form = display_form,
                         env = env)
  res <- list(underlying = underlying,
              data_map = source$data_map)
  class(res) <- 'wrapped_relop'
  return(res)
}

#' Wrap a data frame for later execution.
#'
#' Create a table description that includes the actual data.  Prevents wastefull table copies in
#' immediate pipelines.  Used with \code{ex()}.
#'
#' @param d data.frame
#' @param ... not used, force later argument to be referred by name
#' @param name character, name of table
#' @param env environment to work in.
#' @return a table description, with data attached
#'
#' @examples
#'
#'  d <- data.frame(x = 1:3, y = 4:6)
#'  d %.>%
#'    wrap(.) %.>%
#'    extend(., z := x + y) %.>%
#'    ex(.)
#'
#' @export
#'
wrap <- function(d,
                 ...,
                 name = NULL,
                 env = parent.frame()) {
  wrapr::stop_if_dot_args(substitute(list(...)), "rqdatatable::wrap")
  force(env)
  table_name <- as.character(substitute(d))
  if(length(table_name)!=1) {
    table_name <- 'd'
  }
  underlying <- local_td(d, name = name, env = env)
  data_map = list(d)
  names(data_map) = table_name
  res <- list(underlying = underlying,
              data_map = data_map)
  class(res) <- 'wrapped_relop'
  return(res)
}


#' Execute a wrapped execution pipeline.
#'
#' Execute a ops-dag using `code{wrap()}` data as values.
#'
#' @param ops rquery pipeline with tables formed by `wrap()`.
#' @param ... not used, force later argument to be referred by name
#' @param env environment to work in.
#' @return data.frame result
#'
#' @examples
#'
#'  d <- data.frame(x = 1:3, y = 4:6)
#'  d %.>%
#'    wrap(.) %.>%
#'    extend(., z := x + y) %.>%
#'    ex(.)
#'
#' @export
#'
ex <- function(ops,
               ...,
               env = parent.frame()) {
  wrapr::stop_if_dot_args(substitute(list(...)), "rqdatatable::ex")
  if(!('wrapped_relop' %in% class(ops))) {
    stop("rqdatatable::ex expected ops to be of class wrapped_relop")
  }
  force(env)
  tables <- ops$data_map
  ex_data_table(ops$underlying, tables = tables, env=env)
}

# TODO: wrap other common relop pipe stages




