rquery Modes
================

[`rqdatatable`](https://github.com/WinVector/rqdatatable)/[`rquery`](https://github.com/WinVector/rquery)
is designed to have a number of different modes of use. The primary
intended one the considered mode of building up a pipelines from a
description of the tables to be acted on.

As our example, lets start with the following example data.

``` r
d <- data.frame(
  x = c(1, 2, 3, 4, 5, 6),
  y = c(2, 2, 2, 3, 7, 10),
  g = c('a', 'a', 'a', 'b', 'b' ,'b'),
  stringsAsFactors = FALSE
)

knitr::kable(d)
```

| x |  y | g |
| -: | -: | :- |
| 1 |  2 | a |
| 2 |  2 | a |
| 3 |  2 | a |
| 4 |  3 | b |
| 5 |  7 | b |
| 6 | 10 | b |

For our task: let’s find a row with the larget ratio of ‘y’ to ‘x’, per
group ‘g’.

The `rquery` concept is to break this into small sub-goals and steps:

  - Find the ratio of ‘y’ to ‘x’.
  - Rank the rows by this ratio.
  - Mark our chosen rows.

In the standard `rquery` practice we build up our processing pipeline to
follow our above plan. The translation invovles some familiarity with
the `rquery` steps, including the row-numbering command
[`row_number()`](https://github.com/WinVector/rquery/blob/master/Examples/WindowFunctions/WindowFunctions.md).

``` r
library(rquery)

ops <- local_td(d) %.>%  # Describe table for later operations
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

The `ops` operator pipelne can than be used to process data.

``` r
d %.>%
  ops %.>%
  knitr::kable(.)
```

| x |  y | g |     ratio | simple\_rank | choice |
| -: | -: | :- | --------: | -----------: | :----- |
| 1 |  2 | a | 2.0000000 |            1 | TRUE   |
| 2 |  2 | a | 1.0000000 |            2 | FALSE  |
| 3 |  2 | a | 0.6666667 |            3 | FALSE  |
| 6 | 10 | b | 1.6666667 |            1 | TRUE   |
| 5 |  7 | b | 1.4000000 |            2 | FALSE  |
| 4 |  3 | b | 0.7500000 |            3 | FALSE  |

Another way to use `rquery`/`rqdatatable` is in “immediate mode”, where
we send the data from pipeline stage to pipeline state.

``` r
d %.>%
  extend(.,       # add a new column
         ratio := y / x) %.>%
  extend(.,       # rank the rows by group and order
         simple_rank := row_number(),
         partitionby = 'g',
         orderby = 'ratio',
         reverse = 'ratio') %.>%
  extend(.,       # mark the rows we want
         choice := simple_rank == 1) %.>%
  knitr::kable(.)
```

| x |  y | g |     ratio | simple\_rank | choice |
| -: | -: | :- | --------: | -----------: | :----- |
| 1 |  2 | a | 2.0000000 |            1 | TRUE   |
| 2 |  2 | a | 1.0000000 |            2 | FALSE  |
| 3 |  2 | a | 0.6666667 |            3 | FALSE  |
| 6 | 10 | b | 1.6666667 |            1 | TRUE   |
| 5 |  7 | b | 1.4000000 |            2 | FALSE  |
| 4 |  3 | b | 0.7500000 |            3 | FALSE  |

Immediate mode skips the `local_td()` step of building a specification
for the data to later come, and runs directly on the data. The advantage
of this mode is: it is quick for the user. A disadvantage of this mode
is: the pipeline is not left for re-use, and there are possibly
expensive data conversions (from `data.frame` to `data.table`) at each
operator stage.

``` r
d %.>%
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
  ex %.>%         # signal construction done, and execute
  knitr::kable(.)
```

| x |  y | g |     ratio | simple\_rank | choice |
| -: | -: | :- | --------: | -----------: | :----- |
| 1 |  2 | a | 2.0000000 |            1 | TRUE   |
| 2 |  2 | a | 1.0000000 |            2 | FALSE  |
| 3 |  2 | a | 0.6666667 |            3 | FALSE  |
| 6 | 10 | b | 1.6666667 |            1 | TRUE   |
| 5 |  7 | b | 1.4000000 |            2 | FALSE  |
| 4 |  3 | b | 0.7500000 |            3 | FALSE  |

The difference is: we use the `wrap` to data, and then later `ex` to say
we are done specifying steps and to execute the data.

``` r
library(microbenchmark)
```

    ## Warning: package 'microbenchmark' was built under R version 3.5.2

``` r
n_rows <- 1000000
d_large <- data.frame(
  x = rnorm(n = n_rows),
  y = rnorm(n = n_rows),
  g = sample(paste0('v_', seq_len(n_rows/10)), 
             size = n_rows, 
             replace = TRUE),
  stringsAsFactors = FALSE
)

f_compiled <- function() {
  d_large %.>% ops  # use pre-compiled pipeline
}

f_immediate <- function() {
  d_large %.>%
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

f_wrapped <- function() {
  d_large %.>%
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

f_dplyr <- function() {
  d_large %.>%
    mutate(.,       # add a new column
           ratio := y / x) %.>%
    group_by(.,     # rank the rows by group and order
             g) %.>%
    arrange(.,
            -ratio) %.>%
    mutate(.,      
           simple_rank := row_number()) %.>%
    mutate(.,       # mark the rows we want
           choice := simple_rank == 1)
}

timings <- microbenchmark(
  f_compiled = f_compiled(),
  f_immediate = f_immediate(),
  f_wrapped = f_wrapped(),
  times = 10L
)

print(timings)
```

    ## Unit: milliseconds
    ##         expr      min       lq      mean    median        uq      max
    ##   f_compiled 613.7339 659.8995  736.2775  680.0341  753.3297 1120.026
    ##  f_immediate 833.9003 939.3323 1080.5864 1000.0393 1146.9923 1774.043
    ##    f_wrapped 725.5387 778.6493  906.2301  849.2547  989.6489 1308.662
    ##  neval
    ##     10
    ##     10
    ##     10

Notice, the speed differences are usually not that large. Then intent
is: pipeline construction and data conversion steps should be cheap
compared to the actual processing steps.

Let’s re-run the timings with similar `dplyr` and `dtplyr` pipelines. We
are using the most current `CRAN` versions of each (`dtplyr` is
currently being re-enginneered to try to also cut down the number
conversions).

``` r
library(dplyr)
```

    ## Warning: package 'dplyr' was built under R version 3.5.2

    ## 
    ## Attaching package: 'dplyr'

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
library(data.table)
```

    ## Warning: package 'data.table' was built under R version 3.5.2

    ## 
    ## Attaching package: 'data.table'

    ## The following objects are masked from 'package:dplyr':
    ## 
    ##     between, first, last

``` r
library(dtplyr)
```

    ## Warning: package 'dtplyr' was built under R version 3.5.2

``` r
packageVersion('dtplyr')
```

    ## [1] '0.0.3'

``` r
dt_large <- data.table(d_large)

f_dplyr <- function() {
  d_large %.>%
    mutate(.,       # add a new column
           ratio := y / x) %.>%
    group_by(.,     # rank the rows by group and order
             g) %.>%
    arrange(.,
            -ratio) %.>%
    mutate(.,      
           simple_rank := row_number()) %.>%
    ungroup(.) %.>% # end of rank block
    mutate(.,       # mark the rows we want
           choice := simple_rank == 1)
}
```

Above we see a key difference between `rquery` and `dplyr`: `rquery`
grouped and window functions are single operators in `rquery`, but are
driven by annotations between steps in `dplyr`.

`dtplyr` seems to error-out on this problem, so we won’t try to time it.

``` r
f_dtplyr <- function() {
  dt_large %.>%
    mutate(.,       # add a new column
           ratio = y / x) %.>%
    group_by(.,     # rank the rows by group and order
             g) %.>%
    arrange(.,
            -ratio) %.>%
    mutate(.,      
           simple_rank = row_number()) %.>%
    ungroup(.) %.>% # end of rank block
    mutate(.,       # mark the rows we want
           choice = simple_rank == 1)
}

f_dtplyr()
```

    ## row_number() should only be called in a data context

``` r
timings <- microbenchmark(
  compiled = f_compiled(),
  immediate = f_immediate(),
  wrapped = f_wrapped(),
  dplyr = f_dplyr(),
  #  dtplyr = f_dtplyr(),
  times = 10L
)

print(timings)
```

    ## Unit: milliseconds
    ##       expr       min        lq      mean    median        uq      max
    ##   compiled  627.9068  666.0104  810.1124  801.8569  941.8993 1043.082
    ##  immediate  788.3829  885.5931  953.9062  950.2130  994.9757 1160.636
    ##    wrapped  650.7361  734.3984  799.5256  788.0851  850.2615 1010.496
    ##      dplyr 7742.7528 7881.5624 8248.3403 8345.4308 8407.3679 8830.875
    ##  neval
    ##     10
    ##     10
    ##     10
    ##     10
