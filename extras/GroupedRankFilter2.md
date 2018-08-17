Grouped Rank Filter
================

Late 2014 Mac Mini 2.8 GHz Intel Core i5, 8 GB 1600 MHz DDR3 RAM.

``` r
# https://cran.r-project.org/web/packages/reticulate/vignettes/r_markdown.html
library("reticulate")
use_python("/Users/johnmount/anaconda3/bin/python3")
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
pow <- 6
rds_name <- "GroupedRankFilter2_runs.RDS"
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

|   rows|  data.table|       dplyr|  pandas\_reticulate|  rqdatatable|       ratio|
|------:|-----------:|-----------:|-------------------:|------------:|-----------:|
|  1e+00|   0.0014039|   0.0030103|           0.0421621|    0.0088890|   2.1442705|
|  2e+00|   0.0015879|   0.0029556|           0.0425789|    0.0075464|   1.8613086|
|  5e+00|   0.0016117|   0.0035594|           0.0543929|    0.0114550|   2.2085096|
|  1e+01|   0.0063730|   0.0040811|           0.0566445|    0.0132074|   0.6403778|
|  2e+01|   0.0016251|   0.0045056|           0.0555863|    0.0114108|   2.7725583|
|  5e+01|   0.0020897|   0.0049469|           0.0562630|    0.0106749|   2.3672949|
|  1e+02|   0.0015709|   0.0061104|           0.0634033|    0.0105902|   3.8897282|
|  2e+02|   0.0021189|   0.0069774|           0.0556364|    0.0114088|   3.2930115|
|  5e+02|   0.0016425|   0.0101393|           0.0620991|    0.0119361|   6.1732423|
|  1e+03|   0.0018265|   0.0212241|           0.0498281|    0.0115981|  11.6199428|
|  2e+03|   0.0023114|   0.0332965|           0.0725457|    0.0128065|  14.4053951|
|  5e+03|   0.0033855|   0.0808919|           0.0805580|    0.0189853|  23.8933666|
|  1e+04|   0.0049798|   0.1350366|           0.1086150|    0.0209020|  27.1167050|
|  2e+04|   0.0083315|   0.2792474|           0.1475553|    0.0302971|  33.5171747|
|  5e+04|   0.0190474|   0.6720980|           0.3026181|    0.0732130|  35.2854946|
|  1e+05|   0.0420870|   1.3126943|           0.5804750|    0.1383093|  31.1900036|
|  2e+05|   0.0640798|   3.1411725|           1.2995626|    0.2801596|  49.0196923|
|  5e+05|   0.1757401|   7.6311740|           3.6436349|    0.8304852|  43.4230771|
|  1e+06|   0.4007553|  17.8595672|           8.2253009|    1.3205715|  44.5647679|

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
