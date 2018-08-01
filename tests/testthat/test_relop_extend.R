
library("rqdatatable")
context("relop_extend")

test_that("relop_extend works as expected", {

  dL <- build_frame(
    "subjectID", "surveyCategory"     , "assessmentTotal", "one" |
      1          , "withdrawal behavior", 5                , 1     |
      1          , "positive re-framing", 2                , 1     |
      2          , "withdrawal behavior", 3                , 1     |
      2          , "positive re-framing", 4                , 1     )

 # to 0.5.1 or newer.
 scale <- 0.237
 rquery_pipeline <- local_td(dL) %.>%
   extend_nse(.,
              probability %:=%
                exp(assessmentTotal * scale)/
                sum(exp(assessmentTotal * scale)),
              count %:=% sum(one),
              rank %:=% cumsum(one),
              orderby = c("assessmentTotal", "surveyCategory"),
              reverse = c("assessmentTotal"),
              partitionby = 'subjectID')  %.>%
   orderby(., c("subjectID", "probability"))
 rquery_pipeline <- local_td(dL) %.>%
   extend_nse(.,
              probability %:=%
                exp(assessmentTotal * 0.237)/
                sum(exp(assessmentTotal * 0.237)),
              count %:=% sum(one),
              rank %:=% cumsum(one),
              orderby = c("assessmentTotal", "surveyCategory"),
              reverse = c("assessmentTotal"),
              partitionby = 'subjectID')  %.>%
   orderby(., c("subjectID", "probability"))
 res <- ex_data_table(rquery_pipeline, tables = list(dL = dL))
 expect_true(data.table::is.data.table(res))

})
