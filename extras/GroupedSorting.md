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
          d %.>% 
            as.data.table(.) %.>% 
            setorder(., col_x) %.>%
            .[, running := cumsum(col_x), by=list(col_a, col_b, col_c)] %.>%
            setorder(., col_a, col_b, col_c, col_x) %.>%
            setDF(.)[] 
        },
        rqdatatable = { 
          d %.>%
            extend_nse(., 
                       running = cumsum(col_x),
                       partitionby = c("col_a", "col_b", "col_c"),
                       orderby = "col_x") %.>%
            orderby(., c("col_a", "col_b", "col_c", "col_x")) %.>%
            setDF(.)[]
        },
        dplyr = {
          d %>% 
            group_by(col_a, col_b, col_c) %>% 
            arrange(col_x) %>% 
            mutate(running = cumsum(col_x)) %>% 
            arrange(col_a, col_b, col_c, col_x)
            as.data.frame(.)
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
             ratio = dplyr/data.table,
             ratio_by_log_rows = ratio/log(rows)) %.>%
  orderby(., "rows")

knitr::kable(means)
```

|   rows|  data.table|        dplyr|  rqdatatable|      ratio|  ratio\_by\_log\_rows|
|------:|-----------:|------------:|------------:|----------:|---------------------:|
|  1e+00|   0.0010821|    0.0100476|    0.0044867|   9.285011|                   Inf|
|  2e+00|   0.0010370|    0.0034783|    0.0044634|   3.354321|             4.8392628|
|  5e+00|   0.0011451|    0.0036018|    0.0044072|   3.145295|             1.9542816|
|  1e+01|   0.0011916|    0.0036191|    0.0044678|   3.037183|             1.3190318|
|  2e+01|   0.0023994|    0.0057146|    0.0071134|   2.381617|             0.7950032|
|  5e+01|   0.0013500|    0.0045362|    0.0043257|   3.360117|             0.8589206|
|  1e+02|   0.0012206|    0.0057225|    0.0044897|   4.688218|             1.0180335|
|  2e+02|   0.0012647|    0.0078160|    0.0044632|   6.180128|             1.1664322|
|  5e+02|   0.0014518|    0.0144703|    0.0047338|   9.967165|             1.6038284|
|  1e+03|   0.0016752|    0.0256874|    0.0050469|  15.333847|             2.2198017|
|  2e+03|   0.0023489|    0.0458627|    0.0062330|  19.525066|             2.5687826|
|  5e+03|   0.0040170|    0.1045992|    0.0082466|  26.038840|             3.0572090|
|  1e+04|   0.0058399|    0.1839662|    0.0100233|  31.501765|             3.4202606|
|  2e+04|   0.0097084|    0.2952436|    0.0148164|  30.411092|             3.0707457|
|  5e+04|   0.0185871|    0.4969418|    0.0231661|  26.735865|             2.4710178|
|  1e+05|   0.0304051|    0.6102706|    0.0338783|  20.071354|             1.7433756|
|  2e+05|   0.0454999|    0.8651301|    0.0808125|  19.013908|             1.5577417|
|  5e+05|   0.1030013|    1.4400972|    0.2222625|  13.981353|             1.0654600|
|  1e+06|   0.2066127|    2.5203579|    0.3126621|  12.198464|             0.8829542|
|  2e+06|   0.4829743|    4.7065370|    0.5017289|   9.744901|             0.6716611|
|  5e+06|   1.1542890|   12.6808568|    1.2257031|  10.985859|             0.7122137|
|  1e+07|   2.4988707|   26.7692815|    2.2693765|  10.712552|             0.6646289|
|  2e+07|   5.3056336|   57.2001299|    4.8211123|  10.781018|             0.6412981|
|  5e+07|  15.4460678|  157.2902965|   13.0957611|  10.183193|             0.5744281|
|  1e+08|  37.0182569|  345.2271557|   29.2712506|   9.325862|             0.5062713|

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

``` r
ggplot(data = means, aes(x = rows, y = ratio_by_log_rows)) +
  geom_point() + 
  geom_smooth(se = FALSE) +
  scale_x_log10() + 
  ggtitle("ratio of dplyr runtime to data.table runtime dived by log(rows)",
          subtitle = "grouped sorting/sum task")
```

    ## `geom_smooth()` using method = 'loess' and formula 'y ~ x'

    ## Warning: Removed 1 rows containing non-finite values (stat_smooth).

<img src="GroupedSorting_files/figure-markdown_github/present-3.png" width="1152" />
