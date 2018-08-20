Grouped Rank Filter
================

Amazon EC2 `r4.8xlarge` (244 GiB RAM) run (8-12-2018, 64-bit Ubuntu Server 16.04 LTS (HVM), SSD Volume Type - ami-ba602bc2, R 3.4.4 all packages current).

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
shift_col <- function(col) { c(col[1], col[-length(col)]) }

base_r <- function(df) {
  df <- df[order(df$col_a, df$col_b, df$col_c, df$col_x), , drop = FALSE]
  first <- (df$col_a != shift_col(df$col_a)) | 
    (df$col_b != shift_col(df$col_b)) | 
    (df$col_c != shift_col(df$col_c))
  first[[1]] <- TRUE
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

ggplot(data = timings, aes(x = rows, y = seconds, 
                           color = method, linetype = method)) +
  geom_point() + 
  geom_smooth(se = FALSE, size = 2) +
  scale_x_log10() +
  scale_y_log10() +
  ggtitle("grouped sorting task time by rows and method",
          subtitle = "log-log trend shown") +
  theme(legend.position="bottom",
        legend.key.width = unit(5, "line"))
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

|   rows|       base\_r|  data.table|         dplyr|  pandas\_reticulate|  rqdatatable|       ratio|
|------:|-------------:|-----------:|-------------:|-------------------:|------------:|-----------:|
|  1e+00|     0.0002893|   0.0013325|     0.0039254|           0.0512419|    0.0075790|    2.945841|
|  2e+00|     0.0002932|   0.0011294|     0.0036759|           0.0528443|    0.0068870|    3.254752|
|  5e+00|     0.0003099|   0.0013581|     0.0033767|           0.0532702|    0.0062582|    2.486286|
|  1e+01|     0.0003403|   0.0013485|     0.0043542|           0.0518351|    0.0071795|    3.228994|
|  2e+01|     0.0003796|   0.0013151|     0.0043106|           0.0522062|    0.0074439|    3.277694|
|  5e+01|     0.0003630|   0.0012311|     0.0039330|           0.0531442|    0.0068979|    3.194622|
|  1e+02|     0.0004733|   0.0014238|     0.0051162|           0.0524040|    0.0073499|    3.593244|
|  2e+02|     0.0006608|   0.0011772|     0.0051955|           0.0552670|    0.0064488|    4.413452|
|  5e+02|     0.0011173|   0.0013277|     0.0093479|           0.0554849|    0.0071853|    7.040724|
|  1e+03|     0.0022101|   0.0014939|     0.0162594|           0.0565608|    0.0078529|   10.883527|
|  2e+03|     0.0045852|   0.0018925|     0.0303687|           0.0607572|    0.0091274|   16.047078|
|  5e+03|     0.0130999|   0.0020826|     0.0766733|           0.0741889|    0.0106186|   36.815276|
|  1e+04|     0.0296574|   0.0025798|     0.1404100|           0.0870428|    0.0440239|   54.425966|
|  2e+04|     0.0688981|   0.0041732|     0.3406466|           0.1176999|    0.0155363|   81.626753|
|  5e+04|     0.1980745|   0.0086734|     0.8598038|           0.2212087|    0.0290472|   99.131268|
|  1e+05|     0.4435825|   0.0169538|     1.6885893|           0.4077173|    0.0518821|   99.599261|
|  2e+05|     0.9548308|   0.0322762|     3.5516129|           0.9841111|    0.0987897|  110.038288|
|  5e+05|     2.4986960|   0.0826356|    10.4754257|           2.4088991|    0.4033369|  126.766494|
|  1e+06|     5.4666837|   0.2240016|    17.8698256|           5.5981733|    0.5497724|   79.775448|
|  2e+06|    12.3868152|   0.3723851|    33.2980737|          12.1565400|    1.3211994|   89.418374|
|  5e+06|    37.2254820|   1.0195498|    89.9073401|          32.8994262|    2.7483575|   88.183375|
|  1e+07|    82.3766165|   1.8505861|   180.7952714|          69.5261685|    5.2569947|   97.696224|
|  2e+07|   183.3998428|   7.2371603|   377.5268163|         142.0003996|   13.8596790|   52.165048|
|  5e+07|   513.6415602|  10.9281731|   941.2680897|         398.9318990|   42.7868746|   86.132246|
|  1e+08|  1111.9033024|  28.5475393|  2120.9840990|         906.1016305|   76.0889183|   74.296565|

``` r
ggplot(data = means, aes(x = rows, y = ratio)) +
  geom_point() + 
  geom_smooth(se = FALSE) +
  scale_x_log10() + 
  scale_color_manual(values = c("#e41a1c", "#377eb8", "#4daf4a", "#984ea3", "#ff7f00")) + 
  ggtitle("ratio of dplyr runtime to data.table runtime",
          subtitle = "grouped sorting/sum task")
```

    ## `geom_smooth()` using method = 'loess' and formula 'y ~ x'

<img src="GroupedRankFilter2_files/figure-markdown_github/present-2.png" width="1152" />
