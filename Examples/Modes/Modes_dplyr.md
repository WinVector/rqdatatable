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

d_large %.>%
  ops %.>%
  order_rows(., 'g') %.>%
  select_rows(., choice) %.>% 
  head(.) %.>%
  knitr::kable(.)
```

|           x |           y | g         |     ratio | simple\_rank | choice |
| ----------: | ----------: | :-------- | --------: | -----------: | :----- |
|   0.2773596 |   3.1546090 | v\_1      | 11.373713 |            1 | TRUE   |
|   0.3373741 |   0.3947169 | v\_10     |  1.169968 |            1 | TRUE   |
| \-0.4033178 | \-1.2618623 | v\_100    |  3.128705 |            1 | TRUE   |
|   0.1218793 |   2.6972358 | v\_1000   | 22.130387 |            1 | TRUE   |
|   0.0029194 |   0.1780082 | v\_10000  | 60.974286 |            1 | TRUE   |
| \-0.2867625 | \-1.6812063 | v\_100000 |  5.862713 |            1 | TRUE   |

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
           simple_rank = 1:.N) %>%
    ungroup() %>%  # end of rank block
    mutate(        # mark the rows we want
           choice = simple_rank == 1)
}

res_dtplyr <- f_dtplyr(d_large)

res_dtplyr %.>%
  order_rows(., 'g') %.>%
  select_rows(., choice) %.>% 
  head(.) %.>%
  knitr::kable(.)
```

|           x |           y | g         |     ratio | simple\_rank | choice |
| ----------: | ----------: | :-------- | --------: | -----------: | :----- |
|   0.2773596 |   3.1546090 | v\_1      | 11.373713 |            1 | TRUE   |
|   0.3373741 |   0.3947169 | v\_10     |  1.169968 |            1 | TRUE   |
| \-0.4033178 | \-1.2618623 | v\_100    |  3.128705 |            1 | TRUE   |
|   0.1218793 |   2.6972358 | v\_1000   | 22.130387 |            1 | TRUE   |
|   0.0029194 |   0.1780082 | v\_10000  | 60.974286 |            1 | TRUE   |
| \-0.2867625 | \-1.6812063 | v\_100000 |  5.862713 |            1 | TRUE   |

And we can also time `data.table` itself (without the translation
overhead, though we are adding in the time to convert the `data.frame`).

``` r
f_data_table = function(dat) {
  dat <- data.table(dat)
  dat[ , ratio := y / x
       ][order(-ratio) , simple_rank := 1:.N, by = list(g)
          ][ , choice := simple_rank == 1]
}

res_dt <- f_data_table(d_large)

res_dt %.>%
  order_rows(., 'g') %.>%
  select_rows(., choice) %.>% 
  head(.) %.>%
  knitr::kable(.)
```

|           x |           y | g         |     ratio | simple\_rank | choice |
| ----------: | ----------: | :-------- | --------: | -----------: | :----- |
|   0.2773596 |   3.1546090 | v\_1      | 11.373713 |            1 | TRUE   |
|   0.3373741 |   0.3947169 | v\_10     |  1.169968 |            1 | TRUE   |
| \-0.4033178 | \-1.2618623 | v\_100    |  3.128705 |            1 | TRUE   |
|   0.1218793 |   2.6972358 | v\_1000   | 22.130387 |            1 | TRUE   |
|   0.0029194 |   0.1780082 | v\_10000  | 60.974286 |            1 | TRUE   |
| \-0.2867625 | \-1.6812063 | v\_100000 |  5.862713 |            1 | TRUE   |

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
    ##   rquery_compiled  622.7957  658.8947  686.7348  677.8611  685.2826
    ##  rquery_immediate  779.0562  843.1967  896.2168  851.3933  988.0829
    ##    rquery_wrapped  665.9337  705.3427  790.4567  772.1591  844.0691
    ##             dplyr 7751.4788 7931.7369 8229.6599 8254.8785 8392.5296
    ##            dtplyr  782.4301  881.4511  961.5546  931.8426 1011.3056
    ##        data.table  487.0091  503.2039  592.4115  543.4839  729.2733
    ##        max neval
    ##   800.3783    10
    ##  1042.6305    10
    ##  1036.7086    10
    ##  8845.9042    10
    ##  1342.3543    10
    ##   799.2439    10

For these short pipelines the extra copying in `rquery` immediate mode
and `dtplyr` are not causing big problems compared to the overall
translation overhead.
