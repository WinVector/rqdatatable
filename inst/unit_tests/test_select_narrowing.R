
test_select_narrowing <- function() {
  # dbinfo <- rquery::rquery_db_info(identifier_quote_char = "`", string_quote_char = '"')
  x <- data.frame(a = 1:3, b = 4:6, c = 7:9)
  op1 <- local_td(x) %.>% extend_nse(., e %:=% a + 1)
  #  cat(to_sql(op1, dbinfo))
  cn1 <- sort(colnames((x %.>% op1)[]))
  op2 <- op1 %.>% select_columns(., "e")
  #  cat(to_sql(op2, dbinfo))
  cn2 <- sort(colnames((x %.>% op2)[]))
  RUnit::checkEquals(cn1, c("a", "b", "c", "e"))
  RUnit::checkEquals(cn2, c("e"))

  invisible(NULL)
}
