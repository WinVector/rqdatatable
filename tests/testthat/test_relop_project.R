
library("rqdatatable")
context("relop_project")

test_that("relop_project works as expected", {


 dL <- build_frame(
   "subjectID", "surveyCategory"     , "assessmentTotal" |
     1          , "withdrawal behavior", 5                 |
     1          , "positive re-framing", 2                 |
     2          , "withdrawal behavior", 3                 |
     2          , "positive re-framing", 4                 )
 test_p <- local_td(dL) %.>%
   extend_nse(.,
              one %:=% 1) %.>%
   project_nse(.,
               maxscore = max(assessmentTotal),
               groupby = 'subjectID')
 cat(format(test_p))
 ex_data_table(test_p)[]

})