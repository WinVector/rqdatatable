
library("rqdatatable")
context("ex_data_table_parallel")

test_that("test_execute_parallel works as expected", {

  cl <- parallel::makeCluster(2)



  # from http://www.win-vector.com/blog/2018/07/speed-up-your-r-work/
  set.seed(2362)
  mk_example <- function(nkey, nrep, ngroup = 20) {
    keys <- paste0("key_", seq_len(nkey))
    key_group <- sample(as.character(seq_len(ngroup)),
                        length(keys), replace = TRUE)
    names(key_group) <- keys
    key_table <- data.frame(
      key = rep(keys, nrep),
      stringsAsFactors = FALSE)
    key_table$data <- runif(nrow(key_table))
    instance_table <- data.frame(
      key = rep(keys, nrep),
      stringsAsFactors = FALSE)
    instance_table$id <- seq_len(nrow(instance_table))
    instance_table$info <- runif(nrow(instance_table))
    # groups should be no finer than keys
    key_table$key_group <- key_group[key_table$key]
    instance_table$key_group <- key_group[instance_table$key]
    list(key_table = key_table,
         instance_table = instance_table)
  }

  dlist <- mk_example(5, 5, 5)
  data <- dlist$instance_table
  annotation <- dlist$key_table

  # possible data lookup: find rows that
  # have lookup data <= info
  optree <- local_td(data) %.>%
    natural_join(.,
                 local_td(annotation),
                 jointype = "INNER",
                 by = "key") %.>%
    select_rows_nse(., data <= info) %.>%
    pick_top_k(.,
               k = 1,
               partitionby = "id",
               orderby = "data",
               reverse = "data",
               keep_order_column = FALSE) %.>%
    orderby(., "id")
  # cat(format(optree))

  res1 <- ex_data_table(optree)
  res1 <- as.data.frame(res1)

  parallel::clusterEvalQ(cl,
                         library("rqdatatable"))

  res2 <- ex_data_table_parallel(optree,
                                 "key_group",
                                 cl)
  res2 <- as.data.frame(res2)

  parallel::stopCluster(cl)

  testthat::expect_equivalent(res1, res2)

})
