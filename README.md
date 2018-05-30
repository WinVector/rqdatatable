
<!-- README.md is generated from README.Rmd. Please edit that file -->
[`qdatatable`](https://github.com/WinVector/qdatatable) is an implementation of the [`rquery`](https://github.com/WinVector/rquery) piped relational algebra hosted on [`data.tabl`](http://r-datatable.com). `qdatatabl` allow the expression of complex transformations as a series of relational operators. For example scoring a logistic regression model (which requires grouping, ordering, and ranking) is organized as follows. For more on this example please see ["Let’s Have Some Sympathy For The Part-time R User"](http://www.win-vector.com/blog/2017/08/lets-have-some-sympathy-for-the-part-time-r-user/).

``` r
library("qdatatable")
```

    ## Loading required package: rquery

    ## Loading required package: wrapr

``` r
library("data.table")
```

    ## 
    ## Attaching package: 'data.table'

    ## The following object is masked from 'package:wrapr':
    ## 
    ##     :=

``` r
# data example
dL <- wrapr::build_frame(
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
             one := 1) %.>%
  extend_nse(.,
             probability :=
               exp(assessmentTotal * scale)/
               sum(exp(assessmentTotal * scale)),
             count := sum(one),
             rank := rank(probability, surveyCategory),
             partitionby = 'subjectID') %.>%
  extend_nse(.,
             isdiagnosis := rank == count,
             diagnosis := surveyCategory) %.>%
  select_rows_nse(., 
                  isdiagnosis == TRUE) %.>%
  select_columns(., 
                 c('subjectID', 'diagnosis', 'probability')) %.>%
  orderby(., 'subjectID')
```

Show expanded form of query tree.

``` r
cat(format(rquery_pipeline))
```

    table('dL'; 
      subjectID,
      surveyCategory,
      assessmentTotal) %.>%
     extend(.,
      one := 1) %.>%
     extend(.,
      probability := exp(assessmentTotal * scale)/sum(exp(assessmentTotal * scale)),
      count := sum(one),
      p= subjectID) %.>%
     extend(.,
      rank := rank(probability, surveyCategory),
      p= subjectID) %.>%
     extend(.,
      isdiagnosis := rank == count,
      diagnosis := surveyCategory) %.>%
     select_rows(.,
       isdiagnosis == TRUE) %.>%
     select_columns(.,
       subjectID, diagnosis, probability) %.>%
     orderby(., subjectID)

``` r
ex_data_table(rquery_pipeline)[]
```

    ##    subjectID           diagnosis probability
    ## 1:         1 withdrawal behavior   0.6706221
    ## 2:         2 positive re-framing   0.5589742

Initial benchmarking of `qdatatable` is very favorable (notes [here](https://github.com/WinVector/rquery/blob/master/extras/data_table.md)).

To install `qdatatable` please use `devtools` as follows.

``` r
# install.packages("devtools")
devtools::install_github("WinVector/qdatatable")
```
