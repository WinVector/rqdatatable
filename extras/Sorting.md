Sorting
================

Amazon EC2 `r4.8xlarge` (244 GiB RAM) run (8-12-2018, 64-bit Ubuntu Server 16.04 LTS (HVM), SSD Volume Type - ami-ba602bc2, R 3.4.4 all packages current).

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

    ## Warning: package 'dplyr' was built under R version 3.5.1

    ## 
    ## Attaching package: 'dplyr'

    ## The following objects are masked from 'package:stats':
    ## 
    ##     filter, lag

    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

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

if(!file.exists("Sorting_runs.RDS")) {
  szs <- expand.grid(a = c(1,2,5), b = 10^{0:9})
  szs <- sort(unique(szs$a * szs$b))
  szs <- szs[szs<=1e+9]
  runs <- lapply(
    szs,
    function(sz) {
      d <- mk_data(sz)
      ti <- microbenchmark(
        rqdatatable = { d %.>% ops %.>% as.data.frame(.) },
        dplyr = dplyr::arrange(d, col_a, col_b, col_c, col_x),
        times = 3L,
        check = my_check)
      ti <- as.data.frame(ti)
      ti$rows <- sz
      ti
    })
  saveRDS(runs, "Sorting_runs.RDS")
} else {
  runs <- readRDS("Sorting_runs.RDS")
}
```

``` r
timings <- do.call(rbind, runs)
timings$seconds <- timings$time/1e+9
timings$method <- gsub("^rqdatatable$", "data.table", timings$expr)
timings$method <- factor(timings$method)
timings$method <- reorder(timings$method, -timings$seconds)

ggplot(data = timings, aes(x = rows, y = seconds, color = method)) +
  geom_point() + 
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
             ratio = dplyr/data.table,
             ratio_by_log_rows = ratio/log(rows)) %.>%
  orderby(., "rows")

knitr::kable(means)
```

|   rows|   data.table|         dplyr|     ratio|  ratio\_by\_log\_rows|
|------:|------------:|-------------:|---------:|---------------------:|
|  1e+00|    0.0008447|     0.0075125|  8.893619|                   Inf|
|  2e+00|    0.0008826|     0.0014331|  1.623732|             2.3425501|
|  5e+00|    0.0008745|     0.0014337|  1.639380|             1.0186042|
|  1e+01|    0.0008821|     0.0014334|  1.625015|             0.7057349|
|  2e+01|    0.0009189|     0.0014090|  1.533443|             0.5118759|
|  5e+01|    0.0008773|     0.0014871|  1.695088|             0.4333021|
|  1e+02|    0.0009320|     0.0015343|  1.646189|             0.3574653|
|  2e+02|    0.0009497|     0.0015034|  1.583013|             0.2987765|
|  5e+02|    0.0009695|     0.0015608|  1.609916|             0.2590536|
|  1e+03|    0.0009974|     0.0017879|  1.792502|             0.2594912|
|  2e+03|    0.0011463|     0.0021422|  1.868716|             0.2458545|
|  5e+03|    0.0015462|     0.0031856|  2.060303|             0.2418993|
|  1e+04|    0.0016717|     0.0053182|  3.181343|             0.3454099|
|  2e+04|    0.0027123|     0.0099019|  3.650701|             0.3686278|
|  5e+04|    0.0068707|     0.0266648|  3.880951|             0.3586904|
|  1e+05|    0.0139790|     0.0580948|  4.155857|             0.3609731|
|  2e+05|    0.0546940|     0.1280969|  2.342063|             0.1918769|
|  5e+05|    0.0844396|     0.3875499|  4.589670|             0.3497594|
|  1e+06|    0.1417959|     0.7440808|  5.247547|             0.3798301|
|  2e+06|    0.2911317|     1.7887026|  6.143964|             0.4234688|
|  5e+06|    0.7923789|     5.3594062|  6.763691|             0.4384903|
|  1e+07|    1.6448312|    12.0048937|  7.298557|             0.4528176|
|  2e+07|    3.3158578|    26.4237598|  7.968906|             0.4740224|
|  5e+07|    9.3422346|    73.0847586|  7.823049|             0.4412937|
|  1e+08|   21.3954544|   158.2277751|  7.395392|             0.4014722|
|  2e+08|   43.5116136|   345.7414166|  7.945957|             0.4157177|
|  5e+08|  107.2533052|  1026.9141090|  9.574662|             0.4780132|
|  1e+09|  238.3929687|  2323.0695705|  9.744707|             0.4702303|

``` r
ggplot(data = means, aes(x = rows, y = ratio)) +
  geom_point() + 
  geom_smooth(se = FALSE) +
  scale_x_log10() + 
  ggtitle("ratio of dplyr runtime to data.table runtime")
```

    ## `geom_smooth()` using method = 'loess' and formula 'y ~ x'

<img src="Sorting_files/figure-markdown_github/present-2.png" width="1152" />

``` r
ggplot(data = means, aes(x = rows, y = ratio_by_log_rows)) +
  geom_point() + 
  geom_smooth(se = FALSE) +
  scale_x_log10() + 
  ggtitle("ratio of dplyr runtime to data.table runtime dived by log(rows)")
```

    ## `geom_smooth()` using method = 'loess' and formula 'y ~ x'

    ## Warning: Removed 1 rows containing non-finite values (stat_smooth).

<img src="Sorting_files/figure-markdown_github/present-3.png" width="1152" />
