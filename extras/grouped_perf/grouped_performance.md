grouped\_performance
================

Make example data.

``` r
set.seed(2020)
n <- 1000000

mk_data <- function(n) {
  d <- data.frame(x = rnorm(n))
  d$g <- sprintf("level_%09g", sample.int(n, size = n, replace = TRUE))
  return(d)
}

d <- mk_data(n)
write.csv(d, file = gzfile("d.csv.gz"), quote = FALSE, row.names = FALSE)
```

Example processing, `rqdatatable`.

``` r
library(rqdatatable)
```

    ## Loading required package: wrapr

    ## Loading required package: rquery

``` r
packageVersion("rquery")
```

    ## [1] '1.4.3'

``` r
packageVersion("rqdatatable")
```

    ## [1] '1.2.7'

``` r
ops_rqdatatable <- local_td(d, name = 'd') %.>%
  extend(.,
         rn := row_number(),
         cs := cumsum(x),
         partitionby = 'g',
         orderby = 'x') %.>%
  order_rows(.,
             c('g', 'x'))

res_rqdatatable <- d %.>% ops_rqdatatable

knitr::kable(head(res_rqdatatable))
```

|           x | g                | rn |          cs |
| ----------: | :--------------- | -: | ----------: |
| \-0.9203975 | level\_000000002 |  1 | \-0.9203975 |
|   0.5372110 | level\_000000003 |  1 |   0.5372110 |
|   0.7349189 | level\_000000004 |  1 |   0.7349189 |
| \-0.8907554 | level\_000000005 |  1 | \-0.8907554 |
|   1.7029350 | level\_000000008 |  1 |   1.7029350 |
| \-0.6675965 | level\_000000010 |  1 | \-0.6675965 |

``` r
print(nrow(res_rqdatatable) == n)
```

    ## [1] TRUE

``` r
print(max(res_rqdatatable$rn))
```

    ## [1] 9

``` r
write.csv(res_rqdatatable, file = gzfile("res.csv.gz"), quote = FALSE, row.names = FALSE)
```

(Note, we could use `:=` for assignment if we imported `rquery` or
`wrapr`, but we are avoiding that to avoid colliding with `data.table`’s
or `dplyr`’s use of the symbol.)

Example processing `data.table`.

``` r
library(data.table)
```

    ## 
    ## Attaching package: 'data.table'

    ## The following object is masked from 'package:wrapr':
    ## 
    ##     :=

``` r
packageVersion("data.table")
```

    ## [1] '1.12.8'

``` r
f_data.table <- function(d) {
  dt <- data.table(d)
  res_data.table <- setorderv(dt, c('g', 'x'))[, `:=`(rn = seq_len(.N), cs = cumsum(x)), by = g]
  return(res_data.table)
}

res_data.table <- f_data.table(d)
knitr::kable(head(res_data.table))
```

|           x | g                | rn |          cs |
| ----------: | :--------------- | -: | ----------: |
| \-0.9203975 | level\_000000002 |  1 | \-0.9203975 |
|   0.5372110 | level\_000000003 |  1 |   0.5372110 |
|   0.7349189 | level\_000000004 |  1 |   0.7349189 |
| \-0.8907554 | level\_000000005 |  1 | \-0.8907554 |
|   1.7029350 | level\_000000008 |  1 |   1.7029350 |
| \-0.6675965 | level\_000000010 |  1 | \-0.6675965 |

``` r
stopifnot(all.equal(res_rqdatatable, data.frame(res_data.table)))
```

Example processing, `dplyr`.

``` r
library(dplyr)
```

    ## 
    ## Attaching package: 'dplyr'

    ## The following objects are masked from 'package:data.table':
    ## 
    ##     between, first, last

    ## The following object is masked from 'package:wrapr':
    ## 
    ##     coalesce

    ## The following objects are masked from 'package:stats':
    ## 
    ##     filter, lag

    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

``` r
packageVersion("dplyr")
```

    ## [1] '0.8.3'

``` r
ops_dplyr <- . %>%
  arrange(g, x) %>%
  group_by(g) %>%
  mutate(
    rn = row_number(),
    cs = cumsum(x)) %>%
  ungroup()

res_dplyr <- d %>% ops_dplyr

knitr::kable(head(res_dplyr))
```

|           x | g                | rn |          cs |
| ----------: | :--------------- | -: | ----------: |
| \-0.9203975 | level\_000000002 |  1 | \-0.9203975 |
|   0.5372110 | level\_000000003 |  1 |   0.5372110 |
|   0.7349189 | level\_000000004 |  1 |   0.7349189 |
| \-0.8907554 | level\_000000005 |  1 | \-0.8907554 |
|   1.7029350 | level\_000000008 |  1 |   1.7029350 |
| \-0.6675965 | level\_000000010 |  1 | \-0.6675965 |

``` r
stopifnot(all.equal(res_rqdatatable, data.frame(res_dplyr)))
```

Example processing, `dtplyr`.

``` r
library(dtplyr)
packageVersion("dtplyr")
```

    ## [1] '1.0.0'

``` r
f_dtplyr <- function(d) {
  res_dtplyr <- lazy_dt(d) %>%
    arrange(g, x) %>%
    group_by(g) %>%
    mutate(
      rn = row_number(),
      cs = cumsum(x)) %>%
    ungroup() %>%
    as_tibble()
  return(res_dtplyr)
}

res_dtplyr <- f_dtplyr(d)
stopifnot(all.equal(res_rqdatatable, data.frame(res_dtplyr)))
```

``` r
library(microbenchmark)

microbenchmark(
  data.table = f_data.table(d),
  dplyr = d %>% ops_dplyr,
  dtplyr = f_dtplyr(d),
  rqdatatable = d %.>% ops_rqdatatable,
  times = 5L)
```

    ## Unit: seconds
    ##         expr       min        lq      mean    median        uq       max neval
    ##   data.table  1.647990  1.711399  1.794348  1.713328  1.802321  2.096700     5
    ##        dplyr 31.310196 32.386980 33.813750 32.486036 35.603723 37.281816     5
    ##       dtplyr  4.385252  4.582455  4.610222  4.621821  4.718904  4.742677     5
    ##  rqdatatable  3.182464  3.470306  3.750955  3.678086  3.920189  4.503732     5
