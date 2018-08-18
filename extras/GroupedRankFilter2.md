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
pow <- 8
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

|   rows|  data.table|         dplyr|  pandas\_reticulate|  rqdatatable|      ratio|
|------:|-----------:|-------------:|-------------------:|------------:|----------:|
|  1e+00|   0.0013044|     0.0103761|           0.0526532|    0.0090958|   7.954726|
|  2e+00|   0.0011725|     0.0033142|           0.0509832|    0.0081892|   2.826511|
|  5e+00|   0.0012929|     0.0034154|           0.0484493|    0.0444046|   2.641566|
|  1e+01|   0.0012331|     0.0034988|           0.0482039|    0.0091830|   2.837444|
|  2e+01|   0.0011964|     0.0034465|           0.0496014|    0.0095062|   2.880811|
|  5e+01|   0.0012161|     0.0038770|           0.0492078|    0.0083844|   3.187999|
|  1e+02|   0.0011861|     0.0041911|           0.0510651|    0.0083904|   3.533635|
|  2e+02|   0.0012136|     0.0051852|           0.0499095|    0.0085473|   4.272605|
|  5e+02|   0.0013343|     0.0095215|           0.0515220|    0.0086387|   7.135880|
|  1e+03|   0.0014381|     0.0142589|           0.0519340|    0.0096481|   9.915308|
|  2e+03|   0.0017626|     0.0260113|           0.0568113|    0.0098866|  14.757094|
|  5e+03|   0.0031885|     0.0642016|           0.0652364|    0.0114742|  20.135500|
|  1e+04|   0.0026181|     0.1189145|           0.0831414|    0.0139115|  45.420815|
|  2e+04|   0.0045909|     0.2484106|           0.1554748|    0.0185435|  54.108923|
|  5e+04|   0.0100507|     0.6912687|           0.2756078|    0.0744354|  68.777941|
|  1e+05|   0.0212089|     1.4367429|           0.4771554|    0.0977245|  67.742527|
|  2e+05|   0.0343076|     2.8469232|           0.9341816|    0.1276155|  82.982261|
|  5e+05|   0.0977098|     7.1662103|           2.6869110|    0.5496446|  73.341743|
|  1e+06|   0.2331859|    14.9369690|           6.1160769|    0.7489606|  64.056059|
|  2e+06|   0.5411397|    31.7541695|          12.3761522|    1.1525302|  58.680171|
|  5e+06|   1.0363018|    80.8073983|          33.3570382|    3.4413053|  77.976703|
|  1e+07|   2.0440195|   173.7356822|          74.0035290|    7.6405196|  84.997078|
|  2e+07|  11.2958123|   376.2707813|         145.2269821|   13.2490890|  33.310644|
|  5e+07|  22.3381065|   942.6821488|         385.6512349|   32.8063748|  42.200629|
|  1e+08|  26.7253973|  1936.2246529|         804.7686751|  136.6120934|  72.448863|

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
