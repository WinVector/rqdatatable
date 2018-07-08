Speeding Up R Calculations with Parallelization
================
John Mount
2018-07-08

Introduction
============

In this note we will demonstrate speeding up calculations by partitioning data and process-level parallelization.

We will show how to speed up calculations with parallelization using [`rqdatatable`](https://github.com/WinVector/rqdatatable), [`data.table`](https://CRAN.R-project.org/package=data.table), or [`dplyr`](https://CRAN.R-project.org/package=dplyr). For each of these packages the parallelization becomes possible when we use [`wrapr::execute_parallel`](https://winvector.github.io/wrapr/reference/execute_parallel.html) to partition un-related `data.frame` rows to be distributed to different processors.

However, unless the pipeline steps have non-trivial cost, the overhead of partitioning and distributing the work may overwhelm any parallel speedup. Also `data.table` itself already seems to exploit some thread-level parallelism (notice user time is greater than elapsed time). That being said, we can test an synthetic example where computation is expensive due to a blow-up in an intermediate join step.

Our example
===========

First we set up our execution environment and example (some details: OSX 10.13.4 on a 2.8 GHz Intel Core i5 Mac Mini (Late 2015 model) with 8GB ram and hybrid disk drive).

``` r
library("rqdatatable")
```

    ## Loading required package: rquery

``` r
library("microbenchmark")
library("ggplot2")
library("WVPlots")
suppressPackageStartupMessages(library("dplyr"))
```

    ## Warning: package 'dplyr' was built under R version 3.5.1

``` r
base::date()
```

    ## [1] "Sun Jul  8 07:52:58 2018"

``` r
R.version.string
```

    ## [1] "R version 3.5.0 (2018-04-23)"

``` r
parallel::detectCores()
```

    ## [1] 4

``` r
packageVersion("parallel")
```

    ## [1] '3.5.0'

``` r
packageVersion("rqdatatable")
```

    ## [1] '0.1.2'

``` r
packageVersion("rquery")
```

    ## [1] '0.5.1'

``` r
packageVersion("dplyr")
```

    ## [1] '0.7.6'

``` r
ncore <- parallel::detectCores()
print(ncore)
```

    ## [1] 4

``` r
cl <- parallel::makeCluster(ncore)
print(cl)
```

    ## socket cluster with 4 nodes on host 'localhost'

``` r
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

dlist <- mk_example(10, 10)
data <- dlist$instance_table
annotation <- dlist$key_table
```

rquery / rqdatatable
====================

[`rquery`](https://github.com/WinVector/rquery) and [`rqdatatable`](https://github.com/WinVector/rqdatatable) can implement a non-trivial calculation as follows.

``` r
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
cat(format(optree))
```

    ## table('data'; 
    ##   key,
    ##   id,
    ##   info,
    ##   key_group) %.>%
    ##  natural_join(.,
    ##   table('annotation'; 
    ##     key,
    ##     data,
    ##     key_group),
    ##   j= INNER, by= key) %.>%
    ##  select_rows(.,
    ##    data <= info) %.>%
    ##  extend(.,
    ##   row_number := row_number(),
    ##   p= id,
    ##   o= "data" DESC) %.>%
    ##  select_rows(.,
    ##    row_number <= 1) %.>%
    ##  drop_columns(.,
    ##    row_number) %.>%
    ##  orderby(., id)

``` r
res1 <- ex_data_table(optree)
head(res1)
```

    ##         data id      info   key key_group
    ## 1: 0.9152014  1 0.9860654 key_1        20
    ## 2: 0.5599810  2 0.5857570 key_2         8
    ## 3: 0.3011882  3 0.3334490 key_3        10
    ## 4: 0.3650987  4 0.3960980 key_4         5
    ## 5: 0.1469254  5 0.1753649 key_5        14
    ## 6: 0.2567631  6 0.3510280 key_6         7

``` r
nrow(res1)
```

    ## [1] 94

And we can execute the operations in parallel.

``` r
parallel::clusterEvalQ(cl, 
                       library("rqdatatable"))
```

    ## [[1]]
    ## [1] "rqdatatable" "rquery"      "stats"       "graphics"    "grDevices"  
    ## [6] "utils"       "datasets"    "methods"     "base"       
    ## 
    ## [[2]]
    ## [1] "rqdatatable" "rquery"      "stats"       "graphics"    "grDevices"  
    ## [6] "utils"       "datasets"    "methods"     "base"       
    ## 
    ## [[3]]
    ## [1] "rqdatatable" "rquery"      "stats"       "graphics"    "grDevices"  
    ## [6] "utils"       "datasets"    "methods"     "base"       
    ## 
    ## [[4]]
    ## [1] "rqdatatable" "rquery"      "stats"       "graphics"    "grDevices"  
    ## [6] "utils"       "datasets"    "methods"     "base"

``` r
res2 <- ex_data_table_parallel(optree, 
                               "key_group", 
                               cl)
head(res2)
```

    ##         data id      info   key key_group
    ## 1: 0.9152014  1 0.9860654 key_1        20
    ## 2: 0.5599810  2 0.5857570 key_2         8
    ## 3: 0.3011882  3 0.3334490 key_3        10
    ## 4: 0.3650987  4 0.3960980 key_4         5
    ## 5: 0.1469254  5 0.1753649 key_5        14
    ## 6: 0.2567631  6 0.3510280 key_6         7

``` r
nrow(res2)
```

    ## [1] 94

data.table
==========

[`data.table`](http://r-datatable.com) can implement the same function.

``` r
library("data.table")
```

    ## 
    ## Attaching package: 'data.table'

    ## The following objects are masked from 'package:dplyr':
    ## 
    ##     between, first, last

``` r
packageVersion("data.table")
```

    ## [1] '1.11.4'

``` r
data_table_f <- function(data, annotation) {
  data <- data.table::as.data.table(data)
  annotation <- data.table::as.data.table(annotation)
  joined <- merge(data, annotation, 
                  by = "key", 
                  all=FALSE, 
                  allow.cartesian=TRUE)
  joined <- joined[joined$data <= joined$info, ]
  data.table::setorderv(joined, cols = "data")
  joined <- joined[, .SD[.N], id]
  data.table::setorderv(joined, cols = "id")
}
resdt <- data_table_f(data, annotation)
head(resdt)
```

    ##    id   key      info key_group.x      data key_group.y
    ## 1:  1 key_1 0.9860654          20 0.9152014          20
    ## 2:  2 key_2 0.5857570           8 0.5599810           8
    ## 3:  3 key_3 0.3334490          10 0.3011882          10
    ## 4:  4 key_4 0.3960980           5 0.3650987           5
    ## 5:  5 key_5 0.1753649          14 0.1469254          14
    ## 6:  6 key_6 0.3510280           7 0.2567631           7

``` r
nrow(resdt)
```

    ## [1] 94

We can also run `data.table` in parallel using [`wrapr::execute_parallel`](https://winvector.github.io/wrapr/reference/execute_parallel.html).

``` r
parallel::clusterEvalQ(cl, library("data.table"))
```

    ## [[1]]
    ##  [1] "data.table"  "rqdatatable" "rquery"      "stats"       "graphics"   
    ##  [6] "grDevices"   "utils"       "datasets"    "methods"     "base"       
    ## 
    ## [[2]]
    ##  [1] "data.table"  "rqdatatable" "rquery"      "stats"       "graphics"   
    ##  [6] "grDevices"   "utils"       "datasets"    "methods"     "base"       
    ## 
    ## [[3]]
    ##  [1] "data.table"  "rqdatatable" "rquery"      "stats"       "graphics"   
    ##  [6] "grDevices"   "utils"       "datasets"    "methods"     "base"       
    ## 
    ## [[4]]
    ##  [1] "data.table"  "rqdatatable" "rquery"      "stats"       "graphics"   
    ##  [6] "grDevices"   "utils"       "datasets"    "methods"     "base"

``` r
parallel::clusterExport(cl, "data_table_f")

dt_f <- function(tables_list) {
  data <- tables_list$data
  annotation <- tables_list$annotation
  data_table_f(data, annotation)
}

data_table_parallel_f <- function(data, annotation) {
  respdt <- wrapr::execute_parallel(
    tables = list(data = data, 
                  annotation = annotation),
    f = dt_f,
    partition_column = "key_group",
    cl = cl) %.>%
    data.table::rbindlist(.)
  data.table::setorderv(respdt, cols = "id")
  respdt
}
respdt <- data_table_parallel_f(data, annotation)
head(respdt)
```

    ##    id   key      info key_group.x      data key_group.y
    ## 1:  1 key_1 0.9860654          20 0.9152014          20
    ## 2:  2 key_2 0.5857570           8 0.5599810           8
    ## 3:  3 key_3 0.3334490          10 0.3011882          10
    ## 4:  4 key_4 0.3960980           5 0.3650987           5
    ## 5:  5 key_5 0.1753649          14 0.1469254          14
    ## 6:  6 key_6 0.3510280           7 0.2567631           7

``` r
nrow(respdt)
```

    ## [1] 94

dplyr
=====

[`dplyr`](https://CRAN.R-project.org/package=dplyr) can also implement the example.

``` r
dplyr_pipeline <- function(data, annotation) {
  res <- data %>%
    inner_join(annotation, by = "key") %>%
    filter(data <= info) %>%
    group_by(id) %>%
    arrange(-data) %>%
    mutate(rownum = row_number()) %>%
    ungroup() %>%
    filter(rownum == 1) %>%
    arrange(id)
  res
}

resd <- dplyr_pipeline(data, annotation)
head(resd)
```

    ## # A tibble: 6 x 7
    ##   key      id  info key_group.x  data key_group.y rownum
    ##   <chr> <int> <dbl> <chr>       <dbl> <chr>        <int>
    ## 1 key_1     1 0.986 20          0.915 20               1
    ## 2 key_2     2 0.586 8           0.560 8                1
    ## 3 key_3     3 0.333 10          0.301 10               1
    ## 4 key_4     4 0.396 5           0.365 5                1
    ## 5 key_5     5 0.175 14          0.147 14               1
    ## 6 key_6     6 0.351 7           0.257 7                1

``` r
nrow(resd)
```

    ## [1] 94

And we can use [`wrapr::execute_parallel`](https://winvector.github.io/wrapr/reference/execute_parallel.html) to also parallelize the `dplyr` solution.

``` r
parallel::clusterEvalQ(cl, library("dplyr"))
```

    ## [[1]]
    ##  [1] "dplyr"       "data.table"  "rqdatatable" "rquery"      "stats"      
    ##  [6] "graphics"    "grDevices"   "utils"       "datasets"    "methods"    
    ## [11] "base"       
    ## 
    ## [[2]]
    ##  [1] "dplyr"       "data.table"  "rqdatatable" "rquery"      "stats"      
    ##  [6] "graphics"    "grDevices"   "utils"       "datasets"    "methods"    
    ## [11] "base"       
    ## 
    ## [[3]]
    ##  [1] "dplyr"       "data.table"  "rqdatatable" "rquery"      "stats"      
    ##  [6] "graphics"    "grDevices"   "utils"       "datasets"    "methods"    
    ## [11] "base"       
    ## 
    ## [[4]]
    ##  [1] "dplyr"       "data.table"  "rqdatatable" "rquery"      "stats"      
    ##  [6] "graphics"    "grDevices"   "utils"       "datasets"    "methods"    
    ## [11] "base"

``` r
parallel::clusterExport(cl, "dplyr_pipeline")

dplyr_f <- function(tables_list) {
  data <- tables_list$data
  annotation <- tables_list$annotation
  dplyr_pipeline(data, annotation)
}

dplyr_parallel_f <- function(data, annotation) {
  respdt <- wrapr::execute_parallel(
    tables = list(data = data, 
                  annotation = annotation),
    f = dplyr_f,
    partition_column = "key_group",
    cl = cl) %>%
    dplyr::bind_rows() %>%
    arrange(id)
}
respdplyr <- dplyr_parallel_f(data, annotation)
head(respdplyr)
```

    ## # A tibble: 6 x 7
    ##   key      id  info key_group.x  data key_group.y rownum
    ##   <chr> <int> <dbl> <chr>       <dbl> <chr>        <int>
    ## 1 key_1     1 0.986 20          0.915 20               1
    ## 2 key_2     2 0.586 8           0.560 8                1
    ## 3 key_3     3 0.333 10          0.301 10               1
    ## 4 key_4     4 0.396 5           0.365 5                1
    ## 5 key_5     5 0.175 14          0.147 14               1
    ## 6 key_6     6 0.351 7           0.257 7                1

``` r
nrow(respdplyr)
```

    ## [1] 94

Benchmark
=========

We can benchmark the various realizations.

``` r
dlist <- mk_example(300, 300)
data <- dlist$instance_table
annotation <- dlist$key_table

timings <- microbenchmark(
  data_table_parallel = 
    nrow(data_table_parallel_f(data, annotation)),
  data_table = nrow(data_table_f(data, annotation)),
  rqdatatable_parallel = 
    nrow(ex_data_table_parallel(optree, "key_group", cl)),
  rqdatatable = nrow(ex_data_table(optree)),
  dplyr_parallel = 
    nrow(dplyr_parallel_f(data, annotation)),
  dplyr = nrow(dplyr_pipeline(data, annotation)),
  times = 10L)

saveRDS(timings, "Parallel_rqdatatable_timings.RDS")
```

Conclusion
==========

``` r
print(timings)
```

    ## Unit: seconds
    ##                  expr       min        lq      mean    median        uq
    ##   data_table_parallel  5.515423  5.634853  6.371040  5.841237  6.335951
    ##            data_table  9.585073  9.646407 11.560736 10.293269 10.942273
    ##  rqdatatable_parallel  7.418973  7.470167  8.397419  8.110988  8.778457
    ##           rqdatatable 12.828250 13.656825 14.705748 14.185518 15.347285
    ##        dplyr_parallel  6.475563  6.694923  7.279872  7.036339  7.146306
    ##                 dplyr 20.097889 20.735335 21.644570 21.018004 22.644733
    ##        max neval
    ##   8.655145    10
    ##  22.964469    10
    ##  10.485317    10
    ##  18.251560    10
    ##   9.811681    10
    ##  24.293064    10

``` r
# autoplot(timings)

timings <- as.data.frame(timings)
timings$seconds <- timings$time/1e+9

ScatterBoxPlotH(timings, 
                xvar = "seconds", yvar = "expr", 
                title="task duration by method")
```

![](Parallel_rqdatatable_files/figure-markdown_github/present-1.png)

Parallelized `data.table` is the fastest, followed by parallelized `dplyr` and parallelized `rqdatatable`.
The non-paraellized run times are in a similar order. A reason `dplyr` sees greater speedup relative to its own non-parallel implementation is that `data.table` starts already multi-threaded, so it is exploring some parallelism even before we added the fork-style parallelism. We did not include variations such as `multidplyr` or `dtplyr` in the timings, as they did not appear to work.

################### 

Materials
=========

The original rendering of this article can be found [here](https://github.com/WinVector/rqdatatable/blob/master/extras/Parallel_rqdatatable.md), source code [here](https://github.com/WinVector/rqdatatable/blob/master/extras/Parallel_rqdatatable.Rmd), and raw timings [here](https://github.com/WinVector/rqdatatable/blob/master/extras/Parallel_rqdatatable_timings.RDS).

Speculation
===========

`rqdatatable`'s minor performance regression relative to `datatable` I believe is from `rqdatatable`'s ranking strategy (something we will likely tune later, already [usually `rqdatatable` is competitive with `data.table` and actually quite fast](https://github.com/WinVector/rquery/blob/master/extras/data_table_replot.md)).

multidplyr
==========

[`multidplyr`](https://github.com/hadley/multidplyr) does not appear to work on this example, so we could not include it in the timings.

``` r
library("multidplyr") # https://github.com/hadley/multidplyr
packageVersion("multidplyr")
```

    ## [1] '0.0.0.9000'

``` r
multidplyr::set_default_cluster(cl)

# example similar to https://github.com/hadley/multidplyr/blob/master/vignettes/multidplyr.Rmd
class(data)
```

    ## [1] "data.frame"

``` r
datap <- multidplyr::partition(data, key_group)
```

    ## Warning: group_indices_.grouped_df ignores extra arguments

``` r
head(datap)
```

    ## # A tibble: 6 x 4
    ## # Groups:   key_group [3]
    ##   key       id   info key_group
    ##   <chr>  <int>  <dbl> <chr>    
    ## 1 key_4      4 0.874  13       
    ## 2 key_8      8 0.469  1        
    ## 3 key_11    11 0.260  14       
    ## 4 key_18    18 0.443  14       
    ## 5 key_22    22 0.332  13       
    ## 6 key_23    23 0.0974 1

``` r
class(datap)
```

    ## [1] "party_df"

``` r
class(annotation)
```

    ## [1] "data.frame"

``` r
annotationp <- multidplyr::partition(annotation, key_group)
```

    ## Warning: group_indices_.grouped_df ignores extra arguments

``` r
head(annotationp)
```

    ## # A tibble: 6 x 3
    ## # Groups:   key_group [4]
    ##   key     data key_group
    ##   <chr>  <dbl> <chr>    
    ## 1 key_1  0.481 6        
    ## 2 key_13 0.105 3        
    ## 3 key_27 0.978 8        
    ## 4 key_28 0.119 10       
    ## 5 key_29 0.488 10       
    ## 6 key_32 0.286 8

``` r
class(annotationp)
```

    ## [1] "party_df"

``` r
dplyr_pipeline(datap, annotationp) %>%
  collect()
```

    ## Error in UseMethod("inner_join"): no applicable method for 'inner_join' applied to an object of class "party_df"

dtplyr
======

[`dtplyr`](https://CRAN.R-project.org/package=dtplyr) does not appear to work on this example, so we could not include it in the timings.

``` r
library("data.table")
library("dtplyr") #  https://CRAN.R-project.org/package=dtplyr
packageVersion("dtplyr")
```

    ## [1] '0.0.2'

``` r
class(data)
```

    ## [1] "data.frame"

``` r
datadt <- data.table::as.data.table(data)
head(datadt)
```

    ##      key id       info key_group
    ## 1: key_1  1 0.19866525         6
    ## 2: key_2  2 0.84333232        19
    ## 3: key_3  3 0.02837453        15
    ## 4: key_4  4 0.87365445        13
    ## 5: key_5  5 0.83771302        15
    ## 6: key_6  6 0.02838293        12

``` r
class(datadt)
```

    ## [1] "data.table" "data.frame"

``` r
class(annotation)
```

    ## [1] "data.frame"

``` r
annotationdt <- data.table::as.data.table(annotation)
head(annotationdt)
```

    ##      key      data key_group
    ## 1: key_1 0.4810728         6
    ## 2: key_2 0.4595057        19
    ## 3: key_3 0.1476172        15
    ## 4: key_4 0.5624729        13
    ## 5: key_5 0.1921203        15
    ## 6: key_6 0.8842115        12

``` r
class(annotationdt)
```

    ## [1] "data.table" "data.frame"

``` r
dplyr_pipeline(datadt, annotationdt)
```

    ## Error in data.table::is.data.table(data): argument "x" is missing, with no default

clean up
========

``` r
parallel::stopCluster(cl)
rm(list = "cl")
```
