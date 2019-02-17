
test_relop_materialize <- function() {

  d1 <- data.frame(AUC = 0.6, R2 = 0.2)

  ##  TODO: instantiate this part of test once we up
  ##        rquery dependence to 1.3.0 .
  # r1 <- d1 %.>%
  #   extend(., z = AUC/R2) %.>%
  #   extend(., q = AUC+R2)
  # r2 <- d1 %.>%
  #   extend(., z = AUC/R2) %.>%
  #   materialize_node(., table_name = "tmp") %.>%
  #   extend(., q = AUC+R2)
  # RUnit::checkEquals(data.frame(r1), data.frame(r2))



  optree1 <- local_td(d1) %.>%
    extend(., z = AUC/R2) %.>%
    extend(., q = AUC+R2)

  optree2 <- local_td(d1) %.>%
    extend(., z = AUC/R2) %.>%
    materialize_node(., table_name = "tmp") %.>%
    extend(., q = AUC+R2)

  r1 <- d1 %.>% optree1
  r2 <- d1 %.>% optree2
  RUnit::checkEquals(data.frame(r1), data.frame(r2))

  invisible(NULL)
}

