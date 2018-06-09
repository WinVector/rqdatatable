Parallel rqdatatable
================
John Mount
2018-06-09

One can try to execute `relop` trees in parallel. However, in unless the pipeline is very expensive the overhead of partitioning and distributing the work will by far overwhelm any parallel speedup. Also `data.table` itself already seems to exploit some thread-level parallelism (notice user time &gt; elapsed time).

``` r
have_parallel <- requireNamespace("parallel", quietly = TRUE)
```

``` r
library("rqdatatable")
```

    ## Loading required package: rquery

``` r
cl <- parallel::makeCluster(4)
#parallel::clusterEvalQ(cl, library("rquery"))
#parallel::clusterEvalQ(cl, library("rqdatatable"))

set.seed(2362)
mk_example <- function(nkey, nrow, nrep = 5) {
  keys <- paste0("key_", seq_len(nkey))
  key_table <- data.frame(
    key = rep(keys, nrep),
    stringsAsFactors = FALSE)
  key_table$data <- runif(nrow(key_table))
  instance_table <- data.frame(
    id = seq_len(nrow),
    key = sample(keys, nrow, replace = TRUE),
    info = runif(nrow),
    stringsAsFactors = FALSE)
  list(key_table = key_table,
       instance_table = instance_table)
}

dlist <- mk_example(10, 100, 10)
data <- dlist$instance_table
annotation <- dlist$key_table


# possible data lookup: find rows that
# have lookup data <= info
optree <- local_td(data) %.>%
  natural_join(., local_td(annotation), jointype = "INNER", by = "key") %.>%
  select_rows_nse(., data <= info) %.>%
  pick_top_k(., 
             k = 1,
             partitionby = "id",
             orderby = "data",
             reverse = "data",
             keep_order_column = FALSE) %.>%
  orderby(., "id")
cat(format(optree))
```

    ## table('data'; 
    ##   id,
    ##   key,
    ##   info) %.>%
    ##  natural_join(.,
    ##   table('annotation'; 
    ##     key,
    ##     data),
    ##   j= INNER, by= key) %.>%
    ##  select_rows(.,
    ##    data <= info) %.>%
    ##  extend(.,
    ##   row_rank := rank(),
    ##   p= id,
    ##   o= "data" DESC) %.>%
    ##  select_rows(.,
    ##    row_rank <= 1) %.>%
    ##  drop_columns(.,
    ##    row_rank) %.>%
    ##  orderby(., id)

``` r
res1 <- ex_data_table(optree)
head(res1)
```

    ##         data id      info    key
    ## 1: 0.6798646  1 0.7035685  key_7
    ## 2: 0.7137628  2 0.7289375  key_8
    ## 3: 0.3450735  3 0.5269276 key_10
    ## 4: 0.6152025  4 0.8234298  key_2
    ## 5: 0.6152025  5 0.7716559  key_2
    ## 6: 0.6236996  7 0.6633022  key_6

``` r
nrow(res1)
```

    ## [1] 88

``` r
res2 <- ex_data_table_parallel(optree, "key", cl)
```

    ## [1] "start 2018-06-09 08:52:52"
    ## [1] "start split 2018-06-09 08:52:52"
    ## [1] "start apply split 2018-06-09 08:52:52"
    ## [1] "2018-06-09 08:52:52 PDT"
    ## [1] "done 2018-06-09 08:52:52"

``` r
head(res2)
```

    ##         data id      info    key
    ## 1: 0.6798646  1 0.7035685  key_7
    ## 2: 0.7137628  2 0.7289375  key_8
    ## 3: 0.3450735  3 0.5269276 key_10
    ## 4: 0.6152025  4 0.8234298  key_2
    ## 5: 0.6152025  5 0.7716559  key_2
    ## 6: 0.6236996  7 0.6633022  key_6

``` r
nrow(res2)
```

    ## [1] 88

``` r
dlist <- mk_example(1000, 100000, 1000)
data <- dlist$instance_table
annotation <- dlist$key_table

system.time(ex_data_table(optree))
```

    ##    user  system elapsed 
    ##  23.336   9.852  34.334

``` r
system.time(ex_data_table_parallel(optree, "key", cl))
```

    ## [1] "start 2018-06-09 08:53:27"
    ## [1] "start split 2018-06-09 08:53:27"
    ## [1] "start apply split 2018-06-09 08:53:39"
    ## [1] "2018-06-09 08:53:58 PDT"
    ## [1] "done 2018-06-09 08:53:58"

    ##    user  system elapsed 
    ##  10.757   2.009  30.386

``` r
parallel::stopCluster(cl)
rm(list = "cl")
```
