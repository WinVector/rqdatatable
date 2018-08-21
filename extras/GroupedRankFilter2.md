Grouped Rank Filter
================

This is an experiment comparing the performance of a number of data processing systems available in [<code>R</code>](https://www.r-project.org). Our example problem is finding the top ranking item per group (group defined by three columns: <code>col\_a</code>, <code>col\_b</code>, <code>col\_b</code>; and order defined by a single column <code>col\_x</code>). This is a common often needed task.

``` r
# https://cran.r-project.org/web/packages/reticulate/vignettes/r_markdown.html
library("reticulate")
use_python("/home/ruser/miniconda3/bin/python3")
# use_python("/Users/johnmount/anaconda3/bin/python3")
pandas_handle <- reticulate::import("pandas") # don't use as https://github.com/rstudio/reticulate/issues/319

pandas_fn <- py_run_string("
def py_fn(df):
   ord = df.sort_values(by = ['col_a', 'col_b', 'col_c', 'col_x'], ascending = [True, True, True, True])
   ord['rank_col'] = ord.groupby(['col_a', 'col_b', 'col_c']).cumcount()
   return ord[ord.rank_col == 0].ix[:, ['col_a', 'col_b', 'col_c', 'col_x']]
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
base_r <- function(df) {
  rownames(df) <- NULL
  df <- df[order(df$col_a, df$col_b, df$col_c, df$col_x, method = 'radix'), , 
           drop = FALSE]
  rownames(df) <- NULL
  n <- length(df$col_a)
  first <- c(TRUE,
             (df$col_a[-1] != df$col_a[-n]) | 
               (df$col_b[-1] != df$col_b[-n]) | 
               (df$col_c[-1] != df$col_c[-n]))
  df <- df[first, , drop = FALSE]
  rownames(df) <- NULL
  df
}
```

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
      gc()
      d <- mk_data(sz)
      ti <- microbenchmark(
        base_r = {
          base_r(d)
        },
        data.table = { 
          # https://stackoverflow.com/questions/16325641/how-to-extract-the-first-n-rows-per-group
          d %.>% 
            as.data.table(.) %.>% 
            setorder(., col_a, col_b, col_c, col_x) %.>%
            .[, .SD[1], by=list(col_a, col_b, col_c)] 
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
        dplyr_b = {
          d %>% 
            arrange(col_x) %>% 
            group_by(col_a, col_b, col_c) %>% 
            mutate(rn = row_number()) %>%
            ungroup() %>%
            filter(rn == 1) %>%
            select(col_a, col_b, col_c, col_x) %>%
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

First let's compare three methods on the same grouped ranking problem.

-   [<code>dplyr</code>](https://CRAN.R-project.org/package=dplyr)
-   Base <code>R</code> (term defined as <code>R</code> plus just core packages, earlier results [here](http://www.win-vector.com/blog/2018/01/base-r-can-be-fast/)).
-   The seemingly silly idea of using [<code>reticulate</code>](https://CRAN.R-project.org/package=reticulate) to ship the data to <code>Python</code>, and then using [<code>Pandas</code>](https://pandas.pydata.org) to do the work, and finally bring the result back to <code>R</code>.

``` r
timings <- do.call(rbind, runs)
timings$seconds <- timings$time/1e+9
timings$method <- factor(timings$expr)
timings$method <- reorder(timings$method, -timings$seconds)
method_map <- c(dplyr = "dplyr", 
                dplyr_b = "dplyr",
                pandas_reticulate = "base-R or R/python roundtrip",
                data.table = "data.table",
                rqdatatable = "data.table",   
                base_r  = "base-R or R/python roundtrip")
color_map <- c(
   dplyr = "#e7298a",
   dplyr_b = "#d95f02",
   pandas_reticulate = "#e6ab02",
   data.table = "#66a61e",
   rqdatatable = "#1b9e77",
   base_r = "#7570b3")
timings$method_family <- method_map[as.character(timings$method)]
timings$method_family <- reorder(timings$method_family, -timings$seconds)
rowset <- sort(unique(timings$rows))
smooths <- lapply(
  unique(as.character(timings$method)),
  function(mi) {
    ti <- timings[timings$method == mi, , drop = FALSE]
    ti$rows <- log(ti$rows)
    si <- loess(log(seconds) ~ rows, data = ti)
    pi <- data.frame(
      method = mi,
      rows = log(rowset),
      stringsAsFactors = FALSE)
    pi$seconds <- exp(predict(si, newdata = pi))
    pi$rows <- rowset
    pi
  })
smooths <- do.call(rbind, smooths)
smooths$method <- factor(smooths$method, levels = levels(timings$method))
```

``` r
ggplot(data = timings[timings$method %in% qc(dplyr, base_r, pandas_reticulate),], 
       aes(x = rows, y = seconds)) +
  geom_point(aes(color = method)) + 
  geom_smooth(aes(color = method),
              se = FALSE) +
  scale_x_log10() +
  scale_y_log10() +
  scale_color_manual(values = color_map[qc(dplyr, base_r, "pandas_reticulate")]) +
  ggtitle("grouped ranked selection task time by rows and method",
          subtitle = "log-log trend shown; comparing dplyr, base-R, Python round-trip") 
```

    ## `geom_smooth()` using method = 'loess' and formula 'y ~ x'

<img src="GroupedRankFilter2_files/figure-markdown_github/present2-1.png" width="1152" />

Notice, contrary to many claims, <code>dplyr</code> is slower (higher up on the graph) than base <code>R</code> for all problem scales tested (1 row through 100,000,000 rows). Height differences on a <code>log-y</code> scaled graph such as this represent ratios of run-times and we can see the ratio of <code>dplyr</code> to base-<code>R</code> runtime is routinely around a multiplicative factor of 50.

Also notice by the time we get the problem size up to 5,000 rows even sending the data to <code>Python</code> and back for <code>Pandas</code> processing is faster than <code>dplyr</code>.

Note: in this article "<code>pandas</code> timing" means the time it would take an <code>R</code> process to use <code>Pandas</code> for data manipulation. This includes the extra overhead of moving the data from <code>R</code> to <code>Python</code>/<code>Pandas</code> and back. This is always going to be slower than <code>Pandas</code> itself as it includes extra overhead. The point is we are not running a test designed to compare (or capable of comparing) <code>Pandas</code> to [<code>data.table</code>](https://CRAN.R-project.org/package=data.table) (you can already find such a study [here](https://github.com/Rdatatable/data.table/wiki/Benchmarks-%3A-Grouping)), but instead performing a one-sided test of how <code>dplyr</code> compares to <code>Pandas</code> *plus* extra transport costs (so it is interesting if <code>Pandas</code> is faster, or even competitive, in this set-up, but not informative if <code>Pandas</code> plus extra costs is slower).

All runs were performed on an Amazon EC2 `r4.8xlarge` (244 GiB RAM) 64-bit Ubuntu Server 16.04 LTS (HVM), SSD Volume Type - ami-ba602bc2. We used R 3.4.4, with all packages current as of 8-20-2018 (the date of the experiment).

We are not testing [<code>dtplyr</code>](https://CRAN.R-project.org/package=dtplyr) for the simple reason it does not work with the <code>dplyr</code> pipeline as written.

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

    ## Error in data.table::is.data.table(data): argument "x" is missing, with no default

For our example we used what I consider the natural <code>dplyr</code> solution to the problem. The code looks like the following.

``` r
d %>% 
  group_by(col_a, col_b, col_c) %>% 
  arrange(col_x) %>% 
  filter(row_number() == 1) %>%
  ungroup() %>%
  arrange(col_a, col_b, col_c, col_x)
```

<code>dplyr</code> has [known (unfixed) issues with filtering in the presence of grouping](https://github.com/tidyverse/dplyr/issues/3294). Let's try to work around that with the following code (pivoting as many operations out of the grouped data section of the pipeline).

``` r
d %>% 
  arrange(col_x) %>% 
  group_by(col_a, col_b, col_c) %>% 
  mutate(rn = row_number()) %>%
  ungroup() %>%
  filter(rn == 1) %>%
  select(col_a, col_b, col_c, col_x) %>%
  arrange(col_a, col_b, col_c, col_x)
```

We will call the above solution "<code>dplyr\_b</code>". A new comparison including "<code>dplyr\_b</code>" is given below.

``` r
ggplot(data = timings[timings$method %in% qc(dplyr, base_r, dplyr_b,
                                             data.table),], 
       aes(x = rows, y = seconds)) +
  geom_point(aes(color = method)) + 
  geom_smooth(aes(color = method),
              se = FALSE) +
  scale_x_log10() +
  scale_y_log10() +
  scale_color_manual(values = color_map[qc(dplyr, base_r, dplyr_b,
                                             data.table)]) +
  ggtitle("grouped ranked selection task time by rows and method",
          subtitle = "log-log trend shown; comparing dplyr, base-R, and data.table") 
```

    ## `geom_smooth()` using method = 'loess' and formula 'y ~ x'

<img src="GroupedRankFilter2_files/figure-markdown_github/present3-1.png" width="1152" />

Notice in the above graph we have also added <code>data.table</code> results (and left out the earlier <code>Pandas</code> results). At no scale tested does either of the <code>dplyr</code> solutions match the performance of either of base-<code>R</code> or <code>data.table</code>. The ratio of the runtime of the first (or more natual) <code>dplyr</code> solution over the <code>data.table</code> runtime (<code>data.table</code> being by far the best solution) is routinely over 80 to 1.

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
             ratio_a = dplyr/data.table,
             ratio_b = dplyr_b/data.table) %.>%
  orderby(., "rows") %.>%
  as.data.frame(.)

m2 <- means %.>%
  select_columns(., 
                 qc(rows, ratio_a, ratio_b)) %.>%
  unpivot_to_blocks(.,
                    nameForNewKeyColumn = "comparison",
                    nameForNewValueColumn = "ratio",
                    columnsToTakeFrom = qc(ratio_a, ratio_b))
  
ggplot(data = m2, aes(x = rows, y = ratio, color = comparison)) +
  geom_point() + 
  geom_smooth(se = FALSE) +
  scale_x_log10() + 
  scale_y_log10(
    breaks = 2^{0:8},
    minor_breaks = 1:128) + 
  scale_color_manual(values = as.character(color_map[qc(dplyr, dplyr_b)])) +
  geom_hline(yintercept = 1, color = "darkgray") + 
  ggtitle("ratio of dplyr runtime to data.table runtime",
          subtitle = "grouped rank selection task")
```

    ## `geom_smooth()` using method = 'loess' and formula 'y ~ x'

<img src="GroupedRankFilter2_files/figure-markdown_github/present5-1.png" width="1152" />

We also tested an [<code>rqdatatable</code>](https://CRAN.R-project.org/package=rqdatatable) solution. <code>rqdatatable</code> uses <code>data.table</code> to implement the [<code>rquery</code>](https://CRAN.R-project.org/package=rqdatatable) data manipulation grammar, so it has more overhead than <code>data.table</code>.

Full results are below (and all code and results are [here](https://github.com/WinVector/rqdatatable/blob/master/extras/GroupedRankFilter2.md)).

``` r
ggplot(data = timings, aes(x = rows, y = seconds)) +
  geom_line(data = smooths,
            alpha = 0.7,
            linetype = 2,
            aes(group = method, color = method)) +
  geom_point(data = timings, aes(color = method)) + 
  geom_smooth(data = timings, aes(color = method),
              se = FALSE) +
  scale_x_log10() +
  scale_y_log10() +
  scale_color_manual(values = color_map) +
  ggtitle("grouped ranked selection task time by rows and method",
          subtitle = "log-log trend shown; showing all results") +
  facet_wrap(~method_family, ncol=1, labeller = "label_both")
```

    ## `geom_smooth()` using method = 'loess' and formula 'y ~ x'

<img src="GroupedRankFilter2_files/figure-markdown_github/present4-1.png" width="1152" />

``` r
knitr::kable(means[, 
                   qc(rows, base_r, data.table, 
                      dplyr, dplyr_b, 
                      pandas_reticulate, rqdatatable)])
```

|   rows|     base\_r|  data.table|         dplyr|     dplyr\_b|  pandas\_reticulate|  rqdatatable|
|------:|-----------:|-----------:|-------------:|------------:|-------------------:|------------:|
|  1e+00|   0.0003267|   0.0009635|     0.0032435|    0.0056354|           0.0515041|    0.0068414|
|  2e+00|   0.0003528|   0.0011762|     0.0039913|    0.0056410|           0.0502828|    0.0073060|
|  5e+00|   0.0003385|   0.0010677|     0.0034936|    0.0045818|           0.0525998|    0.0068656|
|  1e+01|   0.0002953|   0.0011747|     0.0033224|    0.0046752|           0.0528985|    0.0061786|
|  2e+01|   0.0003701|   0.0011826|     0.0033672|    0.0051183|           0.0515722|    0.0072840|
|  5e+01|   0.0003502|   0.0011314|     0.0049174|    0.0058086|           0.0501480|    0.0079664|
|  1e+02|   0.0004028|   0.0011917|     0.0050619|    0.0058480|           0.0516048|    0.0063728|
|  2e+02|   0.0003551|   0.0011431|     0.0061629|    0.0054713|           0.0521349|    0.0069566|
|  5e+02|   0.0005584|   0.0011976|     0.0091727|    0.0059109|           0.0536094|    0.0075940|
|  1e+03|   0.0006866|   0.0013731|     0.0175628|    0.0071574|           0.0525276|    0.0083290|
|  2e+03|   0.0009508|   0.0014346|     0.0306059|    0.0085873|           0.0587110|    0.0085833|
|  5e+03|   0.0017535|   0.0016617|     0.1062600|    0.0134023|           0.0633362|    0.0103101|
|  1e+04|   0.0032618|   0.0023880|     0.1585770|    0.0215488|           0.0783897|    0.0117951|
|  2e+04|   0.0068442|   0.0036975|     0.2773583|    0.0388676|           0.1047436|    0.0781040|
|  5e+04|   0.0220546|   0.0076919|     0.8126197|    0.1302733|           0.1919448|    0.0287966|
|  1e+05|   0.0542680|   0.0150029|     1.6392750|    0.2519953|           0.3619354|    0.0539985|
|  2e+05|   0.0984879|   0.0297835|     3.8033730|    0.4226258|           0.7554858|    0.1376937|
|  5e+05|   0.1888721|   0.0750671|     8.6772974|    1.6534837|           2.0085191|    0.3987250|
|  1e+06|   0.3081734|   0.1597136|    19.0250048|    3.1239851|           4.5261344|    0.6841254|
|  2e+06|   0.6314713|   0.4500708|    37.5676553|    6.6708313|           9.9416448|    1.2899695|
|  5e+06|   2.0422985|   0.9812918|    89.7617447|   17.1999063|          27.1812446|    3.0494435|
|  1e+07|   4.1903058|   2.9464046|   185.6145993|   38.0824507|          55.4756717|    8.5571020|
|  2e+07|  10.0234737|   4.5928288|   371.9769376|   87.0174476|         121.7105373|   14.2129314|
|  5e+07|  30.3027149|  10.7915545|   978.9227351|  227.6743024|         313.1767425|   33.9917370|
|  1e+08|  96.0148219|  27.9374640|  2075.8621812|  573.3556189|         683.8245597|   66.8635493|

``` r
knitr::kable(means[, 
                   qc(rows, data.table, 
                      dplyr, dplyr_b, 
                      ratio_a, ratio_b)])
```

|   rows|  data.table|         dplyr|     dplyr\_b|    ratio\_a|   ratio\_b|
|------:|-----------:|-------------:|------------:|-----------:|----------:|
|  1e+00|   0.0009635|     0.0032435|    0.0056354|    3.366340|   5.848884|
|  2e+00|   0.0011762|     0.0039913|    0.0056410|    3.393389|   4.795870|
|  5e+00|   0.0010677|     0.0034936|    0.0045818|    3.272137|   4.291283|
|  1e+01|   0.0011747|     0.0033224|    0.0046752|    2.828368|   3.980007|
|  2e+01|   0.0011826|     0.0033672|    0.0051183|    2.847248|   4.327989|
|  5e+01|   0.0011314|     0.0049174|    0.0058086|    4.346260|   5.133901|
|  1e+02|   0.0011917|     0.0050619|    0.0058480|    4.247761|   4.907425|
|  2e+02|   0.0011431|     0.0061629|    0.0054713|    5.391524|   4.786483|
|  5e+02|   0.0011976|     0.0091727|    0.0059109|    7.659537|   4.935831|
|  1e+03|   0.0013731|     0.0175628|    0.0071574|   12.790704|   5.212602|
|  2e+03|   0.0014346|     0.0306059|    0.0085873|   21.333661|   5.985711|
|  5e+03|   0.0016617|     0.1062600|    0.0134023|   63.946449|   8.065404|
|  1e+04|   0.0023880|     0.1585770|    0.0215488|   66.404714|   9.023651|
|  2e+04|   0.0036975|     0.2773583|    0.0388676|   75.011801|  10.511779|
|  5e+04|   0.0076919|     0.8126197|    0.1302733|  105.646123|  16.936417|
|  1e+05|   0.0150029|     1.6392750|    0.2519953|  109.263959|  16.796454|
|  2e+05|   0.0297835|     3.8033730|    0.4226258|  127.700648|  14.189929|
|  5e+05|   0.0750671|     8.6772974|    1.6534837|  115.593808|  22.026728|
|  1e+06|   0.1597136|    19.0250048|    3.1239851|  119.119507|  19.559920|
|  2e+06|   0.4500708|    37.5676553|    6.6708313|   83.470539|  14.821737|
|  5e+06|   0.9812918|    89.7617447|   17.1999063|   91.473038|  17.527820|
|  1e+07|   2.9464046|   185.6145993|   38.0824507|   62.996982|  12.925058|
|  2e+07|   4.5928288|   371.9769376|   87.0174476|   80.990813|  18.946373|
|  5e+07|  10.7915545|   978.9227351|  227.6743024|   90.711929|  21.097452|
|  1e+08|  27.9374640|  2075.8621812|  573.3556189|   74.303887|  20.522823|
