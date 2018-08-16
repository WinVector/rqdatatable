Grouped Sorting
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

    ## 
    ## Attaching package: 'dplyr'

    ## The following objects are masked from 'package:stats':
    ## 
    ##     filter, lag

    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

``` r
library("data.table")
```

    ## 
    ## Attaching package: 'data.table'

    ## The following objects are masked from 'package:dplyr':
    ## 
    ##     between, first, last

``` r
set.seed(32523)

mk_data <- function(nrow) {
  alphabet <- paste("sym", seq_len(max(2, floor(nrow^(1/3)))), sep = "_")
  data.frame(col_a = sample(alphabet, nrow, replace=TRUE),
             col_b = sample(alphabet, nrow, replace=TRUE),
             col_c = sample(alphabet, nrow, replace=TRUE),
             col_x = runif(nrow),
             stringsAsFactors = FALSE)
}
```

``` r
# adapted from help(microbenchmark)
my_check <- function(values) {
  values <- lapply(values,
                   function(vi) {
                     vi <- as.data.frame(vi)
                     rownames(vi) <- NULL
                     vi
                   })
  isTRUE(all(sapply(values[-1], function(x) identical(values[[1]], x))))
}
```

``` r
pow <- 8
rds_name <- "GroupedSorting_runs.RDS"
if(!file.exists(rds_name)) {
  szs <- expand.grid(a = c(1,2,5), b = 10^{0:pow}) 
  szs <- sort(unique(szs$a * szs$b))
  szs <- szs[szs<=10^pow]
  runs <- lapply(
    szs,
    function(sz) {
      d <- mk_data(sz)
      ti <- microbenchmark(
        data.table = { 
          # https://stackoverflow.com/questions/16325641/how-to-extract-the-first-n-rows-per-group
          d %.>% 
            as.data.table(.) %.>% 
            setorder(., col_a, col_b, col_c, col_x) %.>%
            .[, .SD[1], by=list(col_a, col_b, col_c)] %.>%
            setorder(., col_a, col_b, col_c, col_x)
        },
        rqdatatable = { 
          d %.>%
            pick_top_k(., 
                       orderby = "col_x",
                       partitionby = c("col_a", "col_b", "col_c"),
                       keep_order_column = FALSE) %.>%
            orderby(., c("col_a", "col_b", "col_c", "col_x"))
        },
        dplyr = {
          d %>% 
            group_by(col_a, col_b, col_c) %>% 
            arrange(col_x) %>% 
            filter(row_number() == 1) %>%
            ungroup() %>%
            arrange(col_a, col_b, col_c, col_x)
        },
        times = 3L,
        check = my_check)
      ti <- as.data.frame(ti)
      ti$rows <- sz
      ti
    })
  saveRDS(runs, rds_name)
} else {
  runs <- readRDS(rds_name)
}
```

``` r
timings <- do.call(rbind, runs)
timings$seconds <- timings$time/1e+9
timings$method <- factor(timings$expr)
timings$method <- reorder(timings$method, -timings$seconds)

ggplot(data = timings, aes(x = rows, y = seconds, color = method)) +
  geom_point() + 
  geom_smooth(se = FALSE) +
  scale_x_log10() + scale_y_log10() +
  ggtitle("grouped sorting task time by rows and method",
          subtitle = "log-log trend shown")
```

    ## `geom_smooth()` using method = 'loess' and formula 'y ~ x'

<img src="GroupedSorting_files/figure-markdown_github/present-1.png" width="1152" />

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
             ratio = dplyr/data.table) %.>%
  orderby(., "rows")

knitr::kable(means)
```

|   rows|  data.table|         dplyr|  rqdatatable|      ratio|
|------:|-----------:|-------------:|------------:|----------:|
|  1e+00|   0.0011951|     0.0098265|    0.0082620|   8.222454|
|  2e+00|   0.0011959|     0.0033314|    0.0082424|   2.785678|
|  5e+00|   0.0011864|     0.0033939|    0.0084511|   2.860778|
|  1e+01|   0.0012535|     0.0033805|    0.0081950|   2.696767|
|  2e+01|   0.0013120|     0.0034043|    0.0083385|   2.594831|
|  5e+01|   0.0012459|     0.0037954|    0.0081347|   3.046298|
|  1e+02|   0.0011815|     0.0041567|    0.0084052|   3.518234|
|  2e+02|   0.0012784|     0.0051612|    0.0082062|   4.037338|
|  5e+02|   0.0012999|     0.0081600|    0.0085988|   6.277404|
|  1e+03|   0.0014372|     0.0134316|    0.0087887|   9.345849|
|  2e+03|   0.0016893|     0.0262540|    0.0105104|  15.540941|
|  5e+03|   0.0025957|     0.0639630|    0.0113792|  24.642165|
|  1e+04|   0.0025850|     0.1192851|    0.0133682|  46.145877|
|  2e+04|   0.0043410|     0.2822051|    0.0189490|  65.009018|
|  5e+04|   0.0482549|     0.6545480|    0.0352328|  13.564390|
|  1e+05|   0.0186305|     1.4542748|    0.0679744|  78.058677|
|  2e+05|   0.0734117|     2.8331374|    0.1555675|  38.592459|
|  5e+05|   0.1668738|     7.2122194|    0.4209933|  43.219616|
|  1e+06|   0.1764776|    15.1005233|    0.6833693|  85.566208|
|  2e+06|   0.4060240|    31.0397187|    1.2900111|  76.447986|
|  5e+06|   1.1995374|    79.5442208|    3.2486682|  66.312414|
|  1e+07|   2.1088333|   169.4659050|    6.5554873|  80.360030|
|  2e+07|   4.6866528|   362.8710744|   12.9863176|  77.426490|
|  5e+07|  12.2220816|   898.1085842|   34.0927516|  73.482457|
|  1e+08|  24.8203722|  1983.1236486|   71.9125024|  79.899029|

``` r
ggplot(data = means, aes(x = rows, y = ratio)) +
  geom_point() + 
  geom_smooth(se = FALSE) +
  scale_x_log10() + 
  ggtitle("ratio of dplyr runtime to data.table runtime",
          subtitle = "grouped sorting/sum task")
```

    ## `geom_smooth()` using method = 'loess' and formula 'y ~ x'

<img src="GroupedSorting_files/figure-markdown_github/present-2.png" width="1152" />
