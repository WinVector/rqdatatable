

#' ex_data_table for relop_list.
#'
#' Execute storing intermeidate tables in tables variable.
#'
#' @inheritParams ex_data_table
#' @export
ex_data_table.relop_list <- function(optree,
                                     ...,
                                     tables = list(),
                                     source_usage = NULL,
                                     source_limit = NULL,
                                     env = parent.frame()) {
  force(env)
  if(!(isS4(optree) && methods::is(optree, "relop_list"))) {
    stop("rquery::materialize_relop_list_local, expected optree to be of S4 class relop_list")
  }
  wrapr::stop_if_dot_args(substitute(list(...)), "rqdatatable::ex_data_table.relop_list")
  narrow = TRUE  # not part of our arguments, default to TRUE
  res <- NULL
  stages <- rquery::get_relop_list_stages(optree, narrow = narrow)
  nstg <- length(stages)
  for(i in seq_len(nstg)) {
    stage <- stages[[i]]
    table_name = stage$materialize_as
    res <- ex_data_table(stage,
                         ...,
                         tables = tables,
                         source_usage = source_usage,
                         source_limit = source_limit,
                         env = env)
    res <- data.frame(res) # break away from reference semantics
    tables[[table_name]] <- res
  }
  res
}
