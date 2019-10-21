

# Common ops.
# "extend",
# "project",
# "natural_join",
# "select_rows",
# "drop_columns",
# "select_columns",
# "rename_columns",
# "order_rows",
# "convert_records", # may not be able to wrapr the rquery equivlent here, but must do it in cdata


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
                          "rqdatatable::extend_se.wrapped_relop")
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



#' @importFrom rquery project
#' @export
#' @keywords internal
#'
project.wrapped_relop <- function(source,
                                  ...,
                                  groupby = c(),
                                  env = parent.frame()) {
  force(env)
  underlying = project(source$underlying,
                       ...,
                       groupby = groupby,
                       env = env)
  res <- list(underlying = underlying,
              data_map = source$data_map)
  class(res) <- 'wrapped_relop'
  return(res)
}


#' @importFrom rquery project_se
#' @export
#' @keywords internal
#'
project_se.wrapped_relop <- function(source,
                                     assignments,
                                     ...,
                                     groupby=c(),
                                     env = parent.frame()) {
  force(env)
  wrapr::stop_if_dot_args(substitute(list(...)),
                          "rqdatatable::project_se.wrapped_relop")
  underlying = project_se(source, assignments,
                          groupby = groupby,
                          env = env)
  res <- list(underlying = underlying,
              data_map = source$data_map)
  class(res) <- 'wrapped_relop'
  return(res)
}


#' @importFrom rquery natural_join
#' @export
#' @keywords internal
#'
natural_join.wrapped_relop <- function(a, b,
                                       ...,
                                       by,
                                       jointype = 'INNER',
                                       env = parent.frame()) {
  force(env)
  wrapr::stop_if_dot_args(substitute(list(...)),
                          "rqdatatable::natural_join.wrapped_relop")
  data_map <- source$data_map
  if('wrapped_relop' %in% class(b)) {
    for(k in names(b$data_map)) {
      data_map[[k]] <- b$data_map[[k]]
    }
    b = b$underlying
  }
  underlying = natural_join(a, b,
                            by = by,
                            jointype = jointype,
                            env = env)
  res <- list(underlying = underlying,
              data_map = data_map)
  class(res) <- 'wrapped_relop'
  return(res)
}


lapply_bquote_to_langauge_list <- function(ll, env) {
  force(env)
  lapply(ll,
         function(li) {
           do.call(bquote, list(expr = li, where = env), envir = env)
         })
}


#' @importFrom rquery select_rows
#' @export
#' @keywords internal
#'
select_rows.wrapped_relop <- function(source, expr,
                                      env = parent.frame()) {
  force(env)
  wrapr::stop_if_dot_args(substitute(list(...)),
                          "rqdatatable::select_rows.wrapped_relop")
  # TODO: confirm this path
  exprq <- substitute(expr)
  exprq <- lapply_bquote_to_langauge_list(list(exprq), env)[[1]]
  underlying = select_rows_se(source, exprq,
                              env = env)
  res <- list(underlying = underlying,
              data_map = source$data_map)
  class(res) <- 'wrapped_relop'
  return(res)
}


#' @importFrom rquery select_rows_se
#' @export
#' @keywords internal
#'
select_rows_se.wrapped_relop <- function(source, expr,
                                         env = parent.frame()) {
  force(env)
  wrapr::stop_if_dot_args(substitute(list(...)),
                          "rqdatatable::select_rows_se.wrapped_relop")
  underlying = select_rows_se(source, expr,
                              env = env)
  res <- list(underlying = underlying,
              data_map = source$data_map)
  class(res) <- 'wrapped_relop'
  return(res)
}


#' @importFrom rquery drop_columns
#' @export
#' @keywords internal
#'
drop_columns.wrapped_relop <- function(source, drops,
                                       ...,
                                       strict = TRUE,
                                       env = parent.frame()) {
  force(env)
  wrapr::stop_if_dot_args(substitute(list(...)),
                          "rqdatatable:drop_columns.wrapped_relo")
  underlying = drop_columns(source, drops,
                            strict = strict,
                            env = env)
  res <- list(underlying = underlying,
              data_map = source$data_map)
  class(res) <- 'wrapped_relop'
  return(res)
}


#' @importFrom rquery select_columns
#' @export
#' @keywords internal
#'
select_columns.wrapped_relop <- function(source, columns, env = parent.frame()) {
  force(env)
  wrapr::stop_if_dot_args(substitute(list(...)),
                          "rqdatatable::select_columns.wrapped_relop")
  underlying = select_columns(source, columns,
                              env = env)
  res <- list(underlying = underlying,
              data_map = source$data_map)
  class(res) <- 'wrapped_relop'
  return(res)
}


#' @importFrom rquery rename_columns
#' @export
#' @keywords internal
#'
rename_columns.wrapped_relop <- function(source, cmap,
                                         env = parent.frame()) {
  force(env)
  wrapr::stop_if_dot_args(substitute(list(...)),
                          "rqdatatable::rename_columns.wrapped_relop")
  underlying = rename_columns(source, cmap,
                              env = env)
  res <- list(underlying = underlying,
              data_map = source$data_map)
  class(res) <- 'wrapped_relop'
  return(res)
}


#' @importFrom rquery order_rows
#' @export
#' @keywords internal
#'
order_rows.wrapped_relop <- function(source,
                                     cols = NULL,
                                     ...,
                                     reverse = NULL,
                                     limit = NULL,
                                     env = parent.frame()) {
  force(env)
  wrapr::stop_if_dot_args(substitute(list(...)),
                          "rqdatatable::order_rows.wrapped_relop")
  underlying = order_rows(source,
                          cols = cols,
                          reverse = reverse,
                          limit = limit,
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





