
test_ex_relop_list <- function() {
  # from http://www.win-vector.com/blog/2019/02/query-generation-in-r/
  d <- data.frame(x = -3:3)

  d1 <- natural_join(d, d,
                     by = "x", jointype = "LEFT")
  d2 <- natural_join(d1, d1,
                     by = "x", jointype = "LEFT")
  d3 <- natural_join(d2, d2,
                     by = "x", jointype = "LEFT")
  ds <- orderby(d3, cols = "x")
  RUnit::checkEquals(d, data.frame(ds))

  d0 <- local_td(d)
  d1 <- natural_join(d0, d0,
                     by = "x", jointype = "LEFT")
  d2 <- natural_join(d1, d1,
                     by = "x", jointype = "LEFT")
  d3 <- natural_join(d2, d2,
                     by = "x", jointype = "LEFT")
  ds <- orderby(d3, cols = "x")
  dr <- ex_data_table(d3)
  RUnit::checkEquals(d, data.frame(dr))

  rd <- d %.>% d1
  RUnit::checkEquals(d, data.frame(rd))
  rl <- list(d = d) %.>% d1
  RUnit::checkEquals(d, data.frame(rl))

  tmps <- wrapr::mk_tmp_name_source()
  relop_list <- rquery::make_relop_list(tmps)
  d1_ops <- natural_join(d0, d0,
                         by = "x", jointype = "LEFT") %.>%
    relop_list
  d2_ops <- natural_join(d1_ops, d1_ops,
                         by = "x", jointype = "LEFT") %.>%
    relop_list
  d3_ops <- natural_join(d2_ops, d2_ops,
                         by = "x", jointype = "LEFT") %.>%
    relop_list
  ds_ops <- orderby(d3_ops, cols = "x") %.>%
    relop_list
  dr2 <- ex_data_table(relop_list)
  RUnit::checkEquals(d, data.frame(dr2))

  # # not allowed to due to a %.>% relop_List is relop_list's collecting pattern.
  # # (and relop list is primarilly for databases, so don't want to bend it too far for rqdatatable)
  # rd <- d %.>% relop_list
  # RUnit::checkEquals(d, data.frame(rd))
  # rl <- list(d = d) %.>% relop_list
  # RUnit::checkEquals(d, data.frame(rl))
}
