Timing Grouped Mean
================

This note is a comment on some of the timings shared in the dplyr-0.8.0 [pre-release announcement](https://www.tidyverse.org/articles/2018/12/dplyr-0-8-0-release-candidate/).

The original published timings were as follows:

[![](timings_summarise_mean_dplyr-0-8-0.jpg)](https://www.tidyverse.org/articles/2018/12/dplyr-0-8-0-release-candidate/)

With performance metrics: measurements are marketing. So let's dig in the above a bit.

These timings are be of [small task large number of repetition breed](https://cran.r-project.org/web/packages/data.table/vignettes/datatable-benchmarking.html#avoid-microbenchmark...-times100) that Matt Dowle writes against. So they at first wouldn't seem that decisive. Except, look at the following:

-   At the time of our reading the example and methods were not shared. To reproduce the work we will need to make our own example (which we share [here](https://github.com/WinVector/rqdatatable/blob/master/extras/TimingGroupedMean.Rmd)).
-   The timings are not relative to any other package or system (`data.table` and `Pandas` being two obvious choices), so may have trouble valuing the results.
-   The time reported for `dplyr` on the `sum()/n()` examples is over a second to process 10,000 rows. This is unbelievably slow, and we fail to reproduce it in our run.
-   The time reported for `dplyr` on the `mean()` examples is about 0.01 seconds. This is a plausible time for this task (about 3 times as long as `data.table` would take). But it is much faster than is typical for `dplyr`. We fail to reproduce it in our run, we see `dplyr` taking closer to 0.07 seconds on this task (or about seven times slower).

Let's try to reproduce these timings on a 2018 Dell XPS 13 Intel Core i5, 16GB Ram running Ubuntu 18.04, and also compare to some other packages: [`data.table`](https://CRAN.R-project.org/package=data.table) and [`rqdatatable`](https://CRAN.R-project.org/package=rqdatatable).

In this reproduction attempt we see:

-   The `dplyr` time being around 0.05 seconds. This is about 5 times slower than claimed.
-   The `dplyr` `sum()/n()` time is about 0.2 seconds, about 5 times faster than claimed.
-   The `data.table` time being around 0.003 seconds. This is about three times as fast as the `dplyr` claims, and over ten times as fast as the actual observed `dplyr` behavior.

All code for this benchmark is available [here](https://github.com/WinVector/rqdatatable/blob/master/extras/TimingGroupedMean.Rmd) and [here](https://github.com/WinVector/rqdatatable/blob/master/extras/TimingGroupedMean.md).

``` r
library("dplyr")
library("rqdatatable")
library("data.table")
library("microbenchmark")
library("WVPlots")
library("ggplot2")
```

``` r
levels <- sprintf("l_%06g", 
                  seq_len(10000))
d <- data.frame(
  g = rep(levels, 10),
  stringsAsFactors = FALSE)
d$x = runif(nrow(d))
dt <- as.data.table(d)
```

``` r
R.version.string
```

    ## [1] "R version 3.5.1 (2018-07-02)"

``` r
packageVersion("dplyr")
```

    ## [1] '0.7.8'

``` r
packageVersion("rqdatatable")
```

    ## [1] '1.1.2'

``` r
packageVersion("data.table")
```

    ## [1] '1.11.8'

``` r
f_dplyr_mean <- function(d) {
  d %>% 
    group_by(g) %>%
    summarize(x = mean(x))
}

f_dplyr_sum_n <- function(d) {
  d %>% 
    group_by(g) %>%
    summarize(x = sum(x)/n())
}

f_rqdatatable <- function(d) {
  d %.>%
    project_nse(., 
                groupby = "g", 
                x = mean(x))
}

f_data.table <- function(dt) {
  dt[, j = list("x" = mean(x)), by = c("g")]
}
```

``` r
timings = microbenchmark(
  dplyr_mean = f_dplyr_mean(d),
  dplyr_sum_n = f_dplyr_sum_n(d),
  rqdatatable = f_rqdatatable(d),
  data.table = f_data.table(dt),
  times = 10L
)
```

``` r
print(timings)
```

    ## Unit: milliseconds
    ##         expr        min         lq       mean     median         uq
    ##   dplyr_mean  48.666778  49.936418  50.706373  50.533701  51.797656
    ##  dplyr_sum_n 174.673685 178.183725 183.502817 180.411104 184.421786
    ##  rqdatatable   4.604693   4.859366   6.713337   5.187235   5.326155
    ##   data.table   2.451022   2.724500   3.010058   2.794454   3.111439
    ##         max neval
    ##   52.715118    10
    ##  202.182481    10
    ##   20.082657    10
    ##    4.568284    10

``` r
res <- as.data.frame(timings)
res$seconds = res$time/1e+9
res$method = res$expr

res %.>%
  project_nse(.,
              groupby = "method",
              mean_seconds = mean(seconds)) %.>%
  knitr::kable(.)
```

| method        |  mean\_seconds|
|:--------------|--------------:|
| dplyr\_mean   |      0.0507064|
| dplyr\_sum\_n |      0.1835028|
| rqdatatable   |      0.0067133|
| data.table    |      0.0030101|

``` r
WVPlots::ScatterBoxPlotH(
  res, 
  "seconds", "method", 
  "task run time by method")
```

![](TimingGroupedMean_files/figure-markdown_github/present-1.png)

``` r
WVPlots::ScatterBoxPlotH(
  res,  
  "seconds", "method", 
  "task run time by method") + 
  scale_y_log10()
```

![](TimingGroupedMean_files/figure-markdown_github/present-2.png)

Try again at larger data size.

``` r
levels <- sprintf("l_%06g", 
                  seq_len(1000000))
d <- data.frame(
  g = rep(levels, 10),
  stringsAsFactors = FALSE)
d$x = runif(nrow(d))
dt <- as.data.table(d)
```

``` r
timings2 = microbenchmark(
  dplyr_mean = f_dplyr_mean(d),
  dplyr_sum_n = f_dplyr_sum_n(d),
  rqdatatable = f_rqdatatable(d),
  data.table = f_data.table(dt),
  times = 5L
)
```

``` r
print(timings2)
```

    ## Unit: milliseconds
    ##         expr        min         lq       mean     median         uq
    ##   dplyr_mean  9843.3586  9908.8161 10251.3212 10245.5254 10586.1296
    ##  dplyr_sum_n 23797.5394 24024.5731 24571.9004 24885.6025 25062.4381
    ##  rqdatatable   388.5662   410.4587   582.2213   415.2360   810.9741
    ##   data.table   365.8645   375.7298   386.4544   395.3369   395.3741
    ##         max neval
    ##  10672.7764     5
    ##  25089.3491     5
    ##    885.8714     5
    ##    399.9668     5

``` r
res2 <- as.data.frame(timings2)
res2$seconds = res2$time/1e+9
res2$method = res2$expr

res2 %.>%
  project_nse(.,
              groupby = "method",
              mean_seconds = mean(seconds)) %.>%
  knitr::kable(.)
```

| method        |  mean\_seconds|
|:--------------|--------------:|
| data.table    |      0.3864544|
| rqdatatable   |      0.5822213|
| dplyr\_mean   |     10.2513212|
| dplyr\_sum\_n |     24.5719004|

``` r
WVPlots::ScatterBoxPlotH(
  res2, 
  "seconds", "method", 
  "task run time by method (larger example)")
```

![](TimingGroupedMean_files/figure-markdown_github/present2-1.png)

``` r
WVPlots::ScatterBoxPlotH(
  res2,  
  "seconds", "method", 
  "task run time by method (larger example)") + 
  scale_y_log10()
```

![](TimingGroupedMean_files/figure-markdown_github/present2-2.png)
