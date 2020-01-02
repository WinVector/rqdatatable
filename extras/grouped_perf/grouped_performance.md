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

    ## Loading required package: rquery

``` r
packageVersion("rquery")
```

    ## [1] '1.4.1'

``` r
packageVersion("rqdatatable")
```

    ## [1] '1.2.4'

``` r
ops_rqdatatable <- local_td(d, name = 'd') %.>%
  extend(.,
         rn %:=% row_number(),
         cs %:=% cumsum(x),
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
stopifnot(all.equal(data.frame(res_rqdatatable), data.frame(res_data.table)))
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
stopifnot(all.equal(data.frame(res_rqdatatable), data.frame(res_dplyr)))
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
    ungroup()
  return(as_tibble(res_dtplyr))
}

res_dtplyr <- f_dtplyr(d)
stopifnot(all.equal(data.frame(res_rqdatatable), data.frame(res_dtplyr)))
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
    ##   data.table  1.761819  1.801918  2.074670  1.907565  2.360966  2.541081     5
    ##        dplyr 31.293568 33.383398 35.104285 34.324209 36.101260 40.418988     5
    ##       dtplyr  4.412182  4.692573  5.140682  4.888749  5.618379  6.091527     5
    ##  rqdatatable  3.365419  3.470157  3.776139  3.580841  4.020857  4.443421     5
