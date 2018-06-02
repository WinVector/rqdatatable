
<!-- README.md is generated from README.Rmd. Please edit that file -->
[`rqdatatable`](https://github.com/WinVector/rqdatatable) is an implementation of the [`rquery`](https://github.com/WinVector/rquery) piped relational algebra hosted on [`data.table`](http://r-datatable.com). `rquery` allow the expression of complex transformations as a series of relational operators and `rqdatatable` implements the operators using `data.table`.

For example scoring a logistic regression model (which requires grouping, ordering, and ranking) is organized as follows. For more on this example please see ["Let’s Have Some Sympathy For The Part-time R User"](http://www.win-vector.com/blog/2017/08/lets-have-some-sympathy-for-the-part-time-r-user/).

``` r
library("rqdatatable")
```

    ## Loading required package: rquery

    ## Loading required package: wrapr

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
  rename_columns(., 'diagnosis' := 'surveyCategory') %.>%
  select_columns(., c('subjectID', 
                      'diagnosis', 
                      'probability')) %.>%
  orderby(., cols = 'subjectID')
```

We can show the expanded form of query tree.

``` r
cat(format(rquery_pipeline))
```

    table('dL'; 
      subjectID,
      surveyCategory,
      assessmentTotal) %.>%
     extend(.,
      probability := exp(assessmentTotal * scale)) %.>%
     extend(.,
      probability := probability / sum(probability),
      p= subjectID) %.>%
     extend(.,
      row_rank := rank(),
      p= subjectID,
      o= "probability" DESC, "surveyCategory" DESC) %.>%
     select_rows(.,
       row_rank <= 1) %.>%
     rename(.,
      c('diagnosis' = 'surveyCategory')) %.>%
     select_columns(.,
       subjectID, diagnosis, probability) %.>%
     orderby(., subjectID)

And execute it using `data.table`.

``` r
ex_data_table(rquery_pipeline)[]
```

    ##    subjectID           diagnosis probability
    ## 1:         1 withdrawal behavior   0.6706221
    ## 2:         2 positive re-framing   0.5589742

Initial bench-marking of `rqdatatable` is very favorable (notes [here](https://github.com/WinVector/rquery/blob/master/extras/data_table.md)).

To install `rqdatatable` please use `devtools` as follows.

``` r
# install.packages("devtools")
devtools::install_github("WinVector/rqdatatable")
```
