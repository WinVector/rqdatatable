


#' Theta join (database implementation).
#'
#' Limited implementation.  All terms must be of the form: "(table1.col CMP table2.col) (, (table1.col CMP table2.col) )".
#'
#' @examples
#'
#'  d1 <- data.frame(AUC = 0.6, R2 = 0.2)
#'  d2 <- data.frame(AUC2 = 0.4, R2 = 0.3)
#'
#'  optree <- theta_join_se(local_td(d1), local_td(d2), "AUC >= AUC2")
#'
#'  ex_data_table(optree, tables = list(d1 = d1, d2 = d2)) %.>%
#'    print(.)
#'
#' @inheritParams ex_data_table
#' @export
ex_data_table.relop_theta_join <- function(optree,
                                           ...,
                                           tables = list(),
                                           source_usage = NULL,
                                           source_limit = NULL,
                                           env = parent.frame()) {
  wrapr::stop_if_dot_args(substitute(list(...)), "rqdatatable::ex_data_table.relop_theta_join")
  if(is.null(source_usage)) {
    source_usage <- columns_used(optree)
  }
  inputs <- lapply(optree$source,
                   function(si) {
                     ex_data_table(si,
                                   tables = tables,
                                   source_usage = source_usage,
                                   source_limit = source_limit,
                                   env = env)
                   })
  A <- inputs[[1]]
  B <- inputs[[2]]
  inputs <- NULL
  # get join conditions
  n <- length(optree$parsed)
  eexprs <-
    vapply(seq_len(n),
           function(i) {
             strip_up_through_first_assignment(as.character(optree$parsed[[i]]$presentation))
           }, character(1))
  eeterm <- paste(eexprs, collapse = ", ")
  eeterm <- gsub("&&", ",", eeterm, fixed = TRUE)
  # build column mapping
  cols <- c(as.character(optree$cmap[[1]]), as.character(optree$cmap[[2]]))
  qcols <- cols
  qcols[seq_len(length(optree$cmap[[1]]))] <- paste0("x.", names(optree$cmap[[1]]))
  qcols[length(optree$cmap[[1]]) + seq_len(length(optree$cmap[[2]]))] <- paste0("i.", names(optree$cmap[[2]]))
  colsterm <- paste(cols, "=", qcols)
  colsterm <- paste(colsterm, collapse = ", ")
  res <- if(optree$jointype=="INNER") {
    expr_text <- paste0("A[B, on=.(", eeterm, "), .(", colsterm, "), allow.cartesian = TRUE, nomatch = 0]")
  } else if(optree$jointype=="LEFT") {
    expr_text <- paste0("A[B, on=.(", eeterm, "), .(", colsterm, "), allow.cartesian = TRUE]")
  } else if(optree$jointype=="RIGHT") {
    expr_text <- paste0("B[A, on=.(", eeterm, "), .(", colsterm, "), allow.cartesian = TRUE]")
  } else if(optree$jointype=="FULL") {
    stop("rqdatatable::ex_data_table.relop_theta_join FULL join not implemented")
  } else {
    stop(paste("jointype was", optree$jointype, " but should be one of INNER, LEFT, RIGHT"))
  }
  expr <- parse(text = expr_text)
  tmpenv <- new.env(parent = globalenv())
  assign("A", A, envir = tmpenv)
  assign("B", B, envir = tmpenv)
  res <- eval(expr, envir = tmpenv, enclos = tmpenv)
  res
}



