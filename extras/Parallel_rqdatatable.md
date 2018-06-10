Parallel rqdatatable
================
John Mount
2018-06-10

One can try to execute [`rquery`](https://github.com/WinVector/rquery) `relop` trees in parallel using [`rqdatatable`](https://github.com/WinVector/rqdatatable). However, unless the pipeline is very expensive the overhead of partitioning and distributing the work will usually overwhelm any parallel speedup. Also `data.table` itself already seems to exploit some thread-level parallelism (notice user time &gt; elapsed time).

That being said, we can test an example where computation is expensive due to a blow-up in an intermediate join step.

Set up our execution environment and example (some details: OSX 10.13.4 on a 2.8 GHz Intel Core i5 Mac Mini (Late 2015 model) with 8GB ram and hybrid disk drive).

``` r
library("rqdatatable")
```

    ## Loading required package: rquery

``` r
library("microbenchmark")
library("ggplot2")
library("WVPlots")
library("dplyr")
```

    ## 
    ## Attaching package: 'dplyr'

    ## The following objects are masked from 'package:stats':
    ## 
    ##     filter, lag

    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

``` r
base::date()
```

    ## [1] "Sun Jun 10 09:56:17 2018"

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

    ## [1] '0.1.0'

``` r
packageVersion("rquery")
```

    ## [1] '0.5.0'

``` r
packageVersion("dplyr")
```

    ## [1] '0.7.5'

``` r
cl <- parallel::makeCluster(4)
#parallel::clusterEvalQ(cl, library("rquery"))
#parallel::clusterEvalQ(cl, library("rqdatatable"))


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

dlist <- mk_example(10, 5)
data <- dlist$instance_table
annotation <- dlist$key_table
```

[`rquery`](https://github.com/WinVector/rquery) and [`rqdatatable`](https://github.com/WinVector/rqdatatable) can operate a non-trivial operation tree as follows.

``` r
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

    ##         data id      info   key key_group
    ## 1: 0.2252109  1 0.3300204 key_1        20
    ## 2: 0.6090348  2 0.6152025 key_2         8
    ## 3: 0.2804946  3 0.2931857 key_3        10
    ## 4: 0.4188050  4 0.7806856 key_4         5
    ## 5: 0.2710549  5 0.4483611 key_5        14
    ## 6: 0.5734857  7 0.6422148 key_7        20

``` r
nrow(res1)
```

    ## [1] 38

And we can execute the operations in parallel.

``` r
res2 <- ex_data_table_parallel(optree, "key_group", cl)
head(res2)
```

    ##         data id      info   key key_group
    ## 1: 0.2252109  1 0.3300204 key_1        20
    ## 2: 0.6090348  2 0.6152025 key_2         8
    ## 3: 0.2804946  3 0.2931857 key_3        10
    ## 4: 0.4188050  4 0.7806856 key_4         5
    ## 5: 0.2710549  5 0.4483611 key_5        14
    ## 6: 0.5734857  7 0.6422148 key_7        20

``` r
nrow(res2)
```

    ## [1] 38

[`dplyr`](https://CRAN.R-project.org/package=dplyr) works similarly.

``` r
dplyr_pipeline <- function(data, annotation) {
  data %>%
    inner_join(annotation, by = "key") %>%
    filter(data <= info) %>%
    group_by(id) %>%
    arrange(-data) %>%
    mutate(rownum = row_number()) %>%
    ungroup() %>%
    filter(rownum == 1) %>%
    arrange(id)
}

resd <- dplyr_pipeline(data, annotation)
head(resd)
```

    ## # A tibble: 6 x 7
    ##   key      id  info key_group.x  data key_group.y rownum
    ##   <chr> <int> <dbl> <chr>       <dbl> <chr>        <int>
    ## 1 key_1     1 0.330 20          0.225 20               1
    ## 2 key_2     2 0.615 8           0.609 8                1
    ## 3 key_3     3 0.293 10          0.280 10               1
    ## 4 key_4     4 0.781 5           0.419 5                1
    ## 5 key_5     5 0.448 14          0.271 14               1
    ## 6 key_7     7 0.642 20          0.573 20               1

We can time the various realizations.

``` r
dlist <- mk_example(100, 500)
data <- dlist$instance_table
annotation <- dlist$key_table

timings <- microbenchmark(
  rqdatatable_parallel = ex_data_table_parallel(optree, "key_group", cl),
  rqdatatable = ex_data_table(optree),
  dplyr = dplyr_pipeline(data, annotation),
  times = 10L)
```

``` r
print(timings)
```

    ## Unit: seconds
    ##                  expr       min        lq     mean    median        uq
    ##  rqdatatable_parallel  7.362631  7.850774  8.42504  7.934196  9.461763
    ##           rqdatatable 12.364082 12.737838 13.48126 13.407365 14.049963
    ##                 dplyr 19.379079 20.330585 20.74812 20.786257 21.247072
    ##       max neval
    ##  10.20410    10
    ##  14.84257    10
    ##  21.83926    10

``` r
autoplot(timings)
```

![](Parallel_rqdatatable_files/figure-markdown_github/present-1.png)

``` r
timings <- as.data.frame(timings)
timings$seconds <- timings$time/1e+9
ScatterBoxPlotH(timings, xvar = "seconds", yvar = "expr", 
                title="task duration by method")
```

![](Parallel_rqdatatable_files/figure-markdown_github/present-2.png)

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
    ## # Groups:   key_group [4]
    ##   key       id  info key_group
    ##   <chr>  <int> <dbl> <chr>    
    ## 1 key_5      5 0.402 4        
    ## 2 key_14    14 0.246 19       
    ## 3 key_21    21 0.940 13       
    ## 4 key_29    29 0.184 4        
    ## 5 key_33    33 0.376 6        
    ## 6 key_34    34 0.250 6

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
    ##   key      data key_group
    ##   <chr>   <dbl> <chr>    
    ## 1 key_2  0.920  12       
    ## 2 key_4  0.631  8        
    ## 3 key_6  0.594  8        
    ## 4 key_13 0.117  1        
    ## 5 key_15 0.0999 5        
    ## 6 key_16 0.237  5

``` r
class(annotationp)
```

    ## [1] "party_df"

``` r
dplyr_pipeline(datap, annotationp) %>%
  collect()
```

    ## Error in UseMethod("inner_join"): no applicable method for 'inner_join' applied to an object of class "party_df"

[`dtplyr`](https://CRAN.R-project.org/package=dtplyr) does not appear to work on this example, so we could not include it in the timings.

``` r
library("data.table")
```

    ## 
    ## Attaching package: 'data.table'

    ## The following objects are masked from 'package:dplyr':
    ## 
    ##     between, first, last

``` r
library("dtplyr") #  https://CRAN.R-project.org/package=dtplyr
packageVersion("data.table")
```

    ## [1] '1.11.4'

``` r
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
    ## 1: key_1  1 0.07279547        20
    ## 2: key_2  2 0.16457592        12
    ## 3: key_3  3 0.97850703         7
    ## 4: key_4  4 0.30758642         8
    ## 5: key_5  5 0.40178969         4
    ## 6: key_6  6 0.24435737         8

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
    ## 1: key_1 0.2772080        20
    ## 2: key_2 0.9200673        12
    ## 3: key_3 0.7272237         7
    ## 4: key_4 0.6307832         8
    ## 5: key_5 0.7028741         4
    ## 6: key_6 0.5939254         8

``` r
class(annotationdt)
```

    ## [1] "data.table" "data.frame"

``` r
dplyr_pipeline(datadt, annotationdt)
```

    ## Error in data.table::is.data.table(data): argument "x" is missing, with no default

``` r
parallel::stopCluster(cl)
rm(list = "cl")
```
