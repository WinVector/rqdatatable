
library("rqdatatable")
context("relop_extend")

test_that("relop_extend works as expected", {


 scale <- 0.237
 dL <- build_frame(
     "subjectID", "surveyCategory"     , "assessmentTotal", "one" |
     1          , "withdrawal behavior", 5                , 1     |
     1          , "positive re-framing", 2                , 1     |
     2          , "withdrawal behavior", 3                , 1     |
     2          , "positive re-framing", 4                , 1     )
 rquery_pipeline <- local_td(dL) %.>%
   extend_nse(.,
              probability %:=%
                exp(assessmentTotal * scale)/
                sum(exp(assessmentTotal * scale)),
              count %:=% sum(one),
              rank %:=% rank(),
              orderby = c("assessmentTotal", "surveyCategory"),
              reverse = c("assessmentTotal"),
              partitionby = 'subjectID') %.>%
   orderby(., c("subjectID", "probability"))
 res <- ex_data_table(rquery_pipeline)
 expect_true(data.table::is.data.table(res))

})
