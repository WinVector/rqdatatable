
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
  res <- local_td(d, name = name, env = env)
  res$data <- d
  return(res)
}


r_find_table_values <- function(ops, tables = list()) {
  if("relop_table_source" %in% class(ops)) {
    dat = ops$data
    if(!is.null(dat)) {
      tables[[ops$table_name]] <- dat
    }

  } else {
    for(si in ops$source) {
      tables <- r_find_table_values(si, tables = tables)
    }
  }
  return(tables)
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
  force(env)
  tables <- r_find_table_values(ops)
  ex_data_table(ops, tables = tables, env=env)
}





