Speed Up Your R Work
================
John Mount
2018-07-09

Introduction
============

In this note we will show how to speed up work in [`R`](https://www.r-project.org) by partitioning data and process-level parallelization. We will show the technique with three different `R` packages: [`rqdatatable`](https://github.com/WinVector/rqdatatable), [`data.table`](https://CRAN.R-project.org/package=data.table), and [`dplyr`](https://CRAN.R-project.org/package=dplyr). The methods shown will also work with base-`R` and other packages.

For each of the above packages we speed up work by using [`wrapr::execute_parallel`](https://winvector.github.io/wrapr/reference/execute_parallel.html) which in turn uses [`wrapr::partition_tables`](https://winvector.github.io/wrapr/reference/partition_tables.html) to partition un-related `data.frame` rows and then distributes them to different processors to be executed. [`rqdatatable::ex_data_table_parallel`](https://winvector.github.io/rqdatatable/reference/ex_data_table_parallel.html) conveniently bundles all of these steps together when working with [`rquery`](https://CRAN.R-project.org/package=rquery) pipelines.

The partitioning is specified by the user preparing a grouping column that tells the system which sets of rows must be kept together in a correct calculation. We are going to try to demonstrate everything with simple code examples, and minimal discussion.

Keep in mind: unless the pipeline steps have non-trivial cost, the overhead of partitioning and distributing the work may overwhelm any parallel speedup. Also `data.table` itself already seems to exploit some thread-level parallelism (notice user time is greater than elapsed time). That being said, in this note we will demonstrate a synthetic example where computation is expensive due to a blow-up in an intermediate join step.

Our example
===========

First we set up our execution environment and example (some details: OSX 10.13.4 on a 2.8 GHz Intel Core i5 Mac Mini (Late 2015 model) with 8GB RAM and hybrid disk drive).

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

    ## [1] "Mon Jul  9 08:19:44 2018"

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
# revised function from:
# http://www.win-vector.com/blog/2018/07/speed-up-your-r-work/#comment-66925
data_table_f <- function(data, annotation) {
  #setDT(data, key = c("key","info"))
  #setDT(annotation, key = c("key","data"))
  data <- data.table::as.data.table(data)
  annotation <- data.table::as.data.table(annotation)
  
  joined2 <- data[annotation,
                  on=.(key, info >= data),
                  .(id,
                    key,
                    info = x.info,
                    key_group.x = x.key_group,
                    data = i.data,
                    key_group.y = i.key_group),
                  allow.cartesian=TRUE,
                  nomatch = 0]
  
  setorder(joined2,data)
  joined2[joined2[,.I[.N], keyby = .(id)]$V1]
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

And we can use [`wrapr::execute_parallel`](https://winvector.github.io/wrapr/reference/execute_parallel.html) to parallelize the `dplyr` solution.

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
    ##   data_table_parallel  1.989580  2.051434  2.142745  2.134477  2.193945
    ##            data_table  3.869135  4.171722  4.250459  4.237998  4.281611
    ##  rqdatatable_parallel  7.282341  7.502254  7.612384  7.557135  7.762405
    ##           rqdatatable 12.529240 12.930110 13.616540 13.576316 14.344924
    ##        dplyr_parallel  6.442109  6.518160  6.630826  6.590514  6.654042
    ##                 dplyr 20.359402 20.602746 20.726175 20.659127 20.839135
    ##        max neval
    ##   2.461094    10
    ##   4.697535    10
    ##   8.077394    10
    ##  14.732983    10
    ##   6.964291    10
    ##  21.435225    10

``` r
# autoplot(timings)

timings <- as.data.frame(timings)
timings$seconds <- timings$time/1e+9

ScatterBoxPlotH(timings, 
                xvar = "seconds", yvar = "expr", 
                title="task duration by method")
```

![](Parallel_rqdatatable_files/figure-markdown_github/present-1.png)

In these timings `data.table` is by far the fastest. Part of it is the faster nature of `data.table`, and another contribution is `data.table`'s non-equi join avoids a lot of expense (which is why theta-style joins are in fact interesting).

A reason `dplyr` sees greater speedup relative to its own non-parallel implementation (yet does not beat `data.table`) is that `data.table` starts already multi-threaded, so `data.table` is exploiting some parallelism even before we added the process level parallelism (and hence sees less of a speed up, though it is fastest).

`rquery` pipelines [exhibit superior performance on big data systems](https://github.com/WinVector/rquery/blob/master/extras/PerfTest.md) (Spark, PostgreSQL, Amazon Redshift, and hopefully soon Google bigquery), and `rqdatatable` supplies [a very good in-memory implementation of the `rquery` system](http://www.win-vector.com/blog/2018/06/rqdatatable-rquery-powered-by-data-table/) based on `data.table`. `rquery` also speeds up solution development by supplying higher order operators and early debugging features.

In this note we have demonstrated simple procedures to reliably parallelize any of `rqdatatable`, `data.table`, or `dplyr`.

Note: we did not include alternatives such as `multidplyr` or `dtplyr` in the timings, as they did not appear to work on this example.

################### 

Materials
=========

The original rendering of this article can be found [here](https://github.com/WinVector/rqdatatable/blob/master/extras/Parallel_rqdatatable.md), source code [here](https://github.com/WinVector/rqdatatable/blob/master/extras/Parallel_rqdatatable.Rmd), and raw timings [here](https://github.com/WinVector/rqdatatable/blob/master/extras/Parallel_rqdatatable_timings.RDS).

multidplyr
==========

[`multidplyr`](https://github.com/hadley/multidplyr) does not appear to work on this example, so we could not include it in the timings.

``` r
# devtools::install_github("hadley/multidplyr")
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
