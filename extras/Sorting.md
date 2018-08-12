Sorting
================

Amazon EC2 `r4.8xlarge`.

``` r
library("rqdatatable")
```

    ## Loading required package: rquery

``` r
library("microbenchmark")
library("ggplot2")
library("WVPlots")
library("cdata")
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
packageVersion("dplyr")
```

    ## [1] '0.7.6'

``` r
R.version
```

    ##                _                           
    ## platform       x86_64-pc-linux-gnu         
    ## arch           x86_64                      
    ## os             linux-gnu                   
    ## system         x86_64, linux-gnu           
    ## status                                     
    ## major          3                           
    ## minor          4.4                         
    ## year           2018                        
    ## month          03                          
    ## day            15                          
    ## svn rev        74408                       
    ## language       R                           
    ## version.string R version 3.4.4 (2018-03-15)
    ## nickname       Someone to Lean On

``` r
set.seed(32523)

mk_data <- function(nrow) {
  data.frame(col_a = sample(letters, nrow, replace=TRUE),
             col_b = sample(letters, nrow, replace=TRUE),
             col_c = sample(letters, nrow, replace=TRUE),
             col_x = runif(nrow),
             stringsAsFactors = FALSE)
}
```

``` r
ops <- mk_td("d", c("col_a", "col_b", "col_c", "col_x")) %.>%
  orderby(., cols = c("col_a", "col_b", "col_c", "col_x"))

# from help(microbenchmark)
my_check <- function(values) {
  all(sapply(values[-1], function(x) identical(values[[1]], x)))
}

szs <- expand.grid(a = c(1,2,5), b = 10^{0:8})
szs <- sort(unique(szs$a * szs$b))
runs <- lapply(
  szs,
  function(sz) {
    d <- mk_data(sz)
    ti <- microbenchmark(
      rqdatatable = { d %.>% ops %.>% as.data.frame(.) },
      dplyr = dplyr::arrange(d, col_a, col_b, col_c, col_x),
      times = 5L,
      check = my_check)
    ti <- as.data.frame(ti)
    ti$rows <- sz
    ti
  })
saveRDS(runs, "Sorting_runs.RDS")
```

``` r
timings <- do.call(rbind, runs)
timings$seconds <- timings$time/1e+9
timings$method <- factor(timings$expr)
timings$method <- reorder(timings$method, timings$seconds)

ggplot(data = timings, aes(x = rows, y = seconds, color = method)) +
  geom_point() + 
  geom_smooth(method = "lm") +
  scale_x_log10() + scale_y_log10() +
  ggtitle("sorting task time by rows and method",
          subtitle = "log-log trend shown")
```

<img src="Sorting_files/figure-markdown_github/present-1.png" width="1152" />

``` r
means <- timings %.>%
  project_nse(., 
              groupby = c("method", "rows"), 
              seconds = mean(seconds)) %.>%
  pivot_to_rowrecs(., 
                   columnToTakeKeysFrom = "method",
                   columnToTakeValuesFrom = "seconds",
                   rowKeyColumns = "rows") %.>%
  extend_nse(., 
             ratio = dplyr/rqdatatable,
             ratio_by_log_rows = ratio/log(rows))
  
  
ggplot(data = means, aes(x = rows, y = ratio)) +
  geom_point() + 
  geom_smooth(se = FALSE) +
  scale_x_log10() + 
  ggtitle("ratio of dplyr runtime to rqdatatable runtime")
```

    ## `geom_smooth()` using method = 'loess' and formula 'y ~ x'

<img src="Sorting_files/figure-markdown_github/present-2.png" width="1152" />

``` r
ggplot(data = means, aes(x = rows, y = ratio_by_log_rows)) +
  geom_point() + 
  geom_smooth(se = FALSE) +
  scale_x_log10() + 
  ggtitle("ratio of dplyr runtime to rqdatatable runtime dived by log(rows)")
```

    ## `geom_smooth()` using method = 'loess' and formula 'y ~ x'

    ## Warning: Removed 1 rows containing non-finite values (stat_smooth).

<img src="Sorting_files/figure-markdown_github/present-3.png" width="1152" />
