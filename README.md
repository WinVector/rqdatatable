
<!-- README.md is generated from README.Rmd. Please edit that file -->

[![CRAN\_Status\_Badge](https://www.r-pkg.org/badges/version/rqdatatable)](https://cran.r-project.org/package=rqdatatable)
[![status](https://tinyverse.netlify.com/badge/rqdatatable)](https://CRAN.R-project.org/package=rqdatatable)

![](https://github.com/WinVector/rqdatatable/raw/master/tools/rqdatatable.png)

[`rqdatatable`](https://github.com/WinVector/rqdatatable) is an
implementation of the [`rquery`](https://github.com/WinVector/rquery)
piped Codd-style relational algebra hosted on
[`data.table`](https://rdatatable.gitlab.io/data.table/). `rquery` allow
the expression of complex transformations as a series of relational
operators and `rqdatatable` implements the operators using `data.table`.

A `Python` version of `rquery`/`rqdatatable` is under initial
development as
[`data_algebra`](https://github.com/WinVector/data_algebra).

For example scoring a logistic regression model (which requires
grouping, ordering, and ranking) is organized as follows. For more on
this example please see [“Let’s Have Some Sympathy For The Part-time R
User”](https://win-vector.com/2017/08/04/lets-have-some-sympathy-for-the-part-time-r-user/).

``` r
library("rqdatatable")
```

    ## Loading required package: wrapr

    ## Loading required package: rquery

``` r
# data example
dL <- build_frame(
   "subjectID", "surveyCategory"     , "assessmentTotal" |
   1          , "withdrawal behavior", 5                 |
   1          , "positive re-framing", 2                 |
   2          , "withdrawal behavior", 3                 |
   2          , "positive re-framing", 4                 )
```

``` r
scale <- 0.237

# example rquery pipeline
rquery_pipeline <- local_td(dL) %.>%
  extend_nse(.,
             probability :=
               exp(assessmentTotal * scale))  %.>% 
  normalize_cols(.,
                 "probability",
                 partitionby = 'subjectID') %.>%
  pick_top_k(.,
             k = 1,
             partitionby = 'subjectID',
             orderby = c('probability', 'surveyCategory'),
             reverse = c('probability', 'surveyCategory')) %.>% 
  rename_columns(., c('diagnosis' = 'surveyCategory')) %.>%
  select_columns(., c('subjectID', 
                      'diagnosis', 
                      'probability')) %.>%
  orderby(., cols = 'subjectID')
```

We can show the expanded form of query tree.

``` r
cat(format(rquery_pipeline))
```

    mk_td("dL", c(
      "subjectID",
      "surveyCategory",
      "assessmentTotal")) %.>%
     extend(.,
      probability := exp(assessmentTotal * 0.237)) %.>%
     extend(.,
      probability := probability / sum(probability),
      partitionby = c('subjectID'),
      orderby = c(),
      reverse = c()) %.>%
     extend(.,
      row_number := row_number(),
      partitionby = c('subjectID'),
      orderby = c('probability', 'surveyCategory'),
      reverse = c('probability', 'surveyCategory')) %.>%
     select_rows(.,
       row_number <= 1) %.>%
     rename_columns(.,
      c('diagnosis' = 'surveyCategory')) %.>%
     select_columns(., 
        c('subjectID', 'diagnosis', 'probability')) %.>%
     order_rows(.,
      c('subjectID'),
      reverse = c(),
      limit = NULL)

And execute it using `data.table`.

``` r
ex_data_table(rquery_pipeline)
```

    ##   subjectID           diagnosis probability
    ## 1         1 withdrawal behavior   0.6706221
    ## 2         2 positive re-framing   0.5589742

One can also apply the pipeline to new tables.

``` r
build_frame(
   "subjectID", "surveyCategory"     , "assessmentTotal" |
   7          , "withdrawal behavior", 5                 |
   7          , "positive re-framing", 20                ) %.>%
  rquery_pipeline
```

    ##   subjectID           diagnosis probability
    ## 1         7 positive re-framing   0.9722128

Initial bench-marking of `rqdatatable` is very favorable (notes
[here](https://win-vector.com/2018/06/03/rqdatatable-rquery-powered-by-data-table/)).

To install `rqdatatable` please use `install.packages("rqdatatable")`.

Some related work includes:

-   [`data.table`](https://rdatatable.gitlab.io/data.table/)
-   [`disk.frame`](https://github.com/xiaodaigh/disk.frame)
-   [`dbplyr`](https://dbplyr.tidyverse.org)
-   [`dplyr`](https://dplyr.tidyverse.org)
-   [`dtplyr`](https://github.com/tidyverse/dtplyr)
-   [`maditr`](https://github.com/gdemin/maditr)
-   [`nc`](https://github.com/tdhock/nc)
-   [`poorman`](https://github.com/nathaneastwood/poorman)
-   [`rquery`](https://github.com/WinVector/rquery)
-   [`SparkR`](https://CRAN.R-project.org/package=SparkR)
-   [`sparklyr`](https://spark.rstudio.com)
-   [`sqldf`](https://github.com/ggrothendieck/sqldf)
-   [`table.express`](https://github.com/asardaes/table.express)
-   [`tidyfast`](https://github.com/TysonStanley/tidyfast)
-   [`tidyfst`](https://github.com/hope-data-science/tidyfst)
-   [`tidyquery`](https://github.com/ianmcook/tidyquery)
-   [`tidyr`](https://tidyr.tidyverse.org)
-   [`tidytable`](https://github.com/markfairbanks/tidytable) (formerly
    `gdt`/`tidydt`)

–

Note `rqdatatable` has an “immediate mode” which allows direct
application of pipelines stages without pre-assembling the pipeline.
“Immediate mode” is a convenience for ad-hoc analyses, and has some
negative performance impact, so we encourage users to build pipelines
for most work. Some notes on the issue can be found
[here](https://github.com/WinVector/rqdatatable/blob/master/extras/ImmediateIssue.md).

`rqdatatable` implements the `rquery` grammar in the style of a “Turing
or Cook reduction” (implementing the result in terms of multiple oracle
calls to the related system).

`rqdatatable` is intended for “simple column names”, in particular as
`rqdatatable` often uses `eval()` to work over `data.table` escape
characters such as “`\`” and “`\\`” are not reliable in column names.
Also `rqdatatable` does not support tables with no columns.
