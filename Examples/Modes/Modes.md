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

For our task: let’s find a row with the largest ratio of ‘y’ to ‘x’, per
group ‘g’.

The `rquery` concept is to break this into small sub-goals and steps:

  - Find the ratio of ‘y’ to ‘x’.
  - Rank the rows by this ratio.
  - Mark our chosen rows.

In the standard `rquery` practice we build up our processing pipeline to
follow our above plan. The translation involves some familiarity with
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

The `ops` operator pipeline can than be used to process data.

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

And we can also time `data.table` itself (without the translation
overhead, though we are adding in the time to convert the `data.frame`).

``` r
library(data.table)
```

    ## Warning: package 'data.table' was built under R version 3.5.2

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
  data.table = f_data_table(d_large),
  times = 10L
)

print(timings)
```

    ## Unit: milliseconds
    ##              expr      min       lq      mean    median        uq
    ##   rquery_compiled 633.6622 650.0457  719.3338  751.8094  756.8682
    ##  rquery_immediate 827.6549 984.8910 1078.4037 1005.4246 1153.9471
    ##    rquery_wrapped 695.4244 738.1480  787.9664  765.0884  861.6540
    ##        data.table 504.8573 548.7947  640.0024  589.4774  699.1614
    ##        max neval
    ##   818.0530    10
    ##  1523.7683    10
    ##   932.1775    10
    ##   962.9058    10

Notice, the speed differences are usually not that large for short
pipelines. Then intent is: pipeline construction and data conversion
steps should be cheap compared to the actual processing steps.

We have an attempt to add `dplyr` and `dtplyr` to the comparisons
[here](https://github.com/WinVector/rqdatatable/blob/master/Examples/Modes/Modes.md).
