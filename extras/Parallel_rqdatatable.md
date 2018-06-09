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
mk_example <- function(nkey, nrep) {
  keys <- paste0("key_", seq_len(nkey))
  key_table <- data.frame(
    key = rep(keys, nrep),
    stringsAsFactors = FALSE)
  key_table$data <- runif(nrow(key_table))
  instance_table <- data.frame(
    key = rep(keys, nrep),
    stringsAsFactors = FALSE)
  instance_table$id <- seq_len(nrow(instance_table))
  instance_table$info <- runif(nrow(instance_table))
  list(key_table = key_table,
       instance_table = instance_table)
}

dlist <- mk_example(10, 5)
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
    ##   key,
    ##   id,
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

    ##         data id      info   key
    ## 1: 0.4678928  1 0.6376330 key_1
    ## 2: 0.3876909  2 0.6090348 key_2
    ## 3: 0.5704148  3 0.9038968 key_3
    ## 4: 0.2251412  4 0.2523321 key_4
    ## 5: 0.2710549  5 0.5148019 key_5
    ## 6: 0.7465447  6 0.9497908 key_6

``` r
nrow(res1)
```

    ## [1] 41

``` r
res2 <- ex_data_table_parallel(optree, "key", cl)
```

    ## [1] "start 2018-06-09 09:44:38"
    ## [1] "start split 2018-06-09 09:44:38"
    ## [1] "start apply split 2018-06-09 09:44:38"
    ## [1] "2018-06-09 09:44:38 PDT"
    ## [1] "done 2018-06-09 09:44:38"

``` r
head(res2)
```

    ##         data id      info   key
    ## 1: 0.4678928  1 0.6376330 key_1
    ## 2: 0.3876909  2 0.6090348 key_2
    ## 3: 0.5704148  3 0.9038968 key_3
    ## 4: 0.2251412  4 0.2523321 key_4
    ## 5: 0.2710549  5 0.5148019 key_5
    ## 6: 0.7465447  6 0.9497908 key_6

``` r
nrow(res2)
```

    ## [1] 41

``` r
dlist <- mk_example(100, 1000)
data <- dlist$instance_table
annotation <- dlist$key_table

system.time(ex_data_table(optree))
```

    ##    user  system elapsed 
    ##  21.766   9.261  31.369

``` r
system.time(ex_data_table_parallel(optree, "key", cl))
```

    ## [1] "start 2018-06-09 09:45:10"
    ## [1] "start split 2018-06-09 09:45:10"
    ## [1] "start apply split 2018-06-09 09:45:10"
    ## [1] "2018-06-09 09:45:20 PDT"
    ## [1] "done 2018-06-09 09:45:20"

    ##    user  system elapsed 
    ##   0.399   0.081  10.657

``` r
parallel::stopCluster(cl)
rm(list = "cl")
```
