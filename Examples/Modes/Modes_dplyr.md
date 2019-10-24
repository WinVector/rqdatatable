Modes\_dplyr
================

This is running [`dplyr`](https://CRAN.R-project.org/package=dplyr) and
[`dtplyr`](https://CRAN.R-project.org/package=dtplyr) on the [“`rquery`
Modes
Example”](https://github.com/WinVector/rqdatatable/blob/master/Examples/Modes/Modes.md).

First we define the functions and data we used in the [`rquery` modes
example](https://github.com/WinVector/rqdatatable/blob/master/Examples/Modes/Modes.m)
example.

``` r
library(rquery)
library(data.table)
```

    ## Warning: package 'data.table' was built under R version 3.5.2

``` r
library(microbenchmark)
```

    ## Warning: package 'microbenchmark' was built under R version 3.5.2

``` r
library(dplyr)
```

    ## Warning: package 'dplyr' was built under R version 3.5.2

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
packageVersion('dplyr')
```

    ## [1] '0.8.3'

``` r
library(dtplyr)
```

    ## Warning: package 'dtplyr' was built under R version 3.5.2

``` r
packageVersion('dtplyr')
```

    ## [1] '0.0.3'

``` r
set.seed(2019)

n_rows <- 1000000

d_large <- data.frame(
  x = rnorm(n = n_rows),
  y = rnorm(n = n_rows),
  g = sample(paste0('v_', seq_len(n_rows/10)), 
             size = n_rows, 
             replace = TRUE),
  stringsAsFactors = FALSE
)
```

``` r
ops <- local_td(d_large) %.>%  # Describe table for later operations
  extend(.,       # add a new column
         ratio := y / x) %.>%
  extend(.,       # rank the rows by group and order
         simple_rank := row_number(),
         partitionby = 'g',
         orderby = 'ratio',
         reverse = 'ratio') %.>%
  extend(.,       # mark the rows we want
         choice := simple_rank == 1)
```

``` r
f_compiled <- function(dat) {
  dat %.>% ops  # use pre-compiled pipeline
}

f_immediate <- function(dat) {
  dat %.>%
    extend(.,       # add a new column
           ratio := y / x) %.>%
    extend(.,       # rank the rows by group and order
           simple_rank := row_number(),
           partitionby = 'g',
           orderby = 'ratio',
           reverse = 'ratio') %.>%
    extend(.,       # mark the rows we want
           choice := simple_rank == 1)
}

f_wrapped <- function(dat) {
  dat %.>%
    wrap %.>%       # wrap data in a description
    extend(.,       # add a new column
           ratio := y / x) %.>%
    extend(.,       # rank the rows by group and order
           simple_rank := row_number(),
           partitionby = 'g',
           orderby = 'ratio',
           reverse = 'ratio') %.>%
    extend(.,       # mark the rows we want
           choice := simple_rank == 1) %.>%
    ex              # signal construction done, and execute
}
```

The `dplyr` version of the pipeline is similar, except the window
functions are not a single step- but a 4 stage block.

``` r
f_dplyr <- function(dat) {
  dat %>%
    mutate(        # add a new column
           ratio := y / x) %>%
    group_by(      # rank the rows by group and order
             g) %>%
    arrange( -ratio) %>%
    mutate(     
           simple_rank := row_number()) %>%
    ungroup() %>%  # end of rank block
    mutate(        # mark the rows we want
           choice := simple_rank == 1)
}
```

We are using the most current `CRAN` versions of each (`dtplyr` is
currently being re-engineered to try to also cut down the number
conversions).

Above we see a key difference between `rquery` and `dplyr`: `rquery`
grouped and window functions are single operators in `rquery`, but are
driven by annotations between steps in `dplyr`.

`dtplyr` seems to error-out on this problem, meaning the automatic
translations from `dplyr` to `data.table` are not sufficient to our
task.

``` r
f_dplyr(data.table(d_large))
```

    ## Error in `:=`(ratio, y/x): Check that is.data.table(DT) == TRUE. Otherwise, := and `:=`(...) are defined for use in j, once only and in particular ways. See help(":=").

We can try to re-write the `dtplyr` pipeline as follows. It appears
switching from `:=` to `=` and replacing `row_number()` with `.I` helps.

``` r
f_dtplyr <- function(dat) {
  data.table(dat) %>%
    mutate(        # add a new column
           ratio = y / x) %>%
    group_by(      # rank the rows by group and order
             g) %>%
    arrange( -ratio) %>%
    mutate(     
           simple_rank = .I) %>%
    ungroup() %>%  # end of rank block
    mutate(        # mark the rows we want
           choice = simple_rank == 1)
}

head(f_dtplyr(d_large))
```

    ## Source: local data table [6 x 6]
    ## 
    ## # A tibble: 6 x 6
    ##        x      y g      ratio simple_rank choice
    ##    <dbl>  <dbl> <chr>  <dbl>       <int> <lgl> 
    ## 1  0.277  3.15  v_1   11.4             1 TRUE  
    ## 2 -0.502 -1.38  v_1    2.74            2 FALSE 
    ## 3 -1.18  -2.08  v_1    1.75            3 FALSE 
    ## 4  1.02   1.56  v_1    1.54            4 FALSE 
    ## 5 -1.48  -1.93  v_1    1.31            5 FALSE 
    ## 6 -1.03  -0.901 v_1    0.872           6 FALSE

And we can also time `data.table` itself (without the translation
overhead, though we are adding in the time to convert the `data.frame`).

``` r
f_data_table = function(dat) {
  dat <- data.table(dat)
  dat[ , ratio := y / x
       ][order(-ratio) , simple_rank := 1:.N, by = list(g)
          ][ , choice := simple_rank == 1]
}
```

``` r
timings <- microbenchmark(
  rquery_compiled = f_compiled(d_large),
  rquery_immediate = f_immediate(d_large),
  rquery_wrapped = f_wrapped(d_large),
  dplyr = f_dplyr(d_large),
  dtplyr = f_dtplyr(d_large),
  data.table = f_data_table(d_large),
  times = 10L
)

print(timings)
```

    ## Unit: milliseconds
    ##              expr       min        lq      mean    median        uq
    ##   rquery_compiled  623.5139  688.6973  811.8352  800.6101  857.8718
    ##  rquery_immediate  935.4277 1038.1815 1140.6284 1075.4822 1235.3507
    ##    rquery_wrapped  704.7512  727.7314  840.8779  853.2034  913.8645
    ##             dplyr 7977.7499 8438.8750 8853.3462 8878.5247 9222.8179
    ##            dtplyr  838.4266 1075.9857 1163.8247 1183.0681 1255.6366
    ##        data.table  536.2818  575.5401  667.0928  657.4243  772.9167
    ##        max neval
    ##  1185.2507    10
    ##  1519.1752    10
    ##  1001.3966    10
    ##  9684.5956    10
    ##  1517.9664    10
    ##   834.3378    10

For these short pipelines the extra copying in `rquery` immediate mode
and `dtplyr` are not causing big problems compared to the overall
translation overhead.
