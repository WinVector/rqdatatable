Grouped Rank Filter
================

Amazon EC2 `r4.8xlarge` (244 GiB RAM) run (8-12-2018, 64-bit Ubuntu Server 16.04 LTS (HVM), SSD Volume Type - ami-ba602bc2, R 3.4.4 all packages current).

``` r
# https://cran.r-project.org/web/packages/reticulate/vignettes/r_markdown.html
library("reticulate")
use_python("/home/ruser/miniconda3/bin/python3")
pandas_handle <- reticulate::import("pandas") # don't use as https://github.com/rstudio/reticulate/issues/319

pandas_fn <- py_run_string("
def py_fn(df):
   ord = df.sort_values(by = ['col_a', 'col_b', 'col_c', 'col_x'], ascending = [True, True, True, True])
   ord['rank_col'] = ord.groupby(['col_a', 'col_b', 'col_c']).cumcount()
   return ord[ord.rank_col == 0].sort_values(by = ['col_a', 'col_b', 'col_c', 'col_x'], ascending = True).ix[:, ['col_a', 'col_b', 'col_c', 'col_x']]
")
do_pandas <- function(d) {
  res <- pandas_fn$py_fn(pandas_handle$DataFrame(d))
  rownames(res) <- NULL
  return(res)
}
```

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
library("dtplyr")
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
                     data.frame(vi) # strip attributes
                   })
  isTRUE(all(sapply(values[-1], function(x) identical(values[[1]], x))))
}
```

``` r
ds <- mk_data(3)

ds %>%  
  group_by(col_a, col_b, col_c) %>% 
  arrange(col_x) %>% 
  filter(row_number() == 1) %>%
  ungroup() %>%
  arrange(col_a, col_b, col_c, col_x)
```

    ## # A tibble: 3 x 4
    ##   col_a col_b col_c col_x
    ##   <chr> <chr> <chr> <dbl>
    ## 1 sym_1 sym_1 sym_1 0.751
    ## 2 sym_2 sym_1 sym_1 0.743
    ## 3 sym_2 sym_2 sym_1 0.542

``` r
ds %>%  
  as.data.table() %>%
  group_by(col_a, col_b, col_c) %>% 
  arrange(col_x) %>% 
  filter(row_number() == 1) %>%
  ungroup() %>%
  arrange(col_a, col_b, col_c, col_x)
```

    ## Error in rank(x, ties.method = "first", na.last = "keep"): argument "x" is missing, with no default

``` r
pow <- 8
rds_name <- "GroupedRankFilter2_runs.RDS"
if(!file.exists(rds_name)) {
  szs <- expand.grid(a = c(1,2,5), b = 10^{0:pow}) 
  szs <- sort(unique(szs$a * szs$b))
  szs <- szs[szs<=10^pow]
  runs <- lapply(
    rev(szs),
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
          ops <- local_td(d) %.>%
            pick_top_k(., 
                       k = 1L,
                       orderby = "col_x",
                       partitionby = c("col_a", "col_b", "col_c"),
                       keep_order_column = FALSE) %.>%
            orderby(., c("col_a", "col_b", "col_c", "col_x"))
          d %.>% ops
        },
        dplyr = {
          d %>% 
            group_by(col_a, col_b, col_c) %>% 
            arrange(col_x) %>% 
            filter(row_number() == 1) %>%
            ungroup() %>%
            arrange(col_a, col_b, col_c, col_x)
        },
        pandas_reticulate = {
          do_pandas(d)
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

<img src="GroupedRankFilter2_files/figure-markdown_github/present-1.png" width="1152" />

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

|   rows|  data.table|         dplyr|  pandas\_reticulate|  rqdatatable|       ratio|
|------:|-----------:|-------------:|-------------------:|------------:|-----------:|
|  1e+00|   0.0012220|     0.0036808|           0.0528722|    0.0062401|    3.012173|
|  2e+00|   0.0012721|     0.0032407|           0.0474003|    0.0061236|    2.547409|
|  5e+00|   0.0012714|     0.0042640|           0.0512000|    0.0070195|    3.353799|
|  1e+01|   0.0011080|     0.0033529|           0.0476711|    0.0060561|    3.026090|
|  2e+01|   0.0012042|     0.0036422|           0.0525711|    0.0060827|    3.024552|
|  5e+01|   0.0011446|     0.0035813|           0.0478871|    0.0060665|    3.128768|
|  1e+02|   0.0013386|     0.0046073|           0.0523581|    0.0066181|    3.441996|
|  2e+02|   0.0013257|     0.0050385|           0.0481853|    0.0061737|    3.800794|
|  5e+02|   0.0013002|     0.0084516|           0.0552084|    0.0072802|    6.500211|
|  1e+03|   0.0014505|     0.0132834|           0.0507414|    0.0066255|    9.157561|
|  2e+03|   0.0017025|     0.0300404|           0.0601327|    0.0081342|   17.644900|
|  5e+03|   0.0018250|     0.0619265|           0.0644052|    0.0085473|   33.932531|
|  1e+04|   0.0025937|     0.1362418|           0.1169200|    0.0123986|   52.528797|
|  2e+04|   0.0041173|     0.3062655|           0.1121389|    0.0150407|   74.385092|
|  5e+04|   0.0088449|     0.8391986|           0.2206598|    0.0290885|   94.879296|
|  1e+05|   0.0164051|     1.7502977|           0.3979698|    0.0516130|  106.692192|
|  2e+05|   0.0312433|     3.5663185|           0.8836784|    0.1038430|  114.146763|
|  5e+05|   0.0820740|     8.8326184|           2.4153055|    0.2753604|  107.617704|
|  1e+06|   0.1758014|    17.9648324|           5.2094482|    0.7027790|  102.188235|
|  2e+06|   0.3711697|    35.5348507|          11.3279683|    1.1058219|   95.737470|
|  5e+06|   1.0178499|    89.8890604|          32.5319896|    3.3859227|   88.312690|
|  1e+07|   2.4310282|   188.1988675|          69.2231432|    6.0397727|   77.415336|
|  2e+07|   3.7101990|   382.3118725|         146.9938764|   12.8661763|  103.043494|
|  5e+07|  10.5123341|  1003.7706922|         384.8652335|   28.5743195|   95.485045|
|  1e+08|  28.1888318|  2077.8368593|         831.7301071|  104.7479324|   73.711350|

``` r
ggplot(data = means, aes(x = rows, y = ratio)) +
  geom_point() + 
  geom_smooth(se = FALSE) +
  scale_x_log10() + 
  ggtitle("ratio of dplyr runtime to data.table runtime",
          subtitle = "grouped sorting/sum task")
```

    ## `geom_smooth()` using method = 'loess' and formula 'y ~ x'

<img src="GroupedRankFilter2_files/figure-markdown_github/present-2.png" width="1152" />
